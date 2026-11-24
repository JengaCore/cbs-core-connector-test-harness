#!/usr/bin/env python3
"""Generate direct-integration/field-reference.md from the combined API definition and the
hub's ISO 20022 field mapping.

    pip install pyyaml
    python3 generate_field_reference.py \
        --spec  <api_spec.yaml of the combined ISO 20022 + FSPIOP API> \
        --mappings <ml-schema-transformer-lib>/src/mappings/fspiopiso20022 \
        --spec-url <permalink of the spec file on GitHub> \
        --out ../field-reference.md

Two things are produced for each message:

* the fields the hub reads and how it interprets them (from the hub's own mapping), and
* the full structure of the message schema, every element, with type, whether it is required
  within its parent, constraints and the meaning given in the API definition.
"""
import argparse
import re
import sys

import yaml

MESSAGES = [
    # method path, schema, mapping (module, key...)
    ("PUT /parties/{Type}/{ID}", "GetParties_IdentificationVerificationReportV03", ("discovery", "parties", "put"),
     "parties", "PartiesByTypeAndID2"),
    ("PUT /parties/{Type}/{ID}/error", "GetPartiesError_IdentificationVerificationReportV03",
     ("discovery", "parties", "putError"), "parties", "PartiesErrorByTypeAndID"),
    ("POST /quotes", "TermsRequest_FIToFICustomerCreditProposal", ("quotes", "post"), "quotes", "Quotes"),
    ("PUT /quotes/{ID}", "TermsResponse_FIToFICustomerCreditConfirmation", ("quotes", "put"), "quotes", "QuotesByID1"),
    ("PUT /quotes/{ID}/error", "PacsError_FIToFIPaymentStatusReportV15", ("quotes", "putError"), "quotes",
     "QuotesByIDAndError"),
    ("POST /transfers", "Execute_FIToFICustomerCreditTransferV13", ("transfers", "post"), "transfers", "transfers"),
    ("PUT /transfers/{ID}", "PacsStatus_FIToFIPaymentStatusReportV15", ("transfers", "put"), "transfers",
     "TransfersByIDPut"),
    ("PATCH /transfers/{ID}", "PacsStatus_FIToFIPaymentStatusReportV15", ("transfers", "patch"), "transfers",
     "TransfersByIDPatch"),
    ("PUT /transfers/{ID}/error", "PacsError_FIToFIPaymentStatusReportV15", ("transfers", "putError"), "transfers",
     "TransfersByIDAndError"),
]
VIEWER = "https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022"

# Schemas that have identical structure are documented once.
STRUCTURES = [
    ("Party report", ["GetParties_IdentificationVerificationReportV03",
                      "GetPartiesError_IdentificationVerificationReportV03"]),
    ("Customer credit transfer", ["TermsRequest_FIToFICustomerCreditProposal",
                                  "TermsResponse_FIToFICustomerCreditConfirmation",
                                  "Execute_FIToFICustomerCreditTransferV13"]),
    ("Payment status report", ["PacsStatus_FIToFIPaymentStatusReportV15",
                               "PacsError_FIToFIPaymentStatusReportV15"]),
]


def load(spec_path):
    with open(spec_path, encoding="utf-8") as f:
        text = f.read()
    return yaml.safe_load(text), text.splitlines()


def op_line(lines, path, method):
    """Line number of an operation in the spec file (1-based)."""
    key = "  " + path + ":"
    for i, line in enumerate(lines):
        if line.rstrip() == key:
            for j in range(i + 1, len(lines)):
                if re.match(r"^  /", lines[j]):
                    break
                if lines[j].startswith("    " + method.lower() + ":"):
                    return j + 1
    return None


def first_sentence(text, limit=300):
    """Turn a description from the API definition into one short line.

    Descriptions are written as an element name, optionally followed by
    "(FSPIOP equivalent: ...)", then the definition, optionally introduced by "Definition:"
    and followed by "Usage:" notes. The result is "<name>: <first sentence of the definition>."
    followed by the FSPIOP equivalent where there is one."""
    if not text:
        return ""
    lines = [re.sub(r"\s+", " ", l).strip() for l in str(text).strip().splitlines()]
    lines = [l for l in lines if l]
    if not lines:
        return ""
    head = lines[0]
    remainder = " ".join(lines[1:])
    equivalent = ""
    m = re.search(r"\(FSPIOP equivalent: ([^)]*)\)", head)
    if m:
        equivalent = m.group(1).strip()
        head = (head[: m.start()] + head[m.end():]).strip()
    d = re.search(r"Definition:\s*(.*)", remainder)
    body = d.group(1) if d else remainder
    body = body.split("Usage:")[0].strip()
    sent = re.search(r"(?<=[a-z0-9\)])\.(\s|$)", body)
    if sent:
        body = body[: sent.start() + 1]
    meaning = (head + ": " + body) if body else head
    if equivalent:
        meaning += (" " if meaning.endswith(".") else ". ") + "FSPIOP equivalent: " + equivalent + "."
    if len(meaning) > limit:
        meaning = meaning[: limit - 3].rstrip() + "..."
    return meaning.replace("|", "\\|")


