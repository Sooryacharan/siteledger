# SiteLedger entity diagram

The Prisma schema is the field-complete model. These diagrams show how the modules connect, and they repeat the fields the product brief names. Attribute types are shortened to `uuid`, `string`, `int`, `bigint`, `decimal`, `date`, `bool`, and `json`. Money columns are paise.

```mermaid
flowchart TB
  org[Organization]
  party[Party]
  project[Project]
  unit[Unit]
  booking[Booking]
  journal[JournalEntry]
  invoice[VendorInvoice]
  stock[StockLedger]
  share[ShareLedger]
  doc[Document]

  org --> party
  org --> project
  project --> unit
  unit --> booking
  party --> booking
  booking --> journal
  party --> invoice
  invoice --> journal
  project --> stock
  party --> share
  journal --> doc
```

## Identity, tenancy, audit

```mermaid
erDiagram
  ORGANIZATION ||--o{ MEMBERSHIP : has
  USER ||--o{ MEMBERSHIP : joins
  PARTY o|--o{ MEMBERSHIP : portal_identity
  ORGANIZATION ||--o{ PROJECT_ASSIGNMENT : scopes
  USER ||--o{ PROJECT_ASSIGNMENT : assigned
  PROJECT ||--o{ PROJECT_ASSIGNMENT : limits
  ORGANIZATION ||--o{ AUDIT_EVENT : records
  USER o|--o{ AUDIT_EVENT : acts
  ORGANIZATION ||--o{ CHAIN_HEAD : heads
  ORGANIZATION ||--o{ APPROVAL_POLICY : configures
  ORGANIZATION ||--o{ APPROVAL_REQUEST : opens
  APPROVAL_REQUEST ||--o{ APPROVAL_ACTION : decides
  ORGANIZATION ||--o{ FISCAL_YEAR : owns
  FISCAL_YEAR ||--o{ ACCOUNTING_PERIOD : contains
  ACCOUNTING_PERIOD ||--o{ PERIOD_LOCK_EVENT : logs
  APPROVAL_REQUEST o|--o{ PERIOD_LOCK_EVENT : reopens

  ORGANIZATION {
    uuid id
    string slug
    string legal_name
    string gstin
    string state_code
    string timezone
  }
  MEMBERSHIP {
    uuid id
    uuid organization_id
    uuid user_id
    string role
    uuid party_id
  }
  AUDIT_EVENT {
    uuid id
    string action
    string entity_type
    json before
    json after
    string ip_address
    string prev_hash
    string event_hash
  }
  CHAIN_HEAD {
    uuid id
    string chain
    string last_hash
    int last_sequence
  }
  APPROVAL_POLICY {
    uuid id
    string entity_type
    bigint min_amount_paise
    bigint max_amount_paise
    string approver_role
    bool auto_approve
  }
```

`User`, `Account`, `Session`, and `VerificationToken` follow Auth.js. `GstRate` and `TdsSection` are global slabs. None of those six tables carry `organization_id`.

## Projects, phases, towers, floors, units

```mermaid
erDiagram
  ORGANIZATION ||--o{ PROJECT : develops
  PROJECT ||--o{ PROJECT_PHASE : phases
  PROJECT ||--o{ TOWER : towers
  PROJECT_PHASE o|--o{ TOWER : groups
  TOWER ||--o{ FLOOR : floors
  PROJECT ||--o{ UNIT : inventory
  TOWER o|--o{ UNIT : contains
  FLOOR o|--o{ UNIT : contains
  UNIT ||--o{ UNIT_AREA_REVISION : trail
  PROJECT ||--o{ COST_CENTRE : costs
  PROJECT ||--o{ BOQ_ITEM : norms
  COST_CENTRE o|--o{ BOQ_ITEM : classifies

  PROJECT {
    uuid id
    string code
    string name
    string rera_registration_number
    string gstin
    string cost_area_basis
    decimal area_variance_alert_percent
  }
  PROJECT_PHASE {
    uuid id
    uuid project_id
    string name
    int sort_order
  }
  TOWER {
    uuid id
    uuid project_id
    uuid phase_id
    string name
  }
  FLOOR {
    uuid id
    uuid tower_id
    int level_number
    string label
  }
  UNIT {
    uuid id
    string flat_number
    string facing
    string status
    decimal carpet_planned_sqft
    decimal carpet_approved_sqft
    decimal carpet_built_sqft
    decimal built_up_planned_sqft
    decimal built_up_approved_sqft
    decimal built_up_built_sqft
    decimal super_built_up_planned_sqft
    decimal super_built_up_approved_sqft
    decimal super_built_up_built_sqft
  }
  UNIT_AREA_REVISION {
    uuid id
    string field
    decimal previous_sqft
    decimal new_sqft
    string reason
  }
  BOQ_ITEM {
    uuid id
    string code
    decimal norm_qty_per_sqft
    decimal wastage_allowance_percent
  }
```

