# Field reference

Every element of the ISO 20022 messages the hub exchanges with a DFSP, and how the hub reads them. It is generated from the combined API definition and the hub's field mapping by [tools/generate_field_reference.py](tools/generate_field_reference.py). Do not edit it by hand.

The messages can be viewed with their example payloads in the [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022). The full definition is [api_spec.yaml](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml).

How to read the tables:

- **Required** means required within its parent element. A required element inside an optional parent is needed only when the parent is present.
- **Type** is the JSON type. `choice` marks an element where one of several alternatives is sent; the alternatives follow, at the same level.
- **Meaning** is the first sentence of the definition in the API definition.
- Paths are relative to the message body. `[]` marks a list.

## Contents

1. [Messages](#messages)
2. [Structures](#structures)

## Messages

For each message: where it is defined, the fields the hub reads, and the structure it uses.

### PUT /parties/{Type}/{ID}

- Schema: `GetParties_IdentificationVerificationReportV03`
- Payload viewer: [PUT /parties/{Type}/{ID}](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/parties/PartiesByTypeAndID2)
- Definition: [api_spec.yaml, line 731](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L731)
- Structure: [Party report](#party-report)

Fields the hub reads:

| Element | The hub reads it as | Meaning |
|---|---|---|
| `body.Assgnmt.Assgnr.Agt.FinInstnId.Othr.Id` | `headers.fspiop-source` |  |
| `body.Assgnmt.Assgne.Agt.FinInstnId.Othr.Id` | `headers.fspiop-destination` |  |
| `body.Rpt.UpdtdPtyAndAcctId.Pty.Id.OrgId.Othr.SchmeNm.Prtry` or `body.Rpt.UpdtdPtyAndAcctId.Pty.Id.PrvtId.Othr.SchmeNm.Prtry` or `body.Rpt.UpdtdPtyAndAcctId.Pty.PrvtId.Othr.Id` | `body.party.partyIdInfo.partyIdType` |  |
| `body.Rpt.UpdtdPtyAndAcctId.Pty.Id.OrgId.Othr.Id` or `body.Rpt.UpdtdPtyAndAcctId.Pty.Id.PrvtId.Othr.Id` | `body.party.partyIdInfo.partyIdentifier` |  |
| `body.Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.ClrSysMmbId.MmbId` | `body.party.partyIdInfo.partySubIdOrType` | MemberIdentification: Identification of a member of a clearing system. |
| `body.Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.Othr.Id` | `body.party.partyIdInfo.fspId` | Identification: Unique and unambiguous identification of a person. |
| `body.Rpt.UpdtdPtyAndAcctId.Pty.Nm` | `body.party.name` (getDisplayNameFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.Rpt.UpdtdPtyAndAcctId.Pty.Nm` | `body.party.personalInfo.complexName.firstName` (getFirstFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.Rpt.UpdtdPtyAndAcctId.Pty.Nm` | `body.party.personalInfo.complexName.middleName` (getMiddleFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.Rpt.UpdtdPtyAndAcctId.Pty.Nm` | `body.party.personalInfo.complexName.lastName` (getLastFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.Rpt.UpdtdPtyAndAcctId.Acct.Ccy` | `body.party.supportedCurrencies` (toArray) | Currency: Identification of the currency in which the account is held. |

### PUT /parties/{Type}/{ID}/error

- Schema: `GetPartiesError_IdentificationVerificationReportV03`
- Payload viewer: [PUT /parties/{Type}/{ID}/error](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/parties/PartiesErrorByTypeAndID)
- Definition: [api_spec.yaml, line 769](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L769)
- Structure: [Party report](#party-report)

Fields the hub reads:

| Element | The hub reads it as | Meaning |
|---|---|---|
| `body.Rpt.Rsn.Cd` | `body.errorInformation.errorDescription` (fspiopErrorDescrForCode) |  |
| `body.Rpt.Rsn.Cd` | `body.errorInformation.errorCode` |  |
| `body.Assgnmt.Assgnr.Agt.FinInstnId.Othr.Id` | `headers.fspiop-source` |  |
| `body.Assgnmt.Assgne.Agt.FinInstnId.Othr.Id` | `headers.fspiop-destination` |  |

### POST /quotes

- Schema: `TermsRequest_FIToFICustomerCreditProposal`
- Payload viewer: [POST /quotes](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/quotes/Quotes)
- Definition: [api_spec.yaml, line 1134](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1134)
- Structure: [Customer credit transfer](#customer-credit-transfer)

Fields the hub reads:

| Element | The hub reads it as | Meaning |
|---|---|---|
| `body.CdtTrfTxInf.PmtId.TxId` | `body.quoteId` | TransactionIdentification: Unique identification, as assigned by the first instructing agent, to unambiguously identify the transaction that is passed on, unchanged, throughout the entire interbank chain. FSPIOP equivalent: quoteId in quote request, transferId in transfer request. |
| `body.GrpHdr.PmtInstrXpryDtTm` | `body.expiration` | Payment Instruction Expiry Date and Time |
| `body.CdtTrfTxInf.PmtId.EndToEndId` | `body.transactionId` | EndToEndIdentification: Unique identification, as assigned by the initiating party, to unambiguously identify the transaction. FSPIOP equivalent: transactionId. |
| `body.CdtTrfTxInf.PmtId.InstrId` | `body.transactionRequestId` | InstructionIdentification: Unique identification, as assigned by an instructing party for an instructed party, to unambiguously identify the instruction. FSPIOP equivalent: transactionRequestId. |
| `body.CdtTrfTxInf.Cdtr.Id.OrgId.Othr.SchmeNm.Prtry` or `body.CdtTrfTxInf.Cdtr.Id.PrvtId.Othr.SchmeNm.Prtry` | `body.payee.partyIdInfo.partyIdType` |  |
| `body.CdtTrfTxInf.Cdtr.Id.OrgId.Othr.Id` or `body.CdtTrfTxInf.Cdtr.Id.PrvtId.Othr.Id` | `body.payee.partyIdInfo.partyIdentifier` |  |
| `body.CdtTrfTxInf.CdtrAgt.FinInstnId.ClrSysMmbId.MmbId` | `body.payee.partyIdInfo.partySubIdOrType` | MemberIdentification: Identification of a member of a clearing system. |
| `body.CdtTrfTxInf.CdtrAgt.FinInstnId.Othr.Id` | `body.payee.partyIdInfo.fspId` | Identification: Unique and unambiguous identification of a person. |
| `body.CdtTrfTxInf.Cdtr.Nm` | `body.payee.name` (getDisplayNameFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.CdtTrfTxInf.Cdtr.Nm` | `body.payee.personalInfo.complexName.firstName` (getFirstFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.CdtTrfTxInf.Cdtr.Nm` | `body.payee.personalInfo.complexName.middleName` (getMiddleFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.CdtTrfTxInf.Cdtr.Nm` | `body.payee.personalInfo.complexName.lastName` (getLastFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.CdtTrfTxInf.CdtrAcct.Ccy` | `body.payee.supportedCurrencies` (toArray) | Currency: Identification of the currency in which the account is held. |
| `body.CdtTrfTxInf.Dbtr.Id.OrgId.Othr.SchmeNm.Prtry` or `body.CdtTrfTxInf.Dbtr.Id.PrvtId.Othr.SchmeNm.Prtry` | `body.payer.partyIdInfo.partyIdType` |  |
| `body.CdtTrfTxInf.Dbtr.Id.OrgId.Othr.Id` or `body.CdtTrfTxInf.Dbtr.Id.PrvtId.Othr.Id` | `body.payer.partyIdInfo.partyIdentifier` |  |
| `body.CdtTrfTxInf.DbtrAgt.FinInstnId.ClrSysMmbId.MmbId` | `body.payer.partyIdInfo.partySubIdOrType` | MemberIdentification: Identification of a member of a clearing system. |
| `body.CdtTrfTxInf.DbtrAgt.FinInstnId.Othr.Id` | `body.payer.partyIdInfo.fspId` | Identification: Unique and unambiguous identification of a person. |
| `body.CdtTrfTxInf.Dbtr.Nm` | `body.payer.name` (getDisplayNameFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.CdtTrfTxInf.Dbtr.Nm` | `body.payer.personalInfo.complexName.firstName` (getFirstFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.CdtTrfTxInf.Dbtr.Nm` | `body.payer.personalInfo.complexName.middleName` (getMiddleFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.CdtTrfTxInf.Dbtr.Nm` | `body.payer.personalInfo.complexName.lastName` (getLastFromDelimitedName) | Name: Name by which a party is known and which is usually used to identify that party. |
| `body.CdtTrfTxInf.DbtrAcct.Ccy` | `body.payer.supportedCurrencies` (toArray) | Currency: Identification of the currency in which the account is held. |
| `body.CdtTrfTxInf.IntrBkSttlmAmt.Ccy` | `body.amount.currency` | Currency: Identification of the currency in which the account is held. |
| `body.CdtTrfTxInf.IntrBkSttlmAmt.ActiveCurrencyAndAmount` | `body.amount.amount` |  |
| `body.CdtTrfTxInf.Purp.Prtry` | `body.transactionType.scenario` |  |
| `body.CdtTrfTxInf.PmtId.InstrId` | `body.transactionType.refundInfo.originalTransactionId` | InstructionIdentification: Unique identification, as assigned by an instructing party for an instructed party, to unambiguously identify the instruction. FSPIOP equivalent: transactionRequestId. |

### PUT /quotes/{ID}

- Schema: `TermsResponse_FIToFICustomerCreditConfirmation`
- Payload viewer: [PUT /quotes/{ID}](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/quotes/QuotesByID1)
- Definition: [api_spec.yaml, line 1222](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1222)
- Structure: [Customer credit transfer](#customer-credit-transfer)

Fields the hub reads:

| Element | The hub reads it as | Meaning |
|---|---|---|
| `body.CdtTrfTxInf.PmtId.TxId` | `params.ID` | TransactionIdentification: Unique identification, as assigned by the first instructing agent, to unambiguously identify the transaction that is passed on, unchanged, throughout the entire interbank chain. FSPIOP equivalent: quoteId in quote request, transferId in transfer request. |
| `body.CdtTrfTxInf.Dbtr.Id.OrgId.Othr.Id` | `headers.fspiop-destination` |  |
| `body.CdtTrfTxInf.Cdtr.Id.OrgId.Othr.Id` | `headers.fspiop-source` |  |
| `body.GrpHdr.PmtInstrXpryDtTm` | `body.expiration` | Payment Instruction Expiry Date and Time |
| `body.CdtTrfTxInf.IntrBkSttlmAmt.Ccy` | `body.transferAmount.currency` | Currency: Identification of the currency in which the account is held. |
| `body.CdtTrfTxInf.IntrBkSttlmAmt.ActiveCurrencyAndAmount` | `body.transferAmount.amount` |  |
| `body.CdtTrfTxInf.InstdAmt.Ccy` | `body.payeeReceiveAmount.currency` | Currency: Identification of the currency in which the account is held. |
| `body.CdtTrfTxInf.InstdAmt.ActiveOrHistoricCurrencyAndAmount` | `body.payeeReceiveAmount.amount` | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `body.CdtTrfTxInf.ChrgsInf.Amt.Ccy` | `body.payeeFspFee.currency` | Currency: Identification of the currency in which the account is held. |
| `body.CdtTrfTxInf.ChrgsInf.Amt.ActiveOrHistoricCurrencyAndAmount` | `body.payeeFspFee.amount` | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `body.CdtTrfTxInf.VrfctnOfTerms.IlpV4PrepPacket` | `body.ilpPacket` | Interledger Protocol packet (ILPv4) containing Cryptographically signed terms |
| `body.CdtTrfTxInf.VrfctnOfTerms.IlpV4PrepPacket` | `body.condition` (ilpPacketToCondition) | Interledger Protocol packet (ILPv4) containing Cryptographically signed terms |

### PUT /quotes/{ID}/error

- Schema: `PacsError_FIToFIPaymentStatusReportV15`
- Payload viewer: [PUT /quotes/{ID}/error](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/quotes/QuotesByIDAndError)
- Definition: [api_spec.yaml, line 1261](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1261)
- Structure: [Payment status report](#payment-status-report)

Fields the hub reads:

| Element | The hub reads it as | Meaning |
|---|---|---|
| `body.TxInfAndSts.StsRsnInf.Rsn.Prtry` | `body.errorInformation.errorCode` |  |
| `body.TxInfAndSts.StsRsnInf.AddtlInf` | `body.errorInformation.errorDescription` | AdditionalInformation: Additional information about the status report. |

### POST /transfers

- Schema: `Execute_FIToFICustomerCreditTransferV13`
- Payload viewer: [POST /transfers](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/transfers/transfers)
- Definition: [api_spec.yaml, line 1473](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1473)
- Structure: [Customer credit transfer](#customer-credit-transfer)

Fields the hub reads:

| Element | The hub reads it as | Meaning |
|---|---|---|
| `body.GrpHdr.PmtInstrXpryDtTm` | `body.expiration` | Payment Instruction Expiry Date and Time |
| `body.CdtTrfTxInf.PmtId.TxId` | `body.transferId` | TransactionIdentification: Unique identification, as assigned by the first instructing agent, to unambiguously identify the transaction that is passed on, unchanged, throughout the entire interbank chain. FSPIOP equivalent: quoteId in quote request, transferId in transfer request. |
| `body.CdtTrfTxInf.CdtrAgt.FinInstnId.Othr.Id` | `body.payeeFsp` | Identification: Unique and unambiguous identification of a person. |
| `body.CdtTrfTxInf.DbtrAgt.FinInstnId.Othr.Id` | `body.payerFsp` | Identification: Unique and unambiguous identification of a person. |
| `body.CdtTrfTxInf.IntrBkSttlmAmt.Ccy` | `body.amount.currency` | Currency: Identification of the currency in which the account is held. |
| `body.CdtTrfTxInf.IntrBkSttlmAmt.ActiveCurrencyAndAmount` | `body.amount.amount` |  |
| `body.CdtTrfTxInf.VrfctnOfTerms.IlpV4PrepPacket` | `body.ilpPacket` | Interledger Protocol packet (ILPv4) containing Cryptographically signed terms |
| `body.CdtTrfTxInf.VrfctnOfTerms.IlpV4PrepPacket` | `body.condition` (ilpPacketToCondition) | Interledger Protocol packet (ILPv4) containing Cryptographically signed terms |

### PUT /transfers/{ID}

- Schema: `PacsStatus_FIToFIPaymentStatusReportV15`
- Payload viewer: [PUT /transfers/{ID}](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/transfers/TransfersByIDPut)
- Definition: [api_spec.yaml, line 1603](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1603)
- Structure: [Payment status report](#payment-status-report)

Fields the hub reads:

| Element | The hub reads it as | Meaning |
|---|---|---|
| `body.TxInfAndSts.ExctnConf` | `body.fulfilment` | Unique reference, as assigned by the account servicing institution, to unambiguously identify the confirmation. |
| `body.TxInfAndSts.PrcgDt.DtTm` | `body.completedTimestamp` |  |
| `body.TxInfAndSts.TxSts` | `body.transferState` (toFspiopTransferState) | Specifies the status of the transaction. |

### PATCH /transfers/{ID}

- Schema: `PacsStatus_FIToFIPaymentStatusReportV15`
- Payload viewer: [PATCH /transfers/{ID}](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/transfers/TransfersByIDPatch)
- Definition: [api_spec.yaml, line 1563](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1563)
- Structure: [Payment status report](#payment-status-report)

Fields the hub reads:

| Element | The hub reads it as | Meaning |
|---|---|---|
| `body.TxInfAndSts.PrcgDt.DtTm` | `body.completedTimestamp` |  |
| `body.TxInfAndSts.TxSts` | `body.transferState` (toFspiopTransferState) | Specifies the status of the transaction. |

### PUT /transfers/{ID}/error

- Schema: `PacsError_FIToFIPaymentStatusReportV15`
- Payload viewer: [PUT /transfers/{ID}/error](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/transfers/TransfersByIDAndError)
- Definition: [api_spec.yaml, line 1642](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1642)
- Structure: [Payment status report](#payment-status-report)

Fields the hub reads:

| Element | The hub reads it as | Meaning |
|---|---|---|
| `body.TxInfAndSts.StsRsnInf.Rsn.Prtry` | `body.errorInformation.errorCode` |  |
| `body.TxInfAndSts.StsRsnInf.AddtlInf` | `body.errorInformation.errorDescription` | AdditionalInformation: Additional information about the status report. |

## Structures

### Party report

Used by: `GetParties_IdentificationVerificationReportV03`, `GetPartiesError_IdentificationVerificationReportV03`.

232 elements.

| Path | Type | Required | Constraints | Meaning |
|---|---|---|---|---|
| `Assgnmt` | object | Yes |  | Assignment: Identifies the identification assignment. |
| `Assgnmt.MsgId` | string | Yes | min length 1; max length 35 | MessageIdentification: Unique identification, as assigned by the assigner, to unambiguously identify the message. |
| `Assgnmt.CreDtTm` | string | Yes | pattern: see spec | CreationDateTime: Date and time at which the identification assignment was created. |
| `Assgnmt.Assgnr` | choice | Yes |  | Assignor: Party that assigns the identification assignment to another party. |
| `Assgnmt.Assgne` | choice | Yes |  | Assignee: Party that the identification assignment is assigned to. |
| `Rpt` | object | Yes |  | Report: Information concerning the verification of the identification data for which verification was requested. |
| `Rpt.OrgnlId` | string | Yes | min length 1; max length 35 | OriginalIdentification: Unique identification, as assigned by a sending party, to unambiguously identify the party and account identification information group within the original message. |
| `Rpt.Vrfctn` | boolean | Yes |  | Verification: Identifies whether the party and/or account information received is correct. |
| `Rpt.Rsn` | choice | No |  | Reason: Specifies the reason why the verified identification information is incorrect. |
| `Rpt.OrgnlPtyAndAcctId` | object | No |  | OriginalPartyAndAccountIdentification: Provides party and/or account identification information as given in the original message. |
| `Rpt.OrgnlPtyAndAcctId.Pty` | object | Yes |  | Party: Account owner that owes an amount of money or to whom an amount of money is due. |
| `Rpt.OrgnlPtyAndAcctId.Pty.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.StrtNm` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.BldgNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.TwnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.DstrctNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `Rpt.OrgnlPtyAndAcctId.Pty.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Pty.Id` | choice | Yes |  | Identification: Unique and unambiguous way to identify an organisation. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtryOfRes` | string | No | pattern `^[A-Z]{2,2}$` | CountryOfResidence: Country in which a person resides (the place of a person's home). |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls` | object | No |  | ContactDetails: Set of elements used to indicate how to contact the party. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.NmPrfx` | string | No | one of `DOCT`, `MADM`, `MISS`, `MIST`, `MIKS` | NamePrefix: Name prefix to be used before the name of the person. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.PhneNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | PhoneNumber: Collection of information that identifies a phone number, as defined by telecom services. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.MobNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | MobilePhoneNumber: Collection of information that identifies a mobile phone number, as defined by telecom services. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.FaxNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | FaxNumber: Collection of information that identifies a fax number, as defined by telecom services. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.EmailAdr` | string | No | min length 1; max length 2048 | EmailAddress: Address for electronic mail (e-mail). |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.EmailPurp` | string | No | min length 1; max length 35 | EmailPurpose: Purpose for which an email address may be used. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.JobTitl` | string | No | min length 1; max length 35 | JobTitle: Title of the function. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.Rspnsblty` | string | No | min length 1; max length 35 | Responsibility: Role of a person in an organisation. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.Dept` | string | No | min length 1; max length 70 | Department: Identification of a division of a large organisation or building. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.Othr` | object | No |  | Other: Contact details in another form. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.Othr.ChanlTp` | string | Yes | min length 1; max length 4 | ChannelType: Method used to contact the financial institution's contact for the specific tax region. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.Othr.Id` | string | No | min length 1; max length 128 | Identifier: Communication value such as phone number or email address. |
| `Rpt.OrgnlPtyAndAcctId.Pty.CtctDtls.PrefrdMtd` | string | No | one of `LETT`, `MAIL`, `PHON`, `FAXX`, `CELL` | PreferredMethod: Preferred method used to reach the contact. |
| `Rpt.OrgnlPtyAndAcctId.Acct` | object | No |  | Account: Unambiguous identification of the account of a party. |
| `Rpt.OrgnlPtyAndAcctId.Acct.Id` | choice | No |  | Identification: Unique and unambiguous identification for the account between the account owner and the account servicer. |
| `Rpt.OrgnlPtyAndAcctId.Acct.Tp` | choice | No |  | Type: Specifies the nature, or use of the account. |
| `Rpt.OrgnlPtyAndAcctId.Acct.Ccy` | string | No | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `Rpt.OrgnlPtyAndAcctId.Acct.Nm` | string | No | min length 1; max length 70 | Name: Name of the account, as assigned by the account servicing institution, in agreement with the account owner in order to provide an additional means of identification of the account. |
| `Rpt.OrgnlPtyAndAcctId.Acct.Prxy` | object | No |  | Proxy: Specifies an alternate assumed name for the identification of the account. |
| `Rpt.OrgnlPtyAndAcctId.Acct.Prxy.Tp` | choice | No |  | Type: Type of the proxy identification. |
| `Rpt.OrgnlPtyAndAcctId.Acct.Prxy.Id` | string | Yes | min length 1; max length 2048 | Identification: Identification used to indicate the account identification under another specified name. |
| `Rpt.OrgnlPtyAndAcctId.Agt` | object | No |  | Agent: Financial institution servicing an account for a party. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId` | object | Yes |  | FinancialInstitutionIdentification: Unique and unambiguous identification of a financial institution, as assigned under an internationally recognised or proprietary identification scheme. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.BICFI` | string | No | pattern `^[A-Z0-9]{4,4}[A-Z]{2,2}[A-Z0-9]{2,2}([A-Z0-9]{3,3}){0,1}$` | BICFI: Code allocated to a financial institution by the ISO 9362 Registration Authority as described in ISO 9362 "Banking - Banking telecommunication messages - Business identifier code (BIC)" |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.ClrSysMmbId` | object | No |  | ClearingSystemMemberIdentification: Information used to identify a member within a clearing system |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.ClrSysMmbId.ClrSysId` | choice | No |  | ClearingSystemIdentification: Specification of a pre-agreed offering between clearing agents or the channel through which the payment instruction is processed. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.ClrSysMmbId.MmbId` | string | Yes | min length 1; max length 35 | MemberIdentification: Identification of a member of a clearing system. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identifier of the financial institution. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.StrtNm` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.BldgNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.TwnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.DstrctNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.Othr` | object | No |  | Other: Unique identification of an agent, as assigned by an institution, using an identification scheme. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.Othr.Id` | string | Yes | min length 1; max length 35 | Identification: Unique and unambiguous identification of a person. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.Othr.SchmeNm` | choice | No |  | SchemeName: Name of the identification scheme. |
| `Rpt.OrgnlPtyAndAcctId.Agt.FinInstnId.Othr.Issr` | string | No | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId` | object | No |  | BranchIdentification: Identifies a specific branch of a financial institution. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.Id` | string | No | min length 1; max length 35 | Identification: Unique and unambiguous identification of a branch of a financial institution. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | Legal Entity Identifier: Legal entity identification for the branch of the financial institution. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr` | object | No |  | Postal Address: Information that locates and identifies a specific address, as defined by postal services. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.StrtNm` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.BldgNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.TwnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.DstrctNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `Rpt.OrgnlPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId` | object | No |  | UpdatedPartyAndAccountIdentification: Provides party and/or account identification information. |
| `Rpt.UpdtdPtyAndAcctId.Pty` | object | Yes |  | Party: Account owner that owes an amount of money or to whom an amount of money is due. |
| `Rpt.UpdtdPtyAndAcctId.Pty.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.StrtNm` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.BldgNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.TwnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.DstrctNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `Rpt.UpdtdPtyAndAcctId.Pty.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Pty.Id` | choice | Yes |  | Identification: Unique and unambiguous way to identify an organisation. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtryOfRes` | string | No | pattern `^[A-Z]{2,2}$` | CountryOfResidence: Country in which a person resides (the place of a person's home). |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls` | object | No |  | ContactDetails: Set of elements used to indicate how to contact the party. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.NmPrfx` | string | No | one of `DOCT`, `MADM`, `MISS`, `MIST`, `MIKS` | NamePrefix: Name prefix to be used before the name of the person. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.PhneNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | PhoneNumber: Collection of information that identifies a phone number, as defined by telecom services. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.MobNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | MobilePhoneNumber: Collection of information that identifies a mobile phone number, as defined by telecom services. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.FaxNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | FaxNumber: Collection of information that identifies a fax number, as defined by telecom services. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.EmailAdr` | string | No | min length 1; max length 2048 | EmailAddress: Address for electronic mail (e-mail). |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.EmailPurp` | string | No | min length 1; max length 35 | EmailPurpose: Purpose for which an email address may be used. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.JobTitl` | string | No | min length 1; max length 35 | JobTitle: Title of the function. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.Rspnsblty` | string | No | min length 1; max length 35 | Responsibility: Role of a person in an organisation. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.Dept` | string | No | min length 1; max length 70 | Department: Identification of a division of a large organisation or building. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.Othr` | object | No |  | Other: Contact details in another form. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.Othr.ChanlTp` | string | Yes | min length 1; max length 4 | ChannelType: Method used to contact the financial institution's contact for the specific tax region. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.Othr.Id` | string | No | min length 1; max length 128 | Identifier: Communication value such as phone number or email address. |
| `Rpt.UpdtdPtyAndAcctId.Pty.CtctDtls.PrefrdMtd` | string | No | one of `LETT`, `MAIL`, `PHON`, `FAXX`, `CELL` | PreferredMethod: Preferred method used to reach the contact. |
| `Rpt.UpdtdPtyAndAcctId.Acct` | object | No |  | Account: Unambiguous identification of the account of a party. |
| `Rpt.UpdtdPtyAndAcctId.Acct.Id` | choice | No |  | Identification: Unique and unambiguous identification for the account between the account owner and the account servicer. |
| `Rpt.UpdtdPtyAndAcctId.Acct.Tp` | choice | No |  | Type: Specifies the nature, or use of the account. |
| `Rpt.UpdtdPtyAndAcctId.Acct.Ccy` | string | No | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `Rpt.UpdtdPtyAndAcctId.Acct.Nm` | string | No | min length 1; max length 70 | Name: Name of the account, as assigned by the account servicing institution, in agreement with the account owner in order to provide an additional means of identification of the account. |
| `Rpt.UpdtdPtyAndAcctId.Acct.Prxy` | object | No |  | Proxy: Specifies an alternate assumed name for the identification of the account. |
| `Rpt.UpdtdPtyAndAcctId.Acct.Prxy.Tp` | choice | No |  | Type: Type of the proxy identification. |
| `Rpt.UpdtdPtyAndAcctId.Acct.Prxy.Id` | string | Yes | min length 1; max length 2048 | Identification: Identification used to indicate the account identification under another specified name. |
| `Rpt.UpdtdPtyAndAcctId.Agt` | object | No |  | Agent: Financial institution servicing an account for a party. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId` | object | Yes |  | FinancialInstitutionIdentification: Unique and unambiguous identification of a financial institution, as assigned under an internationally recognised or proprietary identification scheme. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.BICFI` | string | No | pattern `^[A-Z0-9]{4,4}[A-Z]{2,2}[A-Z0-9]{2,2}([A-Z0-9]{3,3}){0,1}$` | BICFI: Code allocated to a financial institution by the ISO 9362 Registration Authority as described in ISO 9362 "Banking - Banking telecommunication messages - Business identifier code (BIC)" |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.ClrSysMmbId` | object | No |  | ClearingSystemMemberIdentification: Information used to identify a member within a clearing system |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.ClrSysMmbId.ClrSysId` | choice | No |  | ClearingSystemIdentification: Specification of a pre-agreed offering between clearing agents or the channel through which the payment instruction is processed. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.ClrSysMmbId.MmbId` | string | Yes | min length 1; max length 35 | MemberIdentification: Identification of a member of a clearing system. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identifier of the financial institution. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.StrtNm` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.BldgNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.TwnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.DstrctNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.Othr` | object | No |  | Other: Unique identification of an agent, as assigned by an institution, using an identification scheme. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.Othr.Id` | string | Yes | min length 1; max length 35 | Identification: Unique and unambiguous identification of a person. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.Othr.SchmeNm` | choice | No |  | SchemeName: Name of the identification scheme. |
| `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.Othr.Issr` | string | No | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId` | object | No |  | BranchIdentification: Identifies a specific branch of a financial institution. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.Id` | string | No | min length 1; max length 35 | Identification: Unique and unambiguous identification of a branch of a financial institution. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | Legal Entity Identifier: Legal entity identification for the branch of the financial institution. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr` | object | No |  | Postal Address: Information that locates and identifies a specific address, as defined by postal services. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.StrtNm` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.BldgNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.TwnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.DstrctNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `Rpt.UpdtdPtyAndAcctId.Agt.BrnchId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `SplmtryData` | object | No |  | SupplementaryData: Additional information that cannot be captured in the structured elements and/or any other specific block. |
| `SplmtryData.PlcAndNm` | string | No | min length 1; max length 350 | PlaceAndName: Unambiguous reference to the location where the supplementary data must be inserted in the message instance. |
| `SplmtryData.Envlp` | object | Yes |  | Envelope: Technical element wrapping the supplementary data. |

### Customer credit transfer

Used by: `TermsRequest_FIToFICustomerCreditProposal`, `TermsResponse_FIToFICustomerCreditConfirmation`, `Execute_FIToFICustomerCreditTransferV13`.

688 elements.

| Path | Type | Required | Constraints | Meaning |
|---|---|---|---|---|
| `GrpHdr` | object | Yes |  | Group Header: Set of characteristics shared by all individual transactions included in the message. |
| `GrpHdr.MsgId` | string | Yes | min length 1; max length 35 | Message Identification |
| `GrpHdr.CreDtTm` | string | Yes | pattern: see spec | Creation Date and Time |
| `GrpHdr.PmtInstrXpryDtTm` | string | No | pattern: see spec | Payment Instruction Expiry Date and Time |
| `GrpHdr.NbOfTxs` | string | Yes | pattern `^[0-9]{1,15}$` | Number of Transactions |
| `GrpHdr.SttlmInf` | object | Yes |  | Settlement Information |
| `GrpHdr.SttlmInf.SttlmMtd` | string | Yes | one of `INDA`, `INGA`, `COVE`, `CLRG` | Specifies the method used to settle the credit transfer instruction.: INDA: Indirect Account INGA: Indirect Agent COVE: Cover CLRG: Clearing |
| `GrpHdr.SttlmInf.PmtTpInf` | object | No |  | Provides further details of the type of payment. |
| `GrpHdr.SttlmInf.PmtTpInf.InstrPrty` | string | No | one of `HIGH`, `NORM` | Indicator of the urgency or order of importance that the instructing party: would like the instructed party to apply to the processing of the instruction. |
| `GrpHdr.SttlmInf.PmtTpInf.ClrChanl` | string | No | one of `RTGS`, `RTNS`, `MPNS`, `BOOK` | Specifies the clearing channel for the routing of the transaction, as part of: the payment type identification. |
| `GrpHdr.SttlmInf.PmtTpInf.SvcLvl` | choice | No |  | ServiceLevel: Agreement under which or rules under which the transaction should be processed. |
| `GrpHdr.SttlmInf.PmtTpInf.LclInstrm` | choice | No |  | LocalInstrument: User community specific instrument. |
| `GrpHdr.SttlmInf.PmtTpInf.CtgyPurp` | choice | No |  | CategoryPurpose: Specifies the high level purpose of the instruction based on a set of pre-defined categories. |
| `CdtTrfTxInf` | object | Yes |  | Credit Transfer Transaction Information |
| `CdtTrfTxInf.PmtId` | object | Yes |  | PaymentIdentification: Set of elements used to reference a payment instruction. |
| `CdtTrfTxInf.PmtId.InstrId` | string | No | pattern `^[0-9A-HJKMNP-TV-Z]{26}$` | InstructionIdentification: Unique identification, as assigned by an instructing party for an instructed party, to unambiguously identify the instruction. FSPIOP equivalent: transactionRequestId. |
| `CdtTrfTxInf.PmtId.EndToEndId` | string | No | pattern `^[0-9A-HJKMNP-TV-Z]{26}$` | EndToEndIdentification: Unique identification, as assigned by the initiating party, to unambiguously identify the transaction. FSPIOP equivalent: transactionId. |
| `CdtTrfTxInf.PmtId.TxId` | string | Yes | pattern `^[0-9A-HJKMNP-TV-Z]{26}$` | TransactionIdentification: Unique identification, as assigned by the first instructing agent, to unambiguously identify the transaction that is passed on, unchanged, throughout the entire interbank chain. FSPIOP equivalent: quoteId in quote request, transferId in transfer request. |
| `CdtTrfTxInf.PmtId.UETR` | string | No | pattern: see spec | UETR: Universally unique identifier to provide an end-to-end reference of a payment transaction. |
| `CdtTrfTxInf.PmtId.ClrSysRef` | string | No | min length 1; max length 35 | ClearingSystemReference: Unique reference, as assigned by a clearing system, to unambiguously identify the instruction. |
| `CdtTrfTxInf.PmtTpInf` | object | No |  | PaymentTypeInformation: Set of elements used to further specify the type of transaction. |
| `CdtTrfTxInf.PmtTpInf.InstrPrty` | string | No | one of `HIGH`, `NORM` | Indicator of the urgency or order of importance that the instructing party: would like the instructed party to apply to the processing of the instruction. |
| `CdtTrfTxInf.PmtTpInf.ClrChanl` | string | No | one of `RTGS`, `RTNS`, `MPNS`, `BOOK` | Specifies the clearing channel for the routing of the transaction, as part of: the payment type identification. |
| `CdtTrfTxInf.PmtTpInf.SvcLvl` | choice | No |  | ServiceLevel: Agreement under which or rules under which the transaction should be processed. |
| `CdtTrfTxInf.PmtTpInf.LclInstrm` | choice | No |  | LocalInstrument: User community specific instrument. |
| `CdtTrfTxInf.PmtTpInf.CtgyPurp` | choice | No |  | CategoryPurpose: Specifies the high level purpose of the instruction based on a set of pre-defined categories. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf` | object | No |  | Underlying Customer Credit Transfer: TBD |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.InstdAmt` | object | No |  | InstructedAmount: Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.InstdAmt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.InstdAmt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr` | object | Yes |  | Party that owes an amount of money to the (ultimate) creditor. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr` | object | No |  | Postal Address: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.CareOf` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.StrtNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.BldgNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.UnitNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.TwnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.DstrctNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.Id` | choice | Yes |  | Identification: Unique and unambiguous identification of a party. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtryOfRes` | string | No | pattern `^[A-Z]{2,2}$` | Country of Residence: Country in which a person resides (the place of a person's home). |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls` | object | No |  | Contact Details: Set of elements used to indicate how to contact the party. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.NmPrfx` | string | No | one of `DOCT`, `MADM`, `MISS`, `MIST`, `MIKS` | NamePrefix: Specifies the terms used to formally address a person. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.PhneNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | PhoneNumber: Collection of information that identifies a phone number, as defined by telecom services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.MobNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | MobilePhoneNumber: Collection of information that identifies a mobile phone number, as defined by telecom services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.FaxNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | FaxNumber: Collection of information that identifies a fax number, as defined by telecom services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.URLAdr` | string | No | min length 1; max length 2048 | URLAddress: Address for the Universal Resource Locator (URL), for example an address used over the www (HTTP) service. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.EmailAdr` | string | No | min length 1; max length 256 | EmailAddress: Address for electronic mail (e-mail). |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.EmailPurp` | string | No | min length 1; max length 35 | EmailPurpose: Purpose for which an email address may be used. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.JobTitl` | string | No | min length 1; max length 35 | JobTitle: Title of the function. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.Rspnsblty` | string | No | min length 1; max length 35 | Responsibility: Role of a person in an organisation. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.Dept` | string | No | min length 1; max length 70 | Department: Identification of a division of a large organisation or building. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.Othr` | object | No |  | OtherContact: Contact details in another form. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.Othr.ChanlTp` | string | Yes | min length 1; max length 4 | ChannelType: Method used to contact the financial institution's contact for the specific tax region. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.Othr.Id` | string | No | min length 1; max length 128 | Identifier: Communication value such as phone number or email address. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Dbtr.CtctDtls.PrefrdMtd` | string | No | one of `LETT`, `MAIL`, `PHON`, `FAXX`, `CELL` | PreferredContactMethod: Preferred method used to reach the contact. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr` | object | Yes |  | Party to which an amount of money is due. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr` | object | No |  | Postal Address: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.CareOf` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.StrtNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.BldgNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.UnitNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.TwnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.DstrctNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.Id` | choice | Yes |  | Identification: Unique and unambiguous identification of a party. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtryOfRes` | string | No | pattern `^[A-Z]{2,2}$` | Country of Residence: Country in which a person resides (the place of a person's home). |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls` | object | No |  | Contact Details: Set of elements used to indicate how to contact the party. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.NmPrfx` | string | No | one of `DOCT`, `MADM`, `MISS`, `MIST`, `MIKS` | NamePrefix: Specifies the terms used to formally address a person. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.PhneNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | PhoneNumber: Collection of information that identifies a phone number, as defined by telecom services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.MobNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | MobilePhoneNumber: Collection of information that identifies a mobile phone number, as defined by telecom services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.FaxNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | FaxNumber: Collection of information that identifies a fax number, as defined by telecom services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.URLAdr` | string | No | min length 1; max length 2048 | URLAddress: Address for the Universal Resource Locator (URL), for example an address used over the www (HTTP) service. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.EmailAdr` | string | No | min length 1; max length 256 | EmailAddress: Address for electronic mail (e-mail). |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.EmailPurp` | string | No | min length 1; max length 35 | EmailPurpose: Purpose for which an email address may be used. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.JobTitl` | string | No | min length 1; max length 35 | JobTitle: Title of the function. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.Rspnsblty` | string | No | min length 1; max length 35 | Responsibility: Role of a person in an organisation. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.Dept` | string | No | min length 1; max length 70 | Department: Identification of a division of a large organisation or building. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.Othr` | object | No |  | OtherContact: Contact details in another form. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.Othr.ChanlTp` | string | Yes | min length 1; max length 4 | ChannelType: Method used to contact the financial institution's contact for the specific tax region. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.Othr.Id` | string | No | min length 1; max length 128 | Identifier: Communication value such as phone number or email address. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.Cdtr.CtctDtls.PrefrdMtd` | string | No | one of `LETT`, `MAIL`, `PHON`, `FAXX`, `CELL` | PreferredContactMethod: Preferred method used to reach the contact. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt` | object | Yes |  | Financial institution servicing an account for the debtor. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId` | object | Yes |  | FinancialInstitutionIdentification: Unique and unambiguous identification of a financial institution or a branch of a financial institution. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.BICFI` | string | No | pattern `^[A-Z0-9]{4,4}[A-Z]{2,2}[A-Z0-9]{2,2}([A-Z0-9]{3,3}){0,1}$` | BICFI: Code allocated to a financial institution by the ISO 9362 Registration Authority as described in ISO 9362 "Banking - Banking telecommunication messages - Business identifier code (BIC)" |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.ClrSysMmbId` | object | No |  | ClearingSystemMemberIdentification: Information used to identify a member within a clearing system |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.ClrSysMmbId.ClrSysId` | choice | No |  | ClearingSystemIdentification: Specification of a pre-agreed offering between clearing agents or the channel through which the payment instruction is processed. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.ClrSysMmbId.MmbId` | string | Yes | min length 1; max length 35 | MemberIdentification: Identification of a member of a clearing system. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identifier of the financial institution. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.StrtNm` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.BldgNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.TwnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.DstrctNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.Othr` | object | No |  | Other: Unique identification of an agent, as assigned by an institution, using an identification scheme. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.Othr.Id` | string | Yes | min length 1; max length 35 | Identification: Unique and unambiguous identification of a person. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.Othr.SchmeNm` | choice | No |  | SchemeName: Name of the identification scheme. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.FinInstnId.Othr.Issr` | string | No | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId` | object | No |  | BranchIdentification: Identifies a specific branch of a financial institution. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.Id` | string | No | min length 1; max length 35 | Identification: Unique and unambiguous identification of a branch of a financial institution. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identification for the branch of the financial institution. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.CareOf` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.StrtNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.BldgNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.UnitNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.TwnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.DstrctNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.DbtrAgt.BrnchId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt` | object | Yes |  | Financial institution servicing an account for the creditor. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId` | object | Yes |  | FinancialInstitutionIdentification: Unique and unambiguous identification of a financial institution or a branch of a financial institution. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.BICFI` | string | No | pattern `^[A-Z0-9]{4,4}[A-Z]{2,2}[A-Z0-9]{2,2}([A-Z0-9]{3,3}){0,1}$` | BICFI: Code allocated to a financial institution by the ISO 9362 Registration Authority as described in ISO 9362 "Banking - Banking telecommunication messages - Business identifier code (BIC)" |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.ClrSysMmbId` | object | No |  | ClearingSystemMemberIdentification: Information used to identify a member within a clearing system |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.ClrSysMmbId.ClrSysId` | choice | No |  | ClearingSystemIdentification: Specification of a pre-agreed offering between clearing agents or the channel through which the payment instruction is processed. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.ClrSysMmbId.MmbId` | string | Yes | min length 1; max length 35 | MemberIdentification: Identification of a member of a clearing system. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identifier of the financial institution. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.StrtNm` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.BldgNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.TwnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.DstrctNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.Othr` | object | No |  | Other: Unique identification of an agent, as assigned by an institution, using an identification scheme. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.Othr.Id` | string | Yes | min length 1; max length 35 | Identification: Unique and unambiguous identification of a person. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.Othr.SchmeNm` | choice | No |  | SchemeName: Name of the identification scheme. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.FinInstnId.Othr.Issr` | string | No | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId` | object | No |  | BranchIdentification: Identifies a specific branch of a financial institution. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.Id` | string | No | min length 1; max length 35 | Identification: Unique and unambiguous identification of a branch of a financial institution. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identification for the branch of the financial institution. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.CareOf` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.StrtNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.BldgNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.UnitNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.TwnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.DstrctNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.UndrlygCstmrCdtTrf.CdtrAgt.BrnchId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.IntrBkSttlmAmt` | object | Yes |  | InterbankSettlementAmount: Amount of money moved between the instructing agent and the instructed agent. |
| `CdtTrfTxInf.IntrBkSttlmAmt.ActiveCurrencyAndAmount` | string | Yes | pattern: see spec |  |
| `CdtTrfTxInf.IntrBkSttlmAmt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.InstdAmt` | object | No |  | InstructedAmount: Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.InstdAmt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.InstdAmt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.XchgRate` | string | No | pattern: see spec | ExchangeRate: Factor used to convert an amount from one currency into another. |
| `CdtTrfTxInf.ChrgBr` | string | Yes | one of `DEBT`, `CRED`, `SHAR` | Specifies which party(ies) will pay charges due for processing of the: instruction. |
| `CdtTrfTxInf.ChrgsInf` | object | No |  | ChargesInformation: Provides information on the charges to be paid by the charge bearer(s) related to the payment transaction. |
| `CdtTrfTxInf.ChrgsInf.Amt` | object | Yes |  | Amount: Transaction charges to be paid by the charge bearer. |
| `CdtTrfTxInf.ChrgsInf.Amt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.ChrgsInf.Amt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.ChrgsInf.Agt` | object | Yes |  | Agent: Agent that takes the transaction charges or to which the transaction charges are due. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId` | object | Yes |  | FinancialInstitutionIdentification: Unique and unambiguous identification of a financial institution or a branch of a financial institution. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.BICFI` | string | No | pattern `^[A-Z0-9]{4,4}[A-Z]{2,2}[A-Z0-9]{2,2}([A-Z0-9]{3,3}){0,1}$` | BICFI: Code allocated to a financial institution by the ISO 9362 Registration Authority as described in ISO 9362 "Banking - Banking telecommunication messages - Business identifier code (BIC)" |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.ClrSysMmbId` | object | No |  | ClearingSystemMemberIdentification: Information used to identify a member within a clearing system |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.ClrSysMmbId.ClrSysId` | choice | No |  | ClearingSystemIdentification: Specification of a pre-agreed offering between clearing agents or the channel through which the payment instruction is processed. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.ClrSysMmbId.MmbId` | string | Yes | min length 1; max length 35 | MemberIdentification: Identification of a member of a clearing system. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identifier of the financial institution. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.StrtNm` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.BldgNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.TwnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.DstrctNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.Othr` | object | No |  | Other: Unique identification of an agent, as assigned by an institution, using an identification scheme. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.Othr.Id` | string | Yes | min length 1; max length 35 | Identification: Unique and unambiguous identification of a person. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.Othr.SchmeNm` | choice | No |  | SchemeName: Name of the identification scheme. |
| `CdtTrfTxInf.ChrgsInf.Agt.FinInstnId.Othr.Issr` | string | No | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId` | object | No |  | BranchIdentification: Identifies a specific branch of a financial institution. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.Id` | string | No | min length 1; max length 35 | Identification: Unique and unambiguous identification of a branch of a financial institution. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identification for the branch of the financial institution. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.CareOf` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.StrtNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.BldgNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.UnitNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.TwnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.DstrctNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.ChrgsInf.Agt.BrnchId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.ChrgsInf.Tp` | choice | No |  | Type: Defines the type of charges. |
| `CdtTrfTxInf.Dbtr` | object | Yes |  | Debtor: Party that owes an amount of money to the (ultimate) creditor. |
| `CdtTrfTxInf.Dbtr.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `CdtTrfTxInf.Dbtr.PstlAdr` | object | No |  | Postal Address: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.Dbtr.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.Dbtr.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.Dbtr.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.Dbtr.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.Dbtr.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.Dbtr.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.Dbtr.PstlAdr.CareOf` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.StrtNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.BldgNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.UnitNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.TwnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.DstrctNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.Dbtr.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.Dbtr.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.Dbtr.Id` | choice | Yes |  | Identification: Unique and unambiguous identification of a party. |
| `CdtTrfTxInf.Dbtr.CtryOfRes` | string | No | pattern `^[A-Z]{2,2}$` | Country of Residence: Country in which a person resides (the place of a person's home). |
| `CdtTrfTxInf.Dbtr.CtctDtls` | object | No |  | Contact Details: Set of elements used to indicate how to contact the party. |
| `CdtTrfTxInf.Dbtr.CtctDtls.NmPrfx` | string | No | one of `DOCT`, `MADM`, `MISS`, `MIST`, `MIKS` | NamePrefix: Specifies the terms used to formally address a person. |
| `CdtTrfTxInf.Dbtr.CtctDtls.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `CdtTrfTxInf.Dbtr.CtctDtls.PhneNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | PhoneNumber: Collection of information that identifies a phone number, as defined by telecom services. |
| `CdtTrfTxInf.Dbtr.CtctDtls.MobNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | MobilePhoneNumber: Collection of information that identifies a mobile phone number, as defined by telecom services. |
| `CdtTrfTxInf.Dbtr.CtctDtls.FaxNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | FaxNumber: Collection of information that identifies a fax number, as defined by telecom services. |
| `CdtTrfTxInf.Dbtr.CtctDtls.URLAdr` | string | No | min length 1; max length 2048 | URLAddress: Address for the Universal Resource Locator (URL), for example an address used over the www (HTTP) service. |
| `CdtTrfTxInf.Dbtr.CtctDtls.EmailAdr` | string | No | min length 1; max length 256 | EmailAddress: Address for electronic mail (e-mail). |
| `CdtTrfTxInf.Dbtr.CtctDtls.EmailPurp` | string | No | min length 1; max length 35 | EmailPurpose: Purpose for which an email address may be used. |
| `CdtTrfTxInf.Dbtr.CtctDtls.JobTitl` | string | No | min length 1; max length 35 | JobTitle: Title of the function. |
| `CdtTrfTxInf.Dbtr.CtctDtls.Rspnsblty` | string | No | min length 1; max length 35 | Responsibility: Role of a person in an organisation. |
| `CdtTrfTxInf.Dbtr.CtctDtls.Dept` | string | No | min length 1; max length 70 | Department: Identification of a division of a large organisation or building. |
| `CdtTrfTxInf.Dbtr.CtctDtls.Othr` | object | No |  | OtherContact: Contact details in another form. |
| `CdtTrfTxInf.Dbtr.CtctDtls.Othr.ChanlTp` | string | Yes | min length 1; max length 4 | ChannelType: Method used to contact the financial institution's contact for the specific tax region. |
| `CdtTrfTxInf.Dbtr.CtctDtls.Othr.Id` | string | No | min length 1; max length 128 | Identifier: Communication value such as phone number or email address. |
| `CdtTrfTxInf.Dbtr.CtctDtls.PrefrdMtd` | string | No | one of `LETT`, `MAIL`, `PHON`, `FAXX`, `CELL` | PreferredContactMethod: Preferred method used to reach the contact. |
| `CdtTrfTxInf.DbtrAcct` | object | No |  | DebtorAccount: Unambiguous identification of the account of the debtor to which a debit entry will be made as a result of the transaction. |
| `CdtTrfTxInf.DbtrAcct.Id` | choice | No |  | Identification: Unique and unambiguous identification for the account between the account owner and the account servicer. |
| `CdtTrfTxInf.DbtrAcct.Tp` | choice | No |  | Type: Specifies the nature, or use of the account. |
| `CdtTrfTxInf.DbtrAcct.Ccy` | string | No | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.DbtrAcct.Nm` | string | No | min length 1; max length 70 | Name: Name of the account, as assigned by the account servicing institution, in agreement with the account owner in order to provide an additional means of identification of the account. |
| `CdtTrfTxInf.DbtrAcct.Prxy` | object | No |  | Proxy: Specifies an alternate assumed name for the identification of the account. |
| `CdtTrfTxInf.DbtrAcct.Prxy.Tp` | choice | No |  | Type: Type of the proxy identification. |
| `CdtTrfTxInf.DbtrAcct.Prxy.Id` | string | Yes | min length 1; max length 2048 | Identification: Identification used to indicate the account identification under another specified name. |
| `CdtTrfTxInf.DbtrAgt` | object | Yes |  | DebtorAgent: Financial institution servicing an account for the debtor. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId` | object | Yes |  | FinancialInstitutionIdentification: Unique and unambiguous identification of a financial institution or a branch of a financial institution. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.BICFI` | string | No | pattern `^[A-Z0-9]{4,4}[A-Z]{2,2}[A-Z0-9]{2,2}([A-Z0-9]{3,3}){0,1}$` | BICFI: Code allocated to a financial institution by the ISO 9362 Registration Authority as described in ISO 9362 "Banking - Banking telecommunication messages - Business identifier code (BIC)" |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.ClrSysMmbId` | object | No |  | ClearingSystemMemberIdentification: Information used to identify a member within a clearing system |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.ClrSysMmbId.ClrSysId` | choice | No |  | ClearingSystemIdentification: Specification of a pre-agreed offering between clearing agents or the channel through which the payment instruction is processed. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.ClrSysMmbId.MmbId` | string | Yes | min length 1; max length 35 | MemberIdentification: Identification of a member of a clearing system. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identifier of the financial institution. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.StrtNm` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.BldgNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.TwnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.DstrctNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.Othr` | object | No |  | Other: Unique identification of an agent, as assigned by an institution, using an identification scheme. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.Othr.Id` | string | Yes | min length 1; max length 35 | Identification: Unique and unambiguous identification of a person. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.Othr.SchmeNm` | choice | No |  | SchemeName: Name of the identification scheme. |
| `CdtTrfTxInf.DbtrAgt.FinInstnId.Othr.Issr` | string | No | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.DbtrAgt.BrnchId` | object | No |  | BranchIdentification: Identifies a specific branch of a financial institution. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.Id` | string | No | min length 1; max length 35 | Identification: Unique and unambiguous identification of a branch of a financial institution. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identification for the branch of the financial institution. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.CareOf` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.StrtNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.BldgNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.UnitNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.TwnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.DstrctNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.DbtrAgt.BrnchId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.CdtrAgt` | object | Yes |  | CreditorAgent: Financial institution servicing an account for the creditor. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId` | object | Yes |  | FinancialInstitutionIdentification: Unique and unambiguous identification of a financial institution or a branch of a financial institution. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.BICFI` | string | No | pattern `^[A-Z0-9]{4,4}[A-Z]{2,2}[A-Z0-9]{2,2}([A-Z0-9]{3,3}){0,1}$` | BICFI: Code allocated to a financial institution by the ISO 9362 Registration Authority as described in ISO 9362 "Banking - Banking telecommunication messages - Business identifier code (BIC)" |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.ClrSysMmbId` | object | No |  | ClearingSystemMemberIdentification: Information used to identify a member within a clearing system |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.ClrSysMmbId.ClrSysId` | choice | No |  | ClearingSystemIdentification: Specification of a pre-agreed offering between clearing agents or the channel through which the payment instruction is processed. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.ClrSysMmbId.MmbId` | string | Yes | min length 1; max length 35 | MemberIdentification: Identification of a member of a clearing system. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identifier of the financial institution. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.StrtNm` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.BldgNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.TwnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.DstrctNm` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.Othr` | object | No |  | Other: Unique identification of an agent, as assigned by an institution, using an identification scheme. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.Othr.Id` | string | Yes | min length 1; max length 35 | Identification: Unique and unambiguous identification of a person. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.Othr.SchmeNm` | choice | No |  | SchemeName: Name of the identification scheme. |
| `CdtTrfTxInf.CdtrAgt.FinInstnId.Othr.Issr` | string | No | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.CdtrAgt.BrnchId` | object | No |  | BranchIdentification: Identifies a specific branch of a financial institution. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.Id` | string | No | min length 1; max length 35 | Identification: Unique and unambiguous identification of a branch of a financial institution. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.LEI` | string | No | pattern `^[A-Z0-9]{18,18}[0-9]{2,2}$` | LEI: Legal entity identification for the branch of the financial institution. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.Nm` | string | No | min length 1; max length 140 | Name: Name by which an agent is known and which is usually used to identify that agent. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr` | object | No |  | PostalAddress: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.CareOf` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.StrtNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.BldgNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.UnitNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.TwnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.DstrctNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.CdtrAgt.BrnchId.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.Cdtr` | object | Yes |  | Creditor: Party to which an amount of money is due. |
| `CdtTrfTxInf.Cdtr.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `CdtTrfTxInf.Cdtr.PstlAdr` | object | No |  | Postal Address: Information that locates and identifies a specific address, as defined by postal services. |
| `CdtTrfTxInf.Cdtr.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `CdtTrfTxInf.Cdtr.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `CdtTrfTxInf.Cdtr.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `CdtTrfTxInf.Cdtr.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `CdtTrfTxInf.Cdtr.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `CdtTrfTxInf.Cdtr.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `CdtTrfTxInf.Cdtr.PstlAdr.CareOf` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.StrtNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.BldgNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.UnitNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.TwnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.DstrctNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `CdtTrfTxInf.Cdtr.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `CdtTrfTxInf.Cdtr.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `CdtTrfTxInf.Cdtr.Id` | choice | Yes |  | Identification: Unique and unambiguous identification of a party. |
| `CdtTrfTxInf.Cdtr.CtryOfRes` | string | No | pattern `^[A-Z]{2,2}$` | Country of Residence: Country in which a person resides (the place of a person's home). |
| `CdtTrfTxInf.Cdtr.CtctDtls` | object | No |  | Contact Details: Set of elements used to indicate how to contact the party. |
| `CdtTrfTxInf.Cdtr.CtctDtls.NmPrfx` | string | No | one of `DOCT`, `MADM`, `MISS`, `MIST`, `MIKS` | NamePrefix: Specifies the terms used to formally address a person. |
| `CdtTrfTxInf.Cdtr.CtctDtls.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `CdtTrfTxInf.Cdtr.CtctDtls.PhneNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | PhoneNumber: Collection of information that identifies a phone number, as defined by telecom services. |
| `CdtTrfTxInf.Cdtr.CtctDtls.MobNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | MobilePhoneNumber: Collection of information that identifies a mobile phone number, as defined by telecom services. |
| `CdtTrfTxInf.Cdtr.CtctDtls.FaxNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | FaxNumber: Collection of information that identifies a fax number, as defined by telecom services. |
| `CdtTrfTxInf.Cdtr.CtctDtls.URLAdr` | string | No | min length 1; max length 2048 | URLAddress: Address for the Universal Resource Locator (URL), for example an address used over the www (HTTP) service. |
| `CdtTrfTxInf.Cdtr.CtctDtls.EmailAdr` | string | No | min length 1; max length 256 | EmailAddress: Address for electronic mail (e-mail). |
| `CdtTrfTxInf.Cdtr.CtctDtls.EmailPurp` | string | No | min length 1; max length 35 | EmailPurpose: Purpose for which an email address may be used. |
| `CdtTrfTxInf.Cdtr.CtctDtls.JobTitl` | string | No | min length 1; max length 35 | JobTitle: Title of the function. |
| `CdtTrfTxInf.Cdtr.CtctDtls.Rspnsblty` | string | No | min length 1; max length 35 | Responsibility: Role of a person in an organisation. |
| `CdtTrfTxInf.Cdtr.CtctDtls.Dept` | string | No | min length 1; max length 70 | Department: Identification of a division of a large organisation or building. |
| `CdtTrfTxInf.Cdtr.CtctDtls.Othr` | object | No |  | OtherContact: Contact details in another form. |
| `CdtTrfTxInf.Cdtr.CtctDtls.Othr.ChanlTp` | string | Yes | min length 1; max length 4 | ChannelType: Method used to contact the financial institution's contact for the specific tax region. |
| `CdtTrfTxInf.Cdtr.CtctDtls.Othr.Id` | string | No | min length 1; max length 128 | Identifier: Communication value such as phone number or email address. |
| `CdtTrfTxInf.Cdtr.CtctDtls.PrefrdMtd` | string | No | one of `LETT`, `MAIL`, `PHON`, `FAXX`, `CELL` | PreferredContactMethod: Preferred method used to reach the contact. |
| `CdtTrfTxInf.CdtrAcct` | object | No |  | CreditorAccount: Unambiguous identification of the account of the creditor to which a credit entry will be posted as a result of the payment transaction. |
| `CdtTrfTxInf.CdtrAcct.Id` | choice | No |  | Identification: Unique and unambiguous identification for the account between the account owner and the account servicer. |
| `CdtTrfTxInf.CdtrAcct.Tp` | choice | No |  | Type: Specifies the nature, or use of the account. |
| `CdtTrfTxInf.CdtrAcct.Ccy` | string | No | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.CdtrAcct.Nm` | string | No | min length 1; max length 70 | Name: Name of the account, as assigned by the account servicing institution, in agreement with the account owner in order to provide an additional means of identification of the account. |
| `CdtTrfTxInf.CdtrAcct.Prxy` | object | No |  | Proxy: Specifies an alternate assumed name for the identification of the account. |
| `CdtTrfTxInf.CdtrAcct.Prxy.Tp` | choice | No |  | Type: Type of the proxy identification. |
| `CdtTrfTxInf.CdtrAcct.Prxy.Id` | string | Yes | min length 1; max length 2048 | Identification: Identification used to indicate the account identification under another specified name. |
| `CdtTrfTxInf.InstrForCdtrAgt` | object | No |  | InstructionForCreditorAgent: Set of elements used to provide information on the remittance advice. |
| `CdtTrfTxInf.InstrForCdtrAgt.Cd` | string | No | min length 1; max length 4 | Code: Coded information related to the processing of the payment instruction, provided by the initiating party, and intended for the creditor's agent. |
| `CdtTrfTxInf.InstrForCdtrAgt.InstrInf` | string | No | min length 1; max length 140 | InstructionInformation: Further information complementing the coded instruction or instruction to the creditor's agent that is bilaterally agreed or specific to a user community. |
| `CdtTrfTxInf.InstrForNxtAgt` | object | No |  | InstructionForNextAgent: Set of elements used to provide information on the remittance advice. |
| `CdtTrfTxInf.InstrForNxtAgt.Cd` | string | No | one of `PHOA`, `TELA` | Code: Coded information related to the processing of the payment instruction, provided by the initiating party, and intended for the next agent in the payment chain. |
| `CdtTrfTxInf.InstrForNxtAgt.InstrInf` | string | No | min length 1; max length 140 | InstructionInformation: Further information complementing the coded instruction or instruction to the next agent that is bilaterally agreed or specific to a user community. |
| `CdtTrfTxInf.Purp` | choice | No |  | Purpose: Underlying reason for the payment transaction. |
| `CdtTrfTxInf.RgltryRptg` | object | No |  | RegulatoryReporting: Information needed due to regulatory and statutory requirements. |
| `CdtTrfTxInf.RgltryRptg.DbtCdtRptgInd` | string | No | one of `CRED`, `DEBT`, `BOTH` | DebitCreditReportingIndicator: Identifies whether the regulatory reporting information applies to the debit side, to the credit side or to both debit and credit sides of the transaction. |
| `CdtTrfTxInf.RgltryRptg.Authrty` | object | No |  | Authority: Entity requiring the regulatory reporting information. |
| `CdtTrfTxInf.RgltryRptg.Authrty.Nm` | string | No | min length 1; max length 140 | Name: Name of the entity requiring the regulatory reporting information. |
| `CdtTrfTxInf.RgltryRptg.Authrty.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Country: Country of the entity that requires the regulatory reporting information. |
| `CdtTrfTxInf.RgltryRptg.Dtls` | choice | No |  | Details: Identifies whether the regulatory reporting information applies to the debit side, to the credit side or to both debit and credit sides of the transaction. |
| `CdtTrfTxInf.RgltryRptg.Dtls.Tp` | string | No | min length 1; max length 35 | Type: Specifies the type of the information supplied in the regulatory reporting details. |
| `CdtTrfTxInf.RgltryRptg.Dtls.Dt` | string | No |  | Date: Date related to the specified type of regulatory reporting details. |
| `CdtTrfTxInf.RgltryRptg.Dtls.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Country: Country related to the specified type of regulatory reporting details. |
| `CdtTrfTxInf.RgltryRptg.Dtls.Cd` | string | No | min length 1; max length 10 | Code: Specifies the nature, purpose, and reason for the transaction to be reported for regulatory and statutory requirements in a coded form. |
| `CdtTrfTxInf.RgltryRptg.Dtls.Amt` | object | No |  | Amount: Amount of money to be reported for regulatory and statutory requirements. |
| `CdtTrfTxInf.RgltryRptg.Dtls.Amt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.RgltryRptg.Dtls.Amt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.RgltryRptg.Dtls.Inf` | choice | No |  | Information: Additional details that cater for specific domestic regulatory requirements. |
| `CdtTrfTxInf.RgltryRptg.Dtls[].Tp` | string | No | min length 1; max length 35 | Type: Specifies the type of the information supplied in the regulatory reporting details. |
| `CdtTrfTxInf.RgltryRptg.Dtls[].Dt` | string | No |  | Date: Date related to the specified type of regulatory reporting details. |
| `CdtTrfTxInf.RgltryRptg.Dtls[].Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Country: Country related to the specified type of regulatory reporting details. |
| `CdtTrfTxInf.RgltryRptg.Dtls[].Cd` | string | No | min length 1; max length 10 | Code: Specifies the nature, purpose, and reason for the transaction to be reported for regulatory and statutory requirements in a coded form. |
| `CdtTrfTxInf.RgltryRptg.Dtls[].Amt` | object | No |  | Amount: Amount of money to be reported for regulatory and statutory requirements. |
| `CdtTrfTxInf.RgltryRptg.Dtls[].Amt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.RgltryRptg.Dtls[].Amt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.RgltryRptg.Dtls[].Inf` | choice | No |  | Information: Additional details that cater for specific domestic regulatory requirements. |
| `CdtTrfTxInf.Tax` | object | No |  | Tax: Provides details on the tax. |
| `CdtTrfTxInf.Tax.Cdtr` | object | No |  | Creditor: Party on the credit side of the transaction to which the tax applies. |
| `CdtTrfTxInf.Tax.Cdtr.TaxId` | string | No | min length 1; max length 35 | TaxIdentification: Tax identification number of the creditor. |
| `CdtTrfTxInf.Tax.Cdtr.RegnId` | string | No | min length 1; max length 35 | RegistrationIdentification: Unique identification, as assigned by an organisation, to unambiguously identify a party. |
| `CdtTrfTxInf.Tax.Cdtr.TaxTp` | string | No | min length 1; max length 35 | TaxType: Type of tax payer. |
| `CdtTrfTxInf.Tax.Dbtr` | object | No |  | Debtor: Party on the debit side of the transaction to which the tax applies. |
| `CdtTrfTxInf.Tax.Dbtr.TaxId` | string | No | min length 1; max length 35 | TaxIdentification: Tax identification number of the debtor. |
| `CdtTrfTxInf.Tax.Dbtr.RegnId` | string | No | min length 1; max length 35 | RegistrationIdentification: Unique identification, as assigned by an organisation, to unambiguously identify a party. |
| `CdtTrfTxInf.Tax.Dbtr.TaxTp` | string | No | min length 1; max length 35 | TaxType: Type of tax payer. |
| `CdtTrfTxInf.Tax.Dbtr.Authstn` | object | No |  | Authorisation: Details of the authorised tax paying party. |
| `CdtTrfTxInf.Tax.Dbtr.Authstn.Titl` | string | No | min length 1; max length 35 | Title: Title or position of debtor or the debtor's authorised representative. |
| `CdtTrfTxInf.Tax.Dbtr.Authstn.Nm` | string | No | min length 1; max length 140 | Name: Name of the debtor or the debtor's authorised representative. |
| `CdtTrfTxInf.Tax.UltmtDbtr` | object | No |  | UltimateDebtor: Ultimate party that owes an amount of money to the (ultimate) creditor, in this case, to the taxing authority. |
| `CdtTrfTxInf.Tax.UltmtDbtr.TaxId` | string | No | min length 1; max length 35 | TaxIdentification: Tax identification number of the debtor. |
| `CdtTrfTxInf.Tax.UltmtDbtr.RegnId` | string | No | min length 1; max length 35 | RegistrationIdentification: Unique identification, as assigned by an organisation, to unambiguously identify a party. |
| `CdtTrfTxInf.Tax.UltmtDbtr.TaxTp` | string | No | min length 1; max length 35 | TaxType: Type of tax payer. |
| `CdtTrfTxInf.Tax.UltmtDbtr.Authstn` | object | No |  | Authorisation: Details of the authorised tax paying party. |
| `CdtTrfTxInf.Tax.UltmtDbtr.Authstn.Titl` | string | No | min length 1; max length 35 | Title: Title or position of debtor or the debtor's authorised representative. |
| `CdtTrfTxInf.Tax.UltmtDbtr.Authstn.Nm` | string | No | min length 1; max length 140 | Name: Name of the debtor or the debtor's authorised representative. |
| `CdtTrfTxInf.Tax.AdmstnZone` | string | No | min length 1; max length 35 | AdministrationZone: Territorial part of a country to which the tax payment is related. |
| `CdtTrfTxInf.Tax.RefNb` | string | No | min length 1; max length 140 | ReferenceNumber: Tax reference information that is specific to a taxing agency. |
| `CdtTrfTxInf.Tax.Mtd` | string | No | min length 1; max length 35 | Method: Method used to indicate the underlying business or how the tax is paid. |
| `CdtTrfTxInf.Tax.TtlTaxblBaseAmt` | object | No |  | TotalTaxableBaseAmount: Total amount of money on which the tax is based. |
| `CdtTrfTxInf.Tax.TtlTaxblBaseAmt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.Tax.TtlTaxblBaseAmt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.Tax.TtlTaxAmt` | object | No |  | TotalTaxAmount: Total amount of money as result of the calculation of the tax. |
| `CdtTrfTxInf.Tax.TtlTaxAmt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.Tax.TtlTaxAmt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.Tax.Dt` | string | No |  | Date: Date by which tax is due. |
| `CdtTrfTxInf.Tax.SeqNb` | string | No | pattern `^(?!0\d)\d{1,18}$` | SequenceNumber: Sequential number of the tax report. |
| `CdtTrfTxInf.Tax.Rcrd` | choice | No |  | Record: Details of the tax record. |
| `CdtTrfTxInf.Tax.Rcrd.AddtlInf` | string | No | min length 1; max length 140 | AdditionalInformation: Further details of the tax record. |
| `CdtTrfTxInf.Tax.Rcrd.CertId` | string | No | min length 1; max length 35 | CertificateIdentification: Identification number of the tax report as assigned by the taxing authority. |
| `CdtTrfTxInf.Tax.Rcrd.Ctgy` | string | No | min length 1; max length 35 | Category: Specifies the tax code as published by the tax authority. |
| `CdtTrfTxInf.Tax.Rcrd.CtgyDtls` | string | No | min length 1; max length 35 | CategoryDetails: Provides further details of the category tax code. |
| `CdtTrfTxInf.Tax.Rcrd.DbtrSts` | string | No | min length 1; max length 35 | DebtorStatus: Code provided by local authority to identify the status of the party that has drawn up the settlement document. |
| `CdtTrfTxInf.Tax.Rcrd.FrmsCd` | string | No | min length 1; max length 35 | FormsCode: Identifies, in a coded form, on which template the tax report is to be provided. |
| `CdtTrfTxInf.Tax.Rcrd.Prd` | object | No |  | Period: Set of elements used to provide details on the period of time related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd.Prd.FrToDt` | object | No |  | FromToDate: Range of time between a start date and an end date for which the tax report is provided. |
| `CdtTrfTxInf.Tax.Rcrd.Prd.FrToDt.FrDt` | string | Yes |  | FromDate: Start date of the range. |
| `CdtTrfTxInf.Tax.Rcrd.Prd.FrToDt.ToDt` | string | Yes |  | ToDate: End date of the range. |
| `CdtTrfTxInf.Tax.Rcrd.Prd.Tp` | string | No | enum (18 values) | Type: Identification of the period related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd.Prd.Yr` | string | No | pattern `^\d{4}(Z\|([+-]\d{2}:\d{2})){0,1}$` | Year: Year related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt` | object | No |  | TaxAmount: Set of elements used to provide information on the amount of the tax record. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Rate` | string | No | pattern: see spec | Rate: Rate used to calculate the tax. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.TaxblBaseAmt` | object | No |  | TaxableBaseAmount: Amount of money on which the tax is based. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.TaxblBaseAmt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.TaxblBaseAmt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.TtlAmt` | object | No |  | TotalAmount: Total amount that is the result of the calculation of the tax for the record. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.TtlAmt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.TtlAmt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls` | choice | No |  | Details: Set of elements used to provide details on the tax period and amount. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls.Prd` | object | No |  | Period: Set of elements used to provide details on the period of time related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls.Prd.FrToDt` | object | No |  | FromToDate: Range of time between a start date and an end date for which the tax report is provided. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls.Prd.FrToDt.FrDt` | string | Yes |  | FromDate: Start date of the range. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls.Prd.FrToDt.ToDt` | string | Yes |  | ToDate: End date of the range. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls.Prd.Tp` | string | No | enum (18 values) | Type: Identification of the period related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls.Prd.Yr` | string | No | pattern `^\d{4}(Z\|([+-]\d{2}:\d{2})){0,1}$` | Year: Year related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls.Amt` | object | Yes |  | Amount: Underlying tax amount related to the specified period. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls.Amt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls.Amt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls[].Prd` | object | No |  | Period: Set of elements used to provide details on the period of time related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls[].Prd.FrToDt` | object | No |  | FromToDate: Range of time between a start date and an end date for which the tax report is provided. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls[].Prd.FrToDt.FrDt` | string | Yes |  | FromDate: Start date of the range. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls[].Prd.FrToDt.ToDt` | string | Yes |  | ToDate: End date of the range. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls[].Prd.Tp` | string | No | enum (18 values) | Type: Identification of the period related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls[].Prd.Yr` | string | No | pattern `^\d{4}(Z\|([+-]\d{2}:\d{2})){0,1}$` | Year: Year related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls[].Amt` | object | Yes |  | Amount: Underlying tax amount related to the specified period. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls[].Amt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.Tax.Rcrd.TaxAmt.Dtls[].Amt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.Tax.Rcrd.Tp` | string | No | min length 1; max length 35 | Type: High level code to identify the type of tax details. |
| `CdtTrfTxInf.Tax.Rcrd[].AddtlInf` | string | No | min length 1; max length 140 | AdditionalInformation: Further details of the tax record. |
| `CdtTrfTxInf.Tax.Rcrd[].CertId` | string | No | min length 1; max length 35 | CertificateIdentification: Identification number of the tax report as assigned by the taxing authority. |
| `CdtTrfTxInf.Tax.Rcrd[].Ctgy` | string | No | min length 1; max length 35 | Category: Specifies the tax code as published by the tax authority. |
| `CdtTrfTxInf.Tax.Rcrd[].CtgyDtls` | string | No | min length 1; max length 35 | CategoryDetails: Provides further details of the category tax code. |
| `CdtTrfTxInf.Tax.Rcrd[].DbtrSts` | string | No | min length 1; max length 35 | DebtorStatus: Code provided by local authority to identify the status of the party that has drawn up the settlement document. |
| `CdtTrfTxInf.Tax.Rcrd[].FrmsCd` | string | No | min length 1; max length 35 | FormsCode: Identifies, in a coded form, on which template the tax report is to be provided. |
| `CdtTrfTxInf.Tax.Rcrd[].Prd` | object | No |  | Period: Set of elements used to provide details on the period of time related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd[].Prd.FrToDt` | object | No |  | FromToDate: Range of time between a start date and an end date for which the tax report is provided. |
| `CdtTrfTxInf.Tax.Rcrd[].Prd.FrToDt.FrDt` | string | Yes |  | FromDate: Start date of the range. |
| `CdtTrfTxInf.Tax.Rcrd[].Prd.FrToDt.ToDt` | string | Yes |  | ToDate: End date of the range. |
| `CdtTrfTxInf.Tax.Rcrd[].Prd.Tp` | string | No | enum (18 values) | Type: Identification of the period related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd[].Prd.Yr` | string | No | pattern `^\d{4}(Z\|([+-]\d{2}:\d{2})){0,1}$` | Year: Year related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt` | object | No |  | TaxAmount: Set of elements used to provide information on the amount of the tax record. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Rate` | string | No | pattern: see spec | Rate: Rate used to calculate the tax. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.TaxblBaseAmt` | object | No |  | TaxableBaseAmount: Amount of money on which the tax is based. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.TaxblBaseAmt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.TaxblBaseAmt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.TtlAmt` | object | No |  | TotalAmount: Total amount that is the result of the calculation of the tax for the record. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.TtlAmt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.TtlAmt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls` | choice | No |  | Details: Set of elements used to provide details on the tax period and amount. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls.Prd` | object | No |  | Period: Set of elements used to provide details on the period of time related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls.Prd.FrToDt` | object | No |  | FromToDate: Range of time between a start date and an end date for which the tax report is provided. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls.Prd.FrToDt.FrDt` | string | Yes |  | FromDate: Start date of the range. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls.Prd.FrToDt.ToDt` | string | Yes |  | ToDate: End date of the range. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls.Prd.Tp` | string | No | enum (18 values) | Type: Identification of the period related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls.Prd.Yr` | string | No | pattern `^\d{4}(Z\|([+-]\d{2}:\d{2})){0,1}$` | Year: Year related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls.Amt` | object | Yes |  | Amount: Underlying tax amount related to the specified period. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls.Amt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls.Amt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls[].Prd` | object | No |  | Period: Set of elements used to provide details on the period of time related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls[].Prd.FrToDt` | object | No |  | FromToDate: Range of time between a start date and an end date for which the tax report is provided. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls[].Prd.FrToDt.FrDt` | string | Yes |  | FromDate: Start date of the range. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls[].Prd.FrToDt.ToDt` | string | Yes |  | ToDate: End date of the range. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls[].Prd.Tp` | string | No | enum (18 values) | Type: Identification of the period related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls[].Prd.Yr` | string | No | pattern `^\d{4}(Z\|([+-]\d{2}:\d{2})){0,1}$` | Year: Year related to the tax payment. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls[].Amt` | object | Yes |  | Amount: Underlying tax amount related to the specified period. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls[].Amt.ActiveOrHistoricCurrencyAndAmount` | string | Yes | pattern: see spec | Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. |
| `CdtTrfTxInf.Tax.Rcrd[].TaxAmt.Dtls[].Amt.Ccy` | string | Yes | enum (164 values); min length 3; max length 3 | Currency: Identification of the currency in which the account is held. |
| `CdtTrfTxInf.Tax.Rcrd[].Tp` | string | No | min length 1; max length 35 | Type: High level code to identify the type of tax details. |
| `CdtTrfTxInf.VrfctnOfTerms` | choice | No |  | Cryptographically signed terms |
| `CdtTrfTxInf.VrfctnOfTerms.IlpV4PrepPacket` | string | Yes | pattern `^[A-Za-z0-9-_]+[=]{0,2}$` | Interledger Protocol packet (ILPv4) containing Cryptographically signed terms |
| `CdtTrfTxInf.VrfctnOfTerms.Sh256Sgntr` | string | Yes |  | SHA-256 signature of the terms |

### Payment status report

Used by: `PacsStatus_FIToFIPaymentStatusReportV15`, `PacsError_FIToFIPaymentStatusReportV15`.

68 elements.

| Path | Type | Required | Constraints | Meaning |
|---|---|---|---|---|
| `GrpHdr` | object | Yes |  | Set of characteristics shared by all individual transactions included in the message. |
| `GrpHdr.MsgId` | string | Yes | min length 1; max length 35 | MessageIdentification: Point to point reference, as assigned by the instructing party, and sent to the next party in the chain to unambiguously identify the message. |
| `GrpHdr.CreDtTm` | string | Yes | pattern: see spec | CreationDateTime: Date and time at which the message was created. |
| `TxInfAndSts` | object | No |  | Information concerning the original transactions, to which the status report message refers. |
| `TxInfAndSts.StsId` | string | No | min length 1; max length 35 | Unique identification, as assigned by the original sending party, to unambiguously identify the status report. |
| `TxInfAndSts.OrgnlInstrId` | string | No | min length 1; max length 35 | Unique identification, as assigned by the original sending party, to: unambiguously identify the original instruction. |
| `TxInfAndSts.OrgnlEndToEndId` | string | No | min length 1; max length 35 | Unique identification, as assigned by the original sending party, to: unambiguously identify the original end-to-end transaction. |
| `TxInfAndSts.OrgnlTxId` | string | No | min length 1; max length 35 | Unique identification, as assigned by the original sending party, to: unambiguously identify the original transaction. |
| `TxInfAndSts.OrgnlUETR` | string | No | pattern: see spec | Unique end-to-end transaction reference, as assigned by the original sending party, to unambiguously identify the original transaction. |
| `TxInfAndSts.TxSts` | string | No | one of `COMM`, `RESV`, `RECV`, `ABOR`; min length 1; max length 4 | Specifies the status of the transaction. |
| `TxInfAndSts.StsRsnInf` | object | No |  | Information concerning the reason for the status. |
| `TxInfAndSts.StsRsnInf.Orgtr` | object | No |  | Originator: Party that issues the status. |
| `TxInfAndSts.StsRsnInf.Orgtr.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr` | object | No |  | Postal Address: Information that locates and identifies a specific address, as defined by postal services. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.AdrTp` | choice | No |  | Choice of formats for the type of address. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.AdrTp.Cd` | string | Yes | one of `ADDR`, `PBOX`, `HOME`, `BIZZ`, `MLTO`, `DLVY` | Code: Type of address expressed as a code. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.AdrTp.Prtry` | object | Yes |  | Proprietary: Type of address expressed as a proprietary code. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.AdrTp.Prtry.Id` | string | Yes | pattern `^[a-zA-Z0-9]{4}$` | Identification: Proprietary information, often a code, issued by the data source scheme issuer. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.AdrTp.Prtry.Issr` | string | Yes | min length 1; max length 35 | Issuer: Entity that assigns the identification. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.AdrTp.Prtry.SchmeNm` | string | No | min length 1; max length 35 | SchemeName: Short textual description of the scheme. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.CareOf` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.Dept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.SubDept` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.StrtNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.BldgNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.BldgNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.Flr` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.UnitNb` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.PstBx` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.Room` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.PstCd` | string | No | min length 1; max length 16 | Specifies a character string with a maximum length of 16 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.TwnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.TwnLctnNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.DstrctNm` | string | No | min length 1; max length 140 | Specifies a character string with a maximum length of 140 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.CtrySubDvsn` | string | No | min length 1; max length 35 | Specifies a character string with a maximum length of 35 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.Ctry` | string | No | pattern `^[A-Z]{2,2}$` | Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code). |
| `TxInfAndSts.StsRsnInf.Orgtr.PstlAdr.AdrLine` | string | No | min length 1; max length 70 | Specifies a character string with a maximum length of 70 characters. |
| `TxInfAndSts.StsRsnInf.Orgtr.Id` | choice | Yes |  | Identification: Unique and unambiguous identification of a party. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtryOfRes` | string | No | pattern `^[A-Z]{2,2}$` | Country of Residence: Country in which a person resides (the place of a person's home). |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls` | object | No |  | Contact Details: Set of elements used to indicate how to contact the party. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.NmPrfx` | string | No | one of `DOCT`, `MADM`, `MISS`, `MIST`, `MIKS` | NamePrefix: Specifies the terms used to formally address a person. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.Nm` | string | No | min length 1; max length 140 | Name: Name by which a party is known and which is usually used to identify that party. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.PhneNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | PhoneNumber: Collection of information that identifies a phone number, as defined by telecom services. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.MobNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | MobilePhoneNumber: Collection of information that identifies a mobile phone number, as defined by telecom services. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.FaxNb` | string | No | pattern `^\+[0-9]{1,3}-[0-9()+\-]{1,30}$` | FaxNumber: Collection of information that identifies a fax number, as defined by telecom services. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.URLAdr` | string | No | min length 1; max length 2048 | URLAddress: Address for the Universal Resource Locator (URL), for example an address used over the www (HTTP) service. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.EmailAdr` | string | No | min length 1; max length 256 | EmailAddress: Address for electronic mail (e-mail). |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.EmailPurp` | string | No | min length 1; max length 35 | EmailPurpose: Purpose for which an email address may be used. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.JobTitl` | string | No | min length 1; max length 35 | JobTitle: Title of the function. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.Rspnsblty` | string | No | min length 1; max length 35 | Responsibility: Role of a person in an organisation. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.Dept` | string | No | min length 1; max length 70 | Department: Identification of a division of a large organisation or building. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.Othr` | object | No |  | OtherContact: Contact details in another form. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.Othr.ChanlTp` | string | Yes | min length 1; max length 4 | ChannelType: Method used to contact the financial institution's contact for the specific tax region. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.Othr.Id` | string | No | min length 1; max length 128 | Identifier: Communication value such as phone number or email address. |
| `TxInfAndSts.StsRsnInf.Orgtr.CtctDtls.PrefrdMtd` | string | No | one of `LETT`, `MAIL`, `PHON`, `FAXX`, `CELL` | PreferredContactMethod: Preferred method used to reach the contact. |
| `TxInfAndSts.StsRsnInf.Rsn` | choice | No |  | Reason: Specifies the reason for the status report. |
| `TxInfAndSts.StsRsnInf.AddtlInf` | string | No | min length 1; max length 105 | AdditionalInformation: Additional information about the status report. |
| `TxInfAndSts.AccptncDtTm` | string | No | pattern: see spec | Date and time at which the status was accepted. |
| `TxInfAndSts.AcctSvcrRef` | string | No | min length 1; max length 35 | Unique reference, as assigned by the account servicing institution, to unambiguously identify the status report. |
| `TxInfAndSts.ClrSysRef` | string | No | min length 1; max length 35 | Reference that is assigned by the account servicing institution and sent to the account owner to unambiguously identify the transaction. |
| `TxInfAndSts.ExctnConf` | string | No |  | Unique reference, as assigned by the account servicing institution, to unambiguously identify the confirmation. |
| `TxInfAndSts.SplmtryData` | object | No |  | Additional information that cannot be captured in the structured elements and/or any other specific block. |
| `TxInfAndSts.SplmtryData.PlcAndNm` | string | No | min length 1; max length 350 | PlaceAndName: Unambiguous reference to the location where the supplementary data must be inserted in the message instance. |
| `TxInfAndSts.SplmtryData.Envlp` | object | Yes |  | Envelope: Technical element wrapping the supplementary data. |
| `TxInfAndSts.PrcgDt` | choice | No |  | Date/time at which the instruction was processed by the specified party. |
| `SplmtryData` | object | No |  | Additional information that cannot be captured in the structured elements and/or any other specific block. |
| `SplmtryData.PlcAndNm` | string | No | min length 1; max length 350 | PlaceAndName: Unambiguous reference to the location where the supplementary data must be inserted in the message instance. |
| `SplmtryData.Envlp` | object | Yes |  | Envelope: Technical element wrapping the supplementary data. |