class Flattener:
    def __init__(self, spec):
        self.schemas = spec["components"]["schemas"]

    def deref(self, s):
        while isinstance(s, dict) and "$ref" in s:
            s = self.schemas[s["$ref"].split("/")[-1]]
        return s

    def local_description(self, node):
        """The description of a property: its own, or from an allOf member, or from the referenced schema."""
        if not isinstance(node, dict):
            return ""
        if node.get("description"):
            return node["description"]
        for part in node.get("allOf", []) or []:
            if isinstance(part, dict) and part.get("description"):
                return part["description"]
        target = self.deref(node)
        if isinstance(target, dict):
            if target.get("description"):
                return target["description"]
            for part in target.get("allOf", []) or []:
                d = self.local_description(part)
                if d:
                    return d
        return ""

    def describe_type(self, node):
        t = self.deref(node)
        if not isinstance(t, dict):
            return "", ""
        for part in t.get("allOf", []) or []:
            pt = self.deref(part)
            if isinstance(pt, dict) and pt.get("type") and not t.get("type"):
                t = {**pt, **t}
        typ = t.get("type") or ("object" if t.get("properties") or t.get("allOf") else "")
        if t.get("oneOf") or t.get("anyOf"):
            typ = "choice"
        if t.get("format"):
            typ += f" ({t['format']})"
        cons = []
        if t.get("enum"):
            vals = t["enum"]
            cons.append("one of " + ", ".join(f"`{v}`" for v in vals) if len(vals) <= 8 else f"enum ({len(vals)} values)")
        if t.get("pattern"):
            cons.append("pattern: see spec" if len(str(t["pattern"])) > 60 else f"pattern `{t['pattern']}`")
        for k, label in (("minLength", "min length"), ("maxLength", "max length"), ("minimum", "min"),
                         ("maximum", "max"), ("minItems", "min items"), ("maxItems", "max items")):
            if k in t:
                cons.append(f"{label} {t[k]}")
        return typ, "; ".join(cons).replace("|", "\\|")

    def walk(self, node, path, required, rows, seen=()):
        name = node["$ref"].split("/")[-1] if isinstance(node, dict) and "$ref" in node else None
        if name and name in seen:
            return
        seen = seen + ((name,) if name else ())
        s = self.deref(node)
        if not isinstance(s, dict):
            return
        props, req = {}, set()

        def collect(x):
            x = self.deref(x)
            if not isinstance(x, dict):
                return
            for a in x.get("allOf", []) or []:
                collect(a)
            for k, v in (x.get("properties") or {}).items():
                props.setdefault(k, v)
            req.update(x.get("required", []) or [])

        collect(s)
        options = s.get("oneOf") or s.get("anyOf")
        if options:
            for opt in options:
                self.walk(opt, path, required, rows, seen)
            return
        if s.get("type") == "array" or (not s.get("type") and "items" in s):
            self.walk(s["items"], path + "[]", required, rows, seen)
            return
        for key, val in props.items():
            child = (path + "." if path else "") + key
            typ, cons = self.describe_type(val)
            rows.append({"path": child, "type": typ, "required": key in req, "constraints": cons,
                         "meaning": first_sentence(self.local_description(val))})
            self.walk(val, child, key in req, rows, seen)

    def rows_for(self, schema_name):
        rows = []
        self.walk({"$ref": "#/components/schemas/" + schema_name}, "", True, rows)
        return rows