A plot can omit tower and floor. Floor level 0 is ground. Negative levels are basements. Every area change also inserts a revision. Variance alerts read the current unit columns.

## Sales CRM

```mermaid
erDiagram
  PROJECT o|--o{ LEAD : attracts
  LEAD ||--o{ LEAD_FOLLOWUP : followups
  LEAD ||--o{ SITE_VISIT : visits
  LEAD ||--o{ LEAD_ACTIVITY : history
  UNIT o|--o{ SITE_VISIT : shown
  LEAD o|--o| BOOKING : converts
  UNIT ||--o{ BOOKING : sold_as
  BOOKING ||--o{ BOOKING_CUSTOMER : buyers
  PARTY ||--o{ BOOKING_CUSTOMER : buys
  BOOKING ||--o{ AGREEMENT : agreements
  BOOKING o|--o| BOOKING_CANCELLATION : cancellation
  BOOKING ||--o{ BOOKING_TRANSFER : transfers
  BOOKING ||--o{ DEMAND_SCHEDULE_ITEM : schedule
  BOOKING ||--o{ DEMAND_NOTE : demands
  DEMAND_NOTE ||--o{ INTEREST_ACCRUAL : interest
  INTEREST_RULE ||--o{ INTEREST_ACCRUAL : rate
  BOOKING ||--o{ RECEIPT : receipts
  RECEIPT ||--o{ RECEIPT_ALLOCATION : allocates
  DEMAND_NOTE o|--o{ RECEIPT_ALLOCATION : settled_by
  BOOKING ||--o{ CUSTOMER_STATEMENT : snapshots
  PROJECT ||--o{ PROGRESS_UPDATE : photos

  LEAD_FOLLOWUP {
    uuid id
    string channel
    string outcome
    date due_on
  }
  SITE_VISIT {
    uuid id
    uuid unit_id
    string status
    string visited_at
  }
  BOOKING {
    uuid id
    string booking_number
    string status
    bigint base_value_paise
    bigint cgst_paise
    bigint sgst_paise
    bigint igst_paise
    bigint total_payable_paise
  }
  AGREEMENT {
    uuid id
    string kind
    string status
    string registration_number
    bigint stamp_duty_paise
  }
  BOOKING_CANCELLATION {
    uuid id
    date cancelled_on
    bigint deduction_paise
    bigint refund_paise
  }
  BOOKING_TRANSFER {
    uuid id
    uuid from_booking_id
    uuid to_booking_id
    bigint ledger_carried_forward_paise
    string charge_payer
  }
  DEMAND_NOTE {
    uuid id
    string supply_type
    string place_of_supply_state_code
    bigint cgst_paise
    bigint sgst_paise
    bigint igst_paise
    bigint total_paise
  }
  INTEREST_ACCRUAL {
    uuid id
    bigint principal_paise
    decimal annual_rate_percent
    int day_count
    bigint amount_paise
    string formula_version
  }
  RECEIPT {
    uuid id
    string channel
    string instrument_reference
    date value_date
    bigint amount_paise
    bigint buyer_tds_paise
  }
```

Receipts stay on the old booking after a transfer. The new booking opens with `ledger_carried_forward_paise`. Buyer TDS is entered. It is not calculated from section 194-IA.

## Partners and investors

```mermaid
erDiagram
  PROJECT ||--o{ CAPITAL_CONTRIBUTION : capital
  PARTY ||--o{ CAPITAL_CONTRIBUTION : contributes
  PROJECT ||--o{ PROFIT_SHARING_AGREEMENT : agrees
  PROFIT_SHARING_AGREEMENT ||--o{ PROFIT_SHARING_RULE : rules
  PARTY ||--o{ PROFIT_SHARING_RULE : shares
  UNIT ||--o{ UNIT_ALLOCATION : allocated
  PARTY ||--o{ UNIT_ALLOCATION : receives
  PROFIT_SHARING_AGREEMENT ||--o{ SHARE_COMPUTATION : runs
  SHARE_COMPUTATION ||--o{ SHARE_LEDGER_ENTRY : posts
  PARTY ||--o{ SHARE_LEDGER_ENTRY : ledger

  PROFIT_SHARING_RULE {
    uuid id
    int priority
    decimal share_percent
    decimal hurdle_rate_percent
    bigint fixed_amount_paise
    bool is_residual
    bool participates_in_loss
    bool absorbs_rounding
  }
  SHARE_COMPUTATION {
    uuid id
    date as_of
    bigint profit_paise
    string formula_version
    string status
  }
  SHARE_LEDGER_ENTRY {
    uuid id
    string entry_type
    bigint amount_paise
    int sequence
    string prev_hash
    string entry_hash
  }
  UNIT_ALLOCATION {
    uuid id
    decimal share_percent
    string reason
  }
```

