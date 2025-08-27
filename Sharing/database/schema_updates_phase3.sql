-- ======================================================
-- SHARING.CANOL.CYMRU - SCHEMA UPDATES FOR USER JOURNEY (PHASE 3)
-- Community causes, visibility, sales, donations, freezes
-- Safe to run on existing DB; use IF NOT EXISTS and separate ALTERs
-- ======================================================

-- 1) Community Causes
CREATE TABLE IF NOT EXISTS `community_causes` (
  `cause_ID` int(11) NOT NULL AUTO_INCREMENT,
  `community_ID` int(11) NOT NULL,
  `cause_name` varchar(100) NOT NULL,
  `cause_description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_by` int(10) unsigned DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`cause_ID`),
  KEY `idx_causes_community` (`community_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 2) Thing visibility per community
CREATE TABLE IF NOT EXISTS `thing_visibility` (
  `thing_ID` int(11) NOT NULL,
  `community_ID` int(11) NOT NULL,
  PRIMARY KEY (`thing_ID`,`community_ID`),
  KEY `idx_tv_community` (`community_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 3) Lead community on members
ALTER TABLE `members`
  ADD COLUMN IF NOT EXISTS `lead_community_ID` int(11) DEFAULT NULL;

-- 4) Freeze flags on member_communities
ALTER TABLE `member_communities`
  ADD COLUMN IF NOT EXISTS `is_frozen` tinyint(1) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `frozen_reason` varchar(255) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `frozen_date` datetime DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `frozen_by` int(10) unsigned DEFAULT NULL;

-- 5) Listing enhancements for sale/loan and donation settings
ALTER TABLE `things`
  ADD COLUMN IF NOT EXISTS `thing_is_for_sale` tinyint(1) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `thing_is_for_loan` tinyint(1) DEFAULT 1,
  ADD COLUMN IF NOT EXISTS `sale_price` decimal(10,2) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `loan_price_first_day` decimal(10,2) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `loan_price_additional_day` decimal(10,2) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `quantity_available` int(11) DEFAULT 1,
  ADD COLUMN IF NOT EXISTS `donation_ratio` enum('100','50','20') DEFAULT '100',
  ADD COLUMN IF NOT EXISTS `cause_ID` int(11) DEFAULT NULL;

-- 6) Sales reservation and sale records
CREATE TABLE IF NOT EXISTS `sale_reservations` (
  `reservation_ID` int(11) NOT NULL AUTO_INCREMENT,
  `thing_ID` int(11) NOT NULL,
  `buyer_ID` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `status` enum('active','cancelled','fulfilled') NOT NULL DEFAULT 'active',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`reservation_ID`),
  KEY `idx_sr_thing_status` (`thing_ID`, `status`),
  KEY `idx_sr_buyer` (`buyer_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE IF NOT EXISTS `sales` (
  `sale_ID` int(11) NOT NULL AUTO_INCREMENT,
  `thing_ID` int(11) NOT NULL,
  `buyer_ID` int(11) NOT NULL,
  `seller_ID` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `advertised_price` decimal(10,2) NOT NULL,
  `sold_price` decimal(10,2) DEFAULT NULL,
  `sale_status` enum('reserved','sold','cancelled') NOT NULL DEFAULT 'reserved',
  `reserve_date` datetime DEFAULT current_timestamp(),
  `sale_date` datetime DEFAULT NULL,
  PRIMARY KEY (`sale_ID`),
  KEY `idx_sales_thing_status` (`thing_ID`, `sale_status`),
  KEY `idx_sales_buyer` (`buyer_ID`),
  KEY `idx_sales_seller` (`seller_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 7) Donation pledges, statements and payments
CREATE TABLE IF NOT EXISTS `donation_pledges` (
  `pledge_ID` int(11) NOT NULL AUTO_INCREMENT,
  `member_ID` int(11) NOT NULL,
  `community_ID` int(11) NOT NULL,
  `cause_ID` int(11) DEFAULT NULL,
  `source_type` enum('sale','loan') NOT NULL,
  `source_ID` int(11) NOT NULL,
  `gross_amount` decimal(10,2) NOT NULL,
  `donation_ratio` enum('100','50','20') NOT NULL,
  `pledged_amount` decimal(10,2) NOT NULL,
  `pledge_status` enum('pending','statemented','reconciled') NOT NULL DEFAULT 'pending',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`pledge_ID`),
  KEY `idx_dp_member_status` (`member_ID`, `pledge_status`),
  KEY `idx_dp_community` (`community_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE IF NOT EXISTS `donation_statements` (
  `statement_ID` int(11) NOT NULL AUTO_INCREMENT,
  `member_ID` int(11) NOT NULL,
  `lead_community_ID` int(11) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `items_count` int(11) NOT NULL,
  `threshold` decimal(10,2) NOT NULL DEFAULT 20.00,
  `generated_date` datetime DEFAULT current_timestamp(),
  `due_date` datetime DEFAULT NULL,
  `status` enum('issued','reminded','paid','overdue','cancelled') NOT NULL DEFAULT 'issued',
  PRIMARY KEY (`statement_ID`),
  KEY `idx_ds_member_status` (`member_ID`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE IF NOT EXISTS `donation_statement_items` (
  `statement_ID` int(11) NOT NULL,
  `pledge_ID` int(11) NOT NULL,
  PRIMARY KEY (`statement_ID`, `pledge_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE IF NOT EXISTS `donation_payments` (
  `payment_ID` int(11) NOT NULL AUTO_INCREMENT,
  `member_ID` int(11) NOT NULL,
  `community_ID` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `method` enum('cash','cheque','bank') NOT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `received_by` int(11) DEFAULT NULL,
  `received_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`payment_ID`),
  KEY `idx_dp_member_date` (`member_ID`, `received_date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 8) Indexes for performance
CREATE INDEX IF NOT EXISTS `idx_tv_thing` ON `thing_visibility` (`thing_ID`);
CREATE INDEX IF NOT EXISTS `idx_things_cause` ON `things` (`cause_ID`);

-- End of Phase 3 user journey schema updates


