-- phpMyAdmin SQL Dump
-- version 5.1.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 27, 2022 at 03:34 AM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 8.1.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `esxlegacy_b8c2fb`
--

-- --------------------------------------------------------

--
-- Table structure for table `bettingbets`
--

CREATE TABLE `bettingbets` (
  `id` int(11) NOT NULL,
  `userId` varchar(255) NOT NULL,
  `keym` varchar(255) NOT NULL,
  `bet` int(1) NOT NULL,
  `odd` double NOT NULL,
  `amount` int(11) NOT NULL,
  `data` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `bettinglist`
--

CREATE TABLE `bettinglist` (
  `keym` varchar(255) NOT NULL,
  `cham` varchar(255) NOT NULL,
  `away` varchar(255) NOT NULL,
  `home` varchar(255) NOT NULL,
  `awayIcon` varchar(255) NOT NULL,
  `homeIcon` varchar(255) NOT NULL,
  `odd0` double NOT NULL,
  `odd1` double NOT NULL,
  `odd2` double NOT NULL,
  `time` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `bettinglist`
--

INSERT INTO `bettinglist` (`keym`, `cham`, `away`, `home`, `awayIcon`, `homeIcon`, `odd0`, `odd1`, `odd2`, `time`) VALUES
('9533c6e55d496c6dad743ccc0b501c1a', 'FIFA World Cup', 'Netherlands', 'Senegal', 'https://dlskitshub.com/wp-content/uploads/2020/05/DLS-Liverpool-Logo-300x300.png', 'https://dlskitshub.com/wp-content/uploads/2020/05/DLS-Liverpool-Logo-300x300.png', 1.75, 5.6, 3.64, 1669035600),
('99ff37c07e84df5d07c6db3c36e29fc0', 'FIFA World Cup', 'Ecuador', 'Qatar', 'https://dlskitshub.com/wp-content/uploads/2020/05/DLS-Liverpool-Logo-300x300.png', 'https://dlskitshub.com/wp-content/uploads/2020/05/DLS-Liverpool-Logo-300x300.png', 2.22, 3.62, 3.36, 1669046400);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bettingbets`
--
ALTER TABLE `bettingbets`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bettinglist`
--
ALTER TABLE `bettinglist`
  ADD PRIMARY KEY (`keym`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bettingbets`
--
ALTER TABLE `bettingbets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
COMMIT;
