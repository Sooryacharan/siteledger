You are a senior full-stack architect and product designer. Build a production-ready web platform called "SiteLedger": a CRM and project-finance system for real estate and construction developers. It has two core goals:
1. Full transparency. Every rupee, every sqft and every bag of material can be traced from source to use, with nothing hidden or editable without a trail.
2. Extreme ease of use. A site supervisor, an accountant and a partner should each use it without training.

TECH STACK
- Next.js 14 (App Router) + TypeScript + Tailwind + shadcn/ui
- PostgreSQL + Prisma; Row Level Security for multi-tenant isolation
- Auth: role-based (Owner/Partner, Finance, Project Manager, Site Engineer, Sales, Vendor portal, Customer portal, Auditor read-only)
- Background jobs: BullMQ/Redis; file storage: S3-compatible
- Mobile-responsive and PWA (offline site entries that sync later)
- Indian context: INR with lakh/crore formatting, GST (GSTIN validation, CGST/SGST/IGST, TDS), RERA fields

CORE MODULES
1. Projects & Units
   - Projects, phases, towers, floors, units (flat no., carpet/built-up/super built-up area, facing, status)
   - Planned vs approved vs actually built area, with variance alerts
2. Sales CRM
   - Leads, followups, site visits, bookings, agreements, cancellations, transfers
   - Customer ledger per unit: demand schedule, receipts, dues, interest, receipts with bank reference
   - Customer portal: payment history, documents, construction progress photos
3. Partners & Investors
   - Partner capital, loans, profit-sharing agreements, unit allocation per partner
   - Each partner's ledger and share computed automatically from the agreement rules
4. Vendors & Procurement
   - Vendor master (GST, PAN, bank, KYC docs, related-party flag)
   - Flow: indent, quotation comparison, PO, GRN (goods received), invoice, 3-way match, payment approval, payment
   - Duplicate invoice and duplicate vendor detection (same bank account, GST, PAN or phone)
   - Vendor portal: upload invoices, see payment status
5. Materials & Inventory
   - Stock in/out per site, consumption vs BOQ standard (e.g. cement bags per sqft)
   - Flags for excess consumption or wastage
6. Contractors & Labour
   - Work orders, RA bills, measurement book, retention, advances and recovery, labour attendance
7. Finance
   - Chart of accounts, bank accounts, receipts and payments, journal entries, cash book
   - Bank statement import (CSV/PDF) with auto-reconciliation
   - Project-wise cost centres; budget vs actual; cost per sqft; margin per unit and per project
   - Loans, interest and EMI tracking
   - Tally import/export (XML/Excel) so it can run alongside existing books
8. Documents
   - Every transaction can carry attachments (invoice, agreement, photo, bill); OCR extraction of key fields
9. Dashboards & Reports
   - Owner dashboard: cash position, receivables, payables, project margin, sales velocity
   - Money trail view: click any unit, vendor or partner to see every inflow and outflow, with linked documents
   - Exception centre: unmatched bank entries, payments without invoices, invoices without GRN, area/material mismatches, round-figure or weekend payments
   - Export to PDF/Excel with clean, well-spaced layouts

TRANSPARENCY RULES (non-negotiable)
- Append-only audit log: who, what, when, old value, new value, IP/device. No hard deletes; reversals only.
- Maker-checker approvals with configurable thresholds by amount and role
- Locked periods once closed; reopening needs Owner approval and is logged
- Every payment must link to a source document and an approval
- Read-only Auditor role with full drill-down and exports
- Immutable hash chain on financial entries to detect tampering

USER-FRIENDLINESS RULES
- Plain-language labels, no accounting jargon on non-finance screens
- Clear "what to do next" prompts on every dashboard
- Global search (Cmd-K) across units, customers, vendors and transactions
- Max 3 clicks to any common action; inline editing; bulk upload from Excel templates
- Mobile-first site screens with big buttons: material received, photo progress, attendance
- WhatsApp/email notifications for dues, approvals and payments
- English first, with i18n ready for Telugu, Hindi and Kannada

DELIVERABLES, IN ORDER
1. Architecture doc + ER diagram (Mermaid) + folder structure
2. Prisma schema covering all modules
3. Auth and roles, plus the audit log middleware
4. Build module by module (Projects/Units, Sales CRM, Vendors/Procurement, Finance, Partners, Materials, Contractors, Dashboards), each with seed data, tests and a working UI
5. Docker compose for local run, README and deployment guide

Work incrementally. After each step, show what was built and how to test it, and ask before moving on. Write clean, typed, tested code. Never use placeholder logic for financial calculations.
