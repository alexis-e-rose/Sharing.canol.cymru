## User Journey Phased Implementation Plan

Version: 2025-08-26  
Scope: Align platform to the full user journey in `userjourney.md` using the current system baseline described in `README.md` and `architecture.md`.

---

### 1) Objective
Deliver end-to-end functionality for the specified user journey while maintaining current stability (Phase 2 complete: booking + notifications). Work will be delivered in safe, incremental phases with database migrations, feature flags, and test coverage.

---

### 2) Current Baseline (from README/architecture)
- Complete: Registration, authentication, item listing basics, search, Phase 2 booking system, notifications framework, security framework, documentation, and agentic testing.
- Data model highlights: `members`, `things`, `bookings`, `notifications`, `communities`, `member_communities` (incl. postcode mapping), security helpers.
- Gaps vs user journey: community causes and donation accounting, community fund thresholds and statements, sale reservations and sold-for price, item quantity for sale, loan pricing first-day vs additional days, item visibility per community, “lead community” and enforcement (freeze per community).

---

### 3) Scope and Non-Goals
- In scope: UI/UX changes, DB schema migrations, business logic, notification templates, admin tooling, reconciliation workflows, and access enforcement per community.
- Non-goals: Online payment processing (payments are off-platform, per journey); PWA/mobile apps; API externalization beyond what is needed for web flows.

---

### 4) Data Model Changes (proposed)

New tables and columns are grouped by capability. Exact types may be adapted to match current SQL conventions in `Sharing/database/*.sql`.

1) Community causes and visibility
- community_causes
  - cause_ID (PK)
  - community_ID (FK → communities.community_ID)
  - cause_name (VARCHAR)
  - cause_description (TEXT NULL)
  - is_active (TINYINT, default 1)
  - created_by (member_ID)
  - created_date (DATETIME)

- thing_visibility
  - thing_ID (FK → things.thing_ID)
  - community_ID (FK → communities.community_ID)
  - PRIMARY KEY (thing_ID, community_ID)

2) Member lead community and freeze enforcement
- members
  - lead_community_ID (FK → communities.community_ID, NULL allowed but required by business rule)

- member_communities
  - is_frozen (TINYINT, default 0)  // Freeze state scoped to a membership
  - frozen_reason (VARCHAR NULL)
  - frozen_date (DATETIME NULL)
  - frozen_by (member_ID NULL)

3) Item sale/loan attributes and donation settings
- things (augment)
  - thing_is_for_sale (TINYINT, default 0)
  - thing_is_for_loan (TINYINT, default 1)
  - sale_price (DECIMAL(10,2) NULL)
  - loan_price_first_day (DECIMAL(10,2) NULL)
  - loan_price_additional_day (DECIMAL(10,2) NULL)
  - quantity_available (INT, default 1)  // for sale
  - donation_ratio (ENUM('100','50','20'))  // replaces/aligns with thing_ratio
  - cause_ID (FK → community_causes.cause_ID NULL)

4) Sales workflow and reservations
- sales
  - sale_ID (PK)
  - thing_ID (FK)
  - buyer_ID (member_ID FK)
  - seller_ID (member_ID FK)
  - quantity (INT, default 1)
  - advertised_price (DECIMAL(10,2))
  - sold_price (DECIMAL(10,2) NULL)
  - sale_status (ENUM('reserved','sold','cancelled'))
  - reserve_date (DATETIME)
  - sale_date (DATETIME NULL)

- sale_reservations
  - reservation_ID (PK)
  - thing_ID (FK)
  - buyer_ID (member_ID FK)
  - quantity (INT)
  - status (ENUM('active','cancelled','fulfilled'))
  - created_date (DATETIME)

5) Donation pledges, statements, and reconciliation
- donation_pledges
  - pledge_ID (PK)
  - member_ID (seller_or_lender member)
  - community_ID (FK)
  - cause_ID (FK)
  - source_type (ENUM('sale','loan'))
  - source_ID (FK → sales.sale_ID or bookings.booking_ID)
  - gross_amount (DECIMAL(10,2))
  - donation_ratio (ENUM('100','50','20'))
  - pledged_amount (DECIMAL(10,2))
  - pledge_status (ENUM('pending','statemented','reconciled'))
  - created_date (DATETIME)

- donation_statements
  - statement_ID (PK)
  - member_ID (FK)
  - lead_community_ID (FK)
  - total_amount (DECIMAL(10,2))
  - items_count (INT)
  - threshold (DECIMAL(10,2))  // e.g., £20
  - generated_date (DATETIME)
  - due_date (DATETIME)
  - status (ENUM('issued','reminded','paid','overdue','cancelled'))