## Vendors and procurement

```mermaid
erDiagram
  PARTY ||--o| VENDOR_PROFILE : vendor
  PARTY ||--o{ PARTY_BANK_ACCOUNT : banks
  PARTY ||--o{ PARTY_CONTACT : phones
  PARTY o|--o| PARTY : related_party
  PROJECT ||--o{ INDENT : indents
  INDENT ||--o{ INDENT_LINE : lines
  INDENT ||--o{ VENDOR_QUOTE : quotes
  VENDOR_QUOTE ||--o{ VENDOR_QUOTE_LINE : priced
  VENDOR_QUOTE ||--o{ QUOTE_COMPARISON : compared
  VENDOR_QUOTE o|--o{ PURCHASE_ORDER : awarded
  PURCHASE_ORDER ||--o{ PURCHASE_ORDER_LINE : lines
  PURCHASE_ORDER o|--o{ GOODS_RECEIPT : received
  GOODS_RECEIPT ||--o{ GOODS_RECEIPT_LINE : lines
  PARTY ||--o{ VENDOR_INVOICE : invoices
  VENDOR_INVOICE ||--o{ VENDOR_INVOICE_LINE : lines
  VENDOR_INVOICE ||--o| THREE_WAY_MATCH : matched
  THREE_WAY_MATCH ||--o{ THREE_WAY_MATCH_LINE : lines
  TDS_SECTION o|--o{ VENDOR_INVOICE : section

  PARTY {
    uuid id
    string legal_name
    string pan_normalized
    bool pan_shape_valid
    string gstin_normalized
    bool gstin_checksum_valid
    bool is_vendor
    bool is_related_party
  }
  PARTY_BANK_ACCOUNT {
    uuid id
    string ifsc
    string account_number
    string fingerprint
  }
  PARTY_CONTACT {
    uuid id
    string phone_e164
    string email
  }
  VENDOR_INVOICE {
    uuid id
    string invoice_number
    string normalized_invoice_number
    string fingerprint
    string supply_type
    bigint taxable_paise
    bigint cgst_paise
    bigint sgst_paise
    bigint igst_paise
    bigint tds_paise
    bigint total_paise
    bigint net_payable_paise
    bool expects_goods
  }
  THREE_WAY_MATCH {
    uuid id
    string status
    bigint rate_variance_paise
  }
```

A draft goods receipt may have no purchase order yet, so a site phone can record material received and link the order later. Quote comparison is append-only and requires a reason.

## Materials, contractors, labour

```mermaid
erDiagram
  PROJECT ||--o{ STORE : stores
  STORE ||--o{ STOCK_LEDGER_ENTRY : moves
  MATERIAL ||--o{ STOCK_LEDGER_ENTRY : item
  STORE ||--o{ MATERIAL_ISSUE : issues
  MATERIAL_ISSUE ||--o{ MATERIAL_ISSUE_LINE : lines
  BOQ_ITEM o|--o{ MATERIAL_ISSUE_LINE : compared
  PROJECT ||--o{ WORK_ORDER : orders
  PARTY ||--o{ WORK_ORDER : contractor
  WORK_ORDER ||--o{ WORK_ORDER_LINE : lines
  WORK_ORDER_LINE ||--o{ MEASUREMENT_ENTRY : measured
  WORK_ORDER ||--o{ RA_BILL : bills
  RA_BILL ||--o{ RA_BILL_LINE : lines
  MEASUREMENT_ENTRY o|--o{ RA_BILL_LINE : supports
  RA_BILL ||--o{ RETENTION_ENTRY : retention
  WORK_ORDER ||--o{ CONTRACTOR_ADVANCE : advances
  CONTRACTOR_ADVANCE ||--o{ ADVANCE_RECOVERY : recovery
  RA_BILL ||--o{ ADVANCE_RECOVERY : deducts
  PROJECT ||--o{ LABOUR_ATTENDANCE : attendance
  WORKER ||--o{ LABOUR_ATTENDANCE : marks

  STOCK_LEDGER_ENTRY {
    uuid id
    string movement
    decimal quantity
    decimal average_rate_rupees
    bigint value_paise
    string prev_hash
    string entry_hash
  }
  RA_BILL {
    uuid id
    bigint gross_paise
    bigint cgst_paise
    bigint sgst_paise
    bigint igst_paise
    bigint retention_paise
    bigint advance_recovery_paise
    bigint tds_paise
    bigint net_payable_paise
  }
  ADVANCE_RECOVERY {
    uuid id
    uuid advance_id
    uuid ra_bill_id
    bigint amount_paise
  }
  LABOUR_ATTENDANCE {
    uuid id
    date work_date
    string status
    decimal overtime_hours
  }
  MEASUREMENT_ENTRY {
    uuid id
    string mb_book
    string mb_page
    decimal quantity
  }
```