def parse_mappings(directory):
    """Parse the ISO to FSPIOP direction of the hub's field mappings."""
    result = {}
    for module in ("discovery", "quotes", "transfers"):
        text = open(f"{directory}/{module}.ts", encoding="utf-8").read()
        current_export = None
        section = None
        for line in text.splitlines():
            m = re.match(r"^export const (\w+) = \{", line)
            if m:
                current_export = m.group(1) if not m.group(1).endswith("_reverse") else None
                section = None
                continue
            if current_export is None:
                continue
            m = re.match(r"^\s*(\w+): `\{\s*$", line) or re.match(r"^\s*(\w+): \{\s*$", line)
            if m and "$" not in m.group(1):
                section = m.group(1)
                continue
            if section is None:
                continue
            ent = re.match(r'^\s*"([^"]+)":\s*(.*?),?\s*$', line)
            if not ent:
                continue
            target, rest = ent.group(1), ent.group(2)
            if target.startswith("$"):
                continue
            sources = re.findall(r'"((?:body|headers|params)\.[^"]+)"', rest)
            transforms = re.findall(r'"\$transform":\s*"(\w+)"', rest)
            alt = "$alt" in rest
            key = ("discovery", "parties", section) if module == "discovery" else (module, section)
            result.setdefault(key, []).append((target, sources, transforms, alt))
    return result


def render(args):
    spec, lines = load(args.spec)
    fl = Flattener(spec)
    maps = parse_mappings(args.mappings)
    out = []
    w = out.append
    w("# Field reference\n")
    w("Every element of the ISO 20022 messages the hub exchanges with a DFSP, and how the hub reads them. "
      "It is generated from the combined API definition and the hub's field mapping by "
      "[tools/generate_field_reference.py](tools/generate_field_reference.py). Do not edit it by hand.\n")
    w(f"The messages can be viewed with their example payloads in the [API viewer]({VIEWER}). "
      f"The full definition is [api_spec.yaml]({args.spec_url}).\n")
    w("How to read the tables:\n")
    w("- **Required** means required within its parent element. A required element inside an optional "
      "parent is needed only when the parent is present.")
    w("- **Type** is the JSON type. `choice` marks an element where one of several alternatives is sent; "
      "the alternatives follow, at the same level.")
    w("- **Meaning** is the first sentence of the definition in the API definition.")
    w("- Paths are relative to the message body. `[]` marks a list.\n")
    w("## Contents\n")
    w("1. [Messages](#messages)")
    w("2. [Structures](#structures)\n")
    w("## Messages\n")
    w("For each message: where it is defined, the fields the hub reads, and the structure it uses.\n")
    struct_rows = {}
    for title, names in STRUCTURES:
        struct_rows[title] = fl.rows_for(names[0])
    lookup = {}
    for title, names in STRUCTURES:
        for n in names:
            lookup[n] = {r["path"].replace("[]", ""): r for r in struct_rows[title]}
    for call, schema, mkey, tag, opid in MESSAGES:
        method, path = call.split(" ", 1)
        line = op_line(lines, path, method)
        anchor = re.sub(r"[^a-z0-9]+", "-", call.lower()).strip("-")
        w(f"### {call}\n")
        w(f"- Schema: `{schema}`")
        w(f"- Payload viewer: [{call}]({VIEWER}#/{tag}/{opid})")
        if line:
            w(f"- Definition: [api_spec.yaml, line {line}]({args.spec_url}#L{line})")
        struct = next(t for t, names in STRUCTURES if schema in names)
        w(f"- Structure: [{struct}](#{re.sub(r'[^a-z0-9]+', '-', struct.lower()).strip('-')})\n")
        entries = maps.get(mkey, [])
        if entries:
            w("Fields the hub reads:\n")
            w("| Element | The hub reads it as | Meaning |")
            w("|---|---|---|")
            for target, sources, transforms, alt in entries:
                src = " or ".join(f"`{s}`" for s in sources) if sources else "(fixed)"
                note = ""
                if transforms:
                    note = " (" + ", ".join(transforms) + ")"
                first = sources[0] if sources else ""
                iso_path = re.sub(r"^body\.", "", first).replace("[]", "")
                meaning = lookup[schema].get(iso_path, {}).get("meaning", "")
                w(f"| {src} | `{target}`{note} | {meaning} |")
            w("")
        else:
            w("The hub reads no fields by mapping for this message.\n")
    w("## Structures\n")
    for title, names in STRUCTURES:
        rows = struct_rows[title]
        w(f"### {title}\n")
        w("Used by: " + ", ".join(f"`{n}`" for n in names) + ".\n")
        w(f"{len(rows)} elements.\n")
        w("| Path | Type | Required | Constraints | Meaning |")
        w("|---|---|---|---|---|")
        for r in rows:
            w(f"| `{r['path']}` | {r['type']} | {'Yes' if r['required'] else 'No'} | {r['constraints']} | "
              f"{r['meaning']} |")
        w("")
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--spec", required=True)
    ap.add_argument("--mappings", required=True)
    ap.add_argument("--spec-url", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    text = render(args)
    with open(args.out, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"wrote {args.out}: {text.count(chr(10))} lines", file=sys.stderr)


if __name__ == "__main__":
    main()