- donation_statement_items
  - statement_ID (FK)
  - pledge_ID (FK)
  - PRIMARY KEY (statement_ID, pledge_ID)

- donation_payments
  - payment_ID (PK)
  - member_ID (FK)
  - community_ID (FK)
  - amount (DECIMAL(10,2))
  - method (ENUM('cash','cheque','bank'))
  - reference (VARCHAR NULL)
  - received_by (member_ID FK)
  - received_date (DATETIME)

6) Notifications (templates only; table exists)
- Add templates for donation statements and reminders.

Indexes: add composite indexes for lookups on foreign keys, status, and dates across new tables.

---

### 5) Phased Delivery Plan

Phase 0: Foundations and Feature Flags (1 week)
- Create DB migrations for new tables/columns. Backfill safe defaults.
- Introduce feature flags for: sales flow, donation ledger, statements, freezes.
- Add minimal admin toggles to restrict exposure until features are ready.
Acceptance criteria:
- Migrations apply cleanly on fresh and existing dev databases.
- App starts with no regressions; flags default to off for new features.

Phase 1: Communities & Causes (1-2 weeks)
- Implement lead community selection in `account.php` (required once member belongs to ≥1 geographic community).
- Implement private “community of friends” join flow (name + password + creator email verification already in journey; ensure server checks align with `communities` model).
- Build admin UI to manage `community_causes` (CRUD; restrict to geographic community admins).
- Implement item visibility mapping via `thing_visibility` on `add_listing.php` and enforce in `search.php` queries.
Acceptance criteria:
- Users can join/create private communities and be auto-assigned to geographic communities.
- Admins can configure causes; users see community-specific cause dropdown when listing items.
- Search results only include items visible to user’s communities.

Phase 2: Item Listing Enhancements (1 week)
- Add sale/loan toggles to listings; support both simultaneously if desired.
- Support `loan_price_first_day` and `loan_price_additional_day` input and validation.
- Add `quantity_available` for sale items.
- Add donation ratio selection limited to 100/50/20 and cause selection.
Acceptance criteria:
- New listing/edit flows persist and display enhanced fields.
- Price=0 for loans disables insurance messaging per journey.

Phase 3: Sales Reservation & Completion (1-2 weeks)
- Add a “Reserve” button for sale items in `search.php` and detail views.
- Implement `sale_reservations` and `sales` flows: reserve → seller confirms sold (and enters sold_for price) → quantity decrement.
- Display “reserved” badge; prevent over-reservation beyond available quantity.
- Capture donation pledge for each sale on confirmation based on donation ratio and cause.
Acceptance criteria:
- Reservation status visible; sold items no longer searchable once quantity=0.
- Sold-for price captured; ledger entries created in `donation_pledges`.

Phase 4: Loan Reservation Refinements (0.5-1 week)
- Align loan “reserve” behavior with journey: multiple users may reserve; lender confirms one booking for specified dates.
- Ensure `bookings` remains the source of truth post-confirmation; generate donation pledge on actual approval with calculated `total_cost`.
Acceptance criteria:
- Multiple reservations visible to owner until one is approved.
- Donation pledges created for approved bookings only.

Phase 5: Donation Ledger, Thresholds, and Statements (1-2 weeks)
- Auto-generate `donation_pledges` on sales confirmations and booking approvals.
- Background job (cron) aggregates pending pledges by member → when total ≥ threshold (configurable; default £20) create `donation_statements` and attach items.
- Email statements with clear breakdown; provide member-facing page to review statements and history.
Acceptance criteria:
- Statement issuance works in cron; emails sent via `notifications.php`/`cron_notifications.php`.
- Members see current balance, issued statements, and detailed line items.

Phase 6: Admin Reconciliation and Enforcement (1 week)
- Admin UI to record `donation_payments`, reconcile pledges, and update statement status.
- Add freeze controls on `member_communities` with reason and audit trail.
- Enforce freeze during search/listing visibility for frozen community membership (member cannot see items in that community).
Acceptance criteria:
- Reconciliation updates member balances and marks pledges/statement items as paid.
- Frozen members cannot access items for that community; unfrozen restores access.

Phase 7: QA, Security, and Documentation (continuous; 0.5-1 week hardening)
- Expand automated tests for new flows (sale reserve/sell, loan reserve/approve, statements).
- Add notification template tests (placeholders, rendering).
- Update `README.md`, deployment docs, and admin guides.
Acceptance criteria:
- All new tests pass; no regressions in existing suite.
- Documentation reflects new capabilities and operations.

---