## Finance

```mermaid
erDiagram
  ORGANIZATION ||--o{ GL_ACCOUNT : chart
  GL_ACCOUNT ||--o{ JOURNAL_LINE : posted_to
  JOURNAL_ENTRY ||--o{ JOURNAL_LINE : lines
  ACCOUNTING_PERIOD ||--o{ JOURNAL_ENTRY : dated
  GL_ACCOUNT ||--o| BANK_ACCOUNT : book
  BANK_ACCOUNT ||--o{ BANK_STATEMENT_IMPORT : imports
  BANK_STATEMENT_IMPORT ||--o{ BANK_STATEMENT_LINE : lines
  BANK_STATEMENT_LINE ||--o{ RECONCILIATION_MATCH : matched
  JOURNAL_LINE ||--o{ RECONCILIATION_MATCH : clears
  PROJECT ||--o{ BUDGET : budgets
  BUDGET ||--o{ BUDGET_LINE : lines
  PROJECT ||--o{ LOAN : loans
  PARTY ||--o{ LOAN : lender
  LOAN ||--o{ EMI_SCHEDULE : versions
  EMI_SCHEDULE ||--o{ EMI_SCHEDULE_LINE : installments
  LOAN ||--o{ LOAN_TRANSACTION : movements
  LOAN ||--o{ LOAN_INTEREST_ACCRUAL : interest
  PARTY ||--o{ PAYMENT : paid
  PAYMENT ||--o{ PAYMENT_ALLOCATION : allocates
  PAYMENT ||--o{ PAYMENT_SOURCE_LINK : proves
  DOCUMENT ||--o{ PAYMENT_SOURCE_LINK : attached
  APPROVAL_REQUEST o|--o{ PAYMENT : approves
  GL_ACCOUNT ||--o{ TALLY_LEDGER_MAP : tally

  JOURNAL_ENTRY {
    uuid id
    date entry_date
    string source
    string status
    int sequence
    string prev_hash
    string entry_hash
  }
  JOURNAL_LINE {
    uuid id
    bigint debit_paise
    bigint credit_paise
    uuid project_id
    uuid unit_id
    uuid party_id
  }
  EMI_SCHEDULE {
    uuid id
    int version
    bigint principal_paise
    int tenure_months
    bigint contractual_emi_paise
    string formula_version
  }
  EMI_SCHEDULE_LINE {
    uuid id
    int installment_number
    bigint opening_principal_paise
    bigint principal_paise
    bigint interest_paise
    bigint emi_paise
    bigint closing_principal_paise
    string status
  }
  PAYMENT {
    uuid id
    date payment_date
    string purpose
    string status
    string channel
    bigint amount_paise
    uuid approval_request_id
  }
  LOAN {
    uuid id
    string kind
    string repayment_style
    bigint sanctioned_paise
    decimal annual_rate_percent
    int tenure_months
  }
```

`JournalEntry` is the single money book. Receipts, payments, invoices, RA bills, interest, loans, capital, retention, advances, and Tally drafts all point at one journal row. Status is not part of the hash.

## Documents, exceptions, sync, search

```mermaid
erDiagram
  ORGANIZATION ||--o{ DOCUMENT : files
  DOCUMENT ||--o| OCR_EXTRACTION : reads
  ORGANIZATION ||--o{ EXCEPTION_RULE : rules
  EXCEPTION_RULE ||--o{ EXCEPTION_ITEM : findings
  PROJECT o|--o{ EXCEPTION_ITEM : where
  ORGANIZATION ||--o{ NOTIFICATION : sends
  USER ||--o{ DEVICE : phones
  DEVICE ||--o{ SYNC_MUTATION : queues
  ORGANIZATION ||--o{ SEARCH_DOCUMENT : index
  ORGANIZATION ||--o{ IMPORT_BATCH : imports

  DOCUMENT {
    uuid id
    string entity_type
    uuid entity_id
    string storage_key
    string sha256
    string ocr_status
  }
  EXCEPTION_RULE {
    uuid id
    string code
    bigint round_figure_multiple_paise
    bigint round_figure_min_paise
    bool flag_saturday
    bool flag_sunday
    decimal area_variance_percent
    decimal wastage_variance_percent
    string plain_language
  }
  EXCEPTION_ITEM {
    uuid id
    string code
    string status
    string entity_type
    uuid entity_id
    string matched_on
  }
  SYNC_MUTATION {
    uuid id
    uuid device_id
    string client_mutation_id
    string entity_type
    json payload
    string status
  }
  NOTIFICATION {
    uuid id
    string channel
    string locale
    string template_key
    string status
  }
```

Exception codes include unmatched bank lines, payments without invoices, invoices without a GRN, area and material mismatches, round-figure payments, and weekend payments. `SearchDocument` is a Cmd-K projection. It is not a financial record.
