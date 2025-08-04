-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 28, 2025 at 12:50 PM
-- Server version: 10.11.13-MariaDB-cll-lve
-- PHP Version: 8.3.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sharingcanol_stuff`
--

-- --------------------------------------------------------

--
-- Table structure for table `Categories`
--

CREATE TABLE `Categories` (
  `category_ID` int(11) NOT NULL,
  `category_name` varchar(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Categories`
--

INSERT INTO `Categories` (`category_ID`, `category_name`) VALUES
(1, 'loan'),
(2, 'sale'),
(3, 'service'),
(4, 'event');

-- --------------------------------------------------------

--
-- Table structure for table `communities`
--

CREATE TABLE `communities` (
  `community_ID` int(11) NOT NULL,
  `community_name` text NOT NULL,
  `community_type` int(11) NOT NULL,
  `password` text NOT NULL,
  `member_ID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `communities`
--

INSERT INTO `communities` (`community_ID`, `community_name`, `community_type`, `password`, `member_ID`) VALUES
(1, 'Montgomery', 1, '', 0),
(2, 'Forden', 1, '', 0),
(3, 'Llandyssil', 1, '', 0),
(21, 'Jeremy&#39;s friends', 0, '123', 85),
(23, 'Jenny&#39;s Friends', 0, '1234', 97),
(24, 'Jeremy&#39;s friends', 0, '123', 86);

-- --------------------------------------------------------

--
-- Table structure for table `community_postcode`
--

CREATE TABLE `community_postcode` (
  `ID` int(11) NOT NULL,
  `community_ID` int(11) NOT NULL,
  `community_postcode` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `community_postcode`
--

INSERT INTO `community_postcode` (`ID`, `community_ID`, `community_postcode`) VALUES
(2, 1, 'SY15 6*'),
(3, 1, 'SY21 *'),
(4, 3, 'SY15 6L*');

-- --------------------------------------------------------

--
-- Table structure for table `members`
--

CREATE TABLE `members` (
  `member_ID` int(10) UNSIGNED NOT NULL,
  `member_fname` text NOT NULL,
  `member_email` text NOT NULL,
  `member_password` text NOT NULL,
  `member_lname` text NOT NULL,
  `member_pcode` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `members`
--

INSERT INTO `members` (`member_ID`, `member_fname`, `member_email`, `member_password`, `member_lname`, `member_pcode`) VALUES
(85, 'Jeremy', 'jeremy@a.b', 'pass', 'Brignell-Thorp', 'SY15 6LQ'),
(97, 'Jenny', 'jenny.brignell-thorp@hotmail.com', '1234', 'Brignell-Thorp', 'SY15 6LQ'),
(103, 'fred', 'fred@a.b', 'pass', 'basset', 'SY15 6PR'),
(104, 'aa', 'aa', 'pass', 'aa', 'aa'),
(105, 'ab', 'ab@a.b', 'pass', 'ab', 'SY15 6PR'),
(106, 'Mark', 'mark@a.b', 'pass', 'Jones', 'SY15 6PR'),
(107, 'Gwil', 'gwil@gwil.com', 'sccCaeliber-123', 'Stephenson ', 'SY156hr');

-- --------------------------------------------------------

--
-- Table structure for table `member_communities`
--

CREATE TABLE `member_communities` (
  `ID` int(11) NOT NULL,
  `member_ID` int(11) NOT NULL,
  `community_ID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `member_communities`
--

INSERT INTO `member_communities` (`ID`, `member_ID`, `community_ID`) VALUES
(161, 96, 1),
(162, 96, 3),
(163, 85, 21),
(164, 96, 21),
(165, 97, 1),
(166, 97, 3),
(167, 97, 22),
(168, 86, 22),
(169, 97, 23),
(171, 86, 24),
(172, 86, 23),
(173, 85, 1),
(174, 85, 3),
(175, 103, 0),
(176, 105, 1),
(177, 106, 1),
(178, 107, 25);

-- --------------------------------------------------------

--
-- Table structure for table `things`
--

CREATE TABLE `things` (
  `thing_ID` int(11) NOT NULL,
  `thing_create_date` date NOT NULL DEFAULT current_timestamp(),
  `thing_title` text NOT NULL,
  `thing_price` int(11) NOT NULL,
  `thing_type` tinyint(11) NOT NULL COMMENT 'for loan = 1, for sale = 2',
  `thing_status` tinyint(4) NOT NULL COMMENT 'available=1, reserved=2, sold=3',
  `thing_ratio` tinyint(4) NOT NULL COMMENT 'percent to community fund\r\n',
  `thing_description` text NOT NULL,
  `thing_image` varchar(40) NOT NULL COMMENT 'filename of image',
  `thing_member_ID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `things`
--

INSERT INTO `things` (`thing_ID`, `thing_create_date`, `thing_title`, `thing_price`, `thing_type`, `thing_status`, `thing_ratio`, `thing_description`, `thing_image`, `thing_member_ID`) VALUES
(31, '2025-07-17', 'blue hammer', 200, 2, 0, 100, 'hardly used, with claw, some scratch marks', '', 85),
(33, '2025-07-17', 'garden spade', 0, 2, 0, 100, 'lovely clean garden spade', '', 85),
(34, '2025-07-17', 'begonia plant in pot', 3, 1, 0, 100, 'rather wilted but alive', '', 85),
(35, '2025-07-17', 'small hobby hammer', 60, 2, 0, 100, 'red with a black end', '', 85),
(44, '2025-07-19', 'hammer', 0, 1, 0, 50, 'little used, surplsu to requirements', '', 96),
(45, '2025-07-19', 'bottle of apple juice', 6, 2, 0, 20, 'home pressed', '', 96),
(48, '2025-07-19', 'Tomato plant', 1, 2, 0, 100, 'Small Green Zebra tomato plant', '', 97),
(49, '2025-07-19', 'Vegetable lasagne', 4, 2, 0, 50, 'Courgette, marrow and onion lasagne for 4 people', '', 97),
(57, '2025-07-23', 'table lamp', 0, 2, 0, 0, 'black', '', 85),
(90, '2025-07-24', 'orange hammer', 3, 2, 0, 100, 'perfect condition', '', 106),
(91, '2025-07-24', 'pink hammer', 1, 1, 0, 0, 'not very strong', '', 106),
(92, '2025-07-28', 'Metal Props', 1, 1, 0, 100, 'Large metal props for holding up building', '', 107);

-- --------------------------------------------------------

--
-- Table structure for table `thing_community`
--

CREATE TABLE `thing_community` (
  `thing_community_ID` int(11) NOT NULL,
  `thing_ID` int(11) NOT NULL,
  `community_ID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `thing_community`
--

INSERT INTO `thing_community` (`thing_community_ID`, `thing_ID`, `community_ID`) VALUES
(33, 0, 85),
(34, 3, 85),
(35, 33, 85),
(36, 81, 2),
(37, 81, 2),
(38, 81, 1),
(39, 81, 3),
(40, 82, 21),
(41, 82, 1),
(42, 83, 1),
(43, 84, 1),
(44, 85, 1),
(45, 85, 21),
(46, 85, 1),
(47, 86, 21),
(48, 86, 1),
(49, 87, 21),
(50, 87, 21),
(51, 87, 1),
(52, 88, 21),
(53, 88, 21),
(54, 88, 1),
(55, 89, 1),
(56, 89, 3),
(59, 33, 21),
(60, 33, 1),
(64, 34, 3),
(89, 31, 21),
(90, 31, 1),
(91, 31, 3),
(92, 35, 21),
(94, 90, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Categories`
--
ALTER TABLE `Categories`
  ADD PRIMARY KEY (`category_ID`);

--
-- Indexes for table `communities`
--
ALTER TABLE `communities`
  ADD PRIMARY KEY (`community_ID`);

--
-- Indexes for table `community_postcode`
--
ALTER TABLE `community_postcode`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `members`
--
ALTER TABLE `members`
  ADD PRIMARY KEY (`member_ID`);

--
-- Indexes for table `member_communities`
--
ALTER TABLE `member_communities`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `things`
--
ALTER TABLE `things`
  ADD UNIQUE KEY `thing_ID` (`thing_ID`);

--
-- Indexes for table `thing_community`
--
ALTER TABLE `thing_community`
  ADD PRIMARY KEY (`thing_community_ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Categories`
--
ALTER TABLE `Categories`
  MODIFY `category_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `communities`
--
ALTER TABLE `communities`
  MODIFY `community_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `community_postcode`
--
ALTER TABLE `community_postcode`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `members`
--
ALTER TABLE `members`
  MODIFY `member_ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=108;

--
-- AUTO_INCREMENT for table `member_communities`
--
ALTER TABLE `member_communities`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=179;

--
-- AUTO_INCREMENT for table `things`
--
ALTER TABLE `things`
  MODIFY `thing_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=93;

--
-- AUTO_INCREMENT for table `thing_community`
--
ALTER TABLE `thing_community`
  MODIFY `thing_community_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
