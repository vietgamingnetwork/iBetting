-- phpMyAdmin SQL Dump
-- version 5.1.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 25, 2022 at 04:42 AM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 8.1.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `fivem`
--

-- --------------------------------------------------------

--
-- Table structure for table `bettingbets`
--

CREATE TABLE `bettingbets` (
  `id` int(11) NOT NULL,
  `keym` varchar(255) NOT NULL,
  `bet` int(1) NOT NULL,
  `odd` double NOT NULL,
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;