### 6) UI/Endpoint Changes (by file)
- `add_listing.php`: sale/loan toggles, quantity, loan dual-price fields, donation ratio, cause dropdown, visibility selector.
- `search.php`: filter and display visibility-based results; sale “Reserve” action; reserved badge.
- `request_booking.php`: support pre-approval reservation list; finalize approval path; ensure donation pledge creation on approval.
- `my_bookings.php`: show incoming/outgoing reservations for loans; status transitions.
- `account.php`: lead community selection; statement balance view.
- `notifications.php` / `cron_notifications.php`: statement/threshold emails, reminders.
- New admin pages (within `includes`/admin area or dedicated endpoints):
  - Causes management (CRUD)
  - Donation reconciliation (list unpaid pledges, record payments)
  - Membership freeze management (per community)

---

### 7) Business Rules & Calculations
- Donation ratios: 100%, 50%, 20% only.
- Pledge calculation:
  - Sales: pledged_amount = sold_price × ratio.
  - Loans: pledged_amount = total_cost × ratio.
- Thresholds: configurable per deployment; default £20.
- Lead community: required if member belongs to ≥1 geographic community; statements are addressed to lead community admins.
- Visibility: item is visible if (viewer is member of any community listed in `thing_visibility`) AND (viewer not frozen in that community).

---

### 8) Risks & Mitigations
- Concurrency on reservations and quantities → use transactions and row-level locking on `things.quantity_available` and `sale_reservations`.
- Data integrity across pledges/statements → foreign keys and reconciliation invariants; admin tools with clear audit.
- Backwards compatibility with existing listings → default flags and NULL-safe migrations; feature flags to dark-launch.
- Scope creep on payments → keep off-platform per user journey; capture references for admin reconciliation only.

---

### 9) Rollout & Ops
- Migrations: ship Phase 0 migrations first; verify on staging/dev.
- Feature flags: enable per phase after QA.
- Cron: extend existing `cron_notifications.php` to include statement generation and reminders.
- Monitoring: extend logs in `Sharing/server.log` for reservations, statements, and reconciliation events.

---

### 10) Acceptance Criteria (summary)
- Community causes managed by admins; visible and selectable during listing.
- Users can set donation ratio and cause; items have correct visibility controls.
- Sales reservation → sold with sold-for price; accurate quantity handling.
- Loan reservation → owner approval; donations pledged on approval.
- Statement issuance at threshold with email notifications; member balance page.
- Admin reconciliation and freeze enforcement operating as specified.
- All flows covered by automated tests; no regressions; documentation updated.

---

### 11) Estimated Timeline (indicative)
- Phase 0: 1 week
- Phase 1: 1–2 weeks
- Phase 2: 1 week
- Phase 3: 1–2 weeks
- Phase 4: 0.5–1 week
- Phase 5: 1–2 weeks
- Phase 6: 1 week
- Phase 7: 0.5–1 week

Total: ~6–9 weeks elapsed, with opportunities to parallelize UI and backend within phases.

---

### 12) Next Steps
1. Implement Phase 0 migrations with feature flags off.
2. Build Phase 1 admin causes and visibility; wire lead community selection.
3. Iterate through Phases 2–6 with incremental releases and tests.
4. Harden in Phase 7 and update all docs.



---

### 13) Execution Status (Done / TODO)

Done
- Phase 0 foundations: Feature flags file `Sharing/includes/feature_flags.inc` added and wired via `header.inc` and `header2.inc`.
- Phase 1 groundwork: Visibility mapping gated; search/listing now switch between `thing_community` and `thing_visibility` based on `enhanced_visibility` flag.
- Phase 2/3 groundwork: Phase 3 DB schema applied to dev DB (`sharingcanol_stuff_dev`) with tables for causes, visibility, sales, donation ledger/statement/payment, lead community, and membership freeze fields.
- UI gating: `search.php` shows sale Reserve button only when `sales_flow` is enabled; otherwise displays a badge. `add_listing.php` writes visibility using `thing_visibility` only when `enhanced_visibility` is enabled.

TODO
- Phase 1: Admin UI for managing `community_causes`; lead community selection in `account.php`.
- Phase 2: Listing form enhancements (loan first/additional day pricing, quantity for sale, donation ratio 100/50/20 and cause select UI).
- Phase 3: Implement sale reservation and confirmation endpoints; decrement `quantity_available`; capture donation pledges on sale confirmation.
- Phase 4: Multi-reserve UX for loans; owner approval selection flow; pledge creation on approval.
- Phase 5: Cron to aggregate pledges, issue `donation_statements`, send emails; member statement/balance page.
- Phase 6: Admin reconciliation UI for `donation_payments`; enforce per-community freeze in queries and UI.
- Phase 7: Expand tests for new flows; update docs and deployment notes.
