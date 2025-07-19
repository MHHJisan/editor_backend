-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 27, 2025 at 02:02 PM
-- Server version: 8.0.36-28
-- PHP Version: 8.1.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `custom-docx`
--

-- --------------------------------------------------------

--
-- Table structure for table `accessrequests`
--

CREATE TABLE `accessrequests` (
  `id` int NOT NULL,
  `document_id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `requested_by` int NOT NULL,
  `requested_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_general_ci DEFAULT 'pending',
  `resolved_by` int DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `requested_permission_type` enum('owner','editor','reviewer','approver','viewer') COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audittrail`
--

CREATE TABLE `audittrail` (
  `id` int NOT NULL,
  `organization_id` int NOT NULL,
  `user_id` int NOT NULL,
  `action_type` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `document_id` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(45) COLLATE utf8mb4_general_ci DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` int NOT NULL,
  `organization_id` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `manager` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('active','inactive') COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `organization_id`, `name`, `manager`, `created_at`, `status`) VALUES
(10, 3, 'Engineering', NULL, '2025-04-17 03:40:41', 'active'),
(11, 3, 'Design', NULL, '2025-04-17 03:46:12', 'active'),
(12, 4, 'Cloud', NULL, '2025-04-22 12:13:14', 'active'),
(13, 3, 'Marketing', NULL, '2025-05-03 01:38:06', 'inactive'),
(14, 23, 'Engineering', NULL, '2025-05-03 06:04:03', 'inactive'),
(15, 23, 'Human Resource', NULL, '2025-05-03 06:44:00', 'active'),
(16, 23, 'Design', NULL, '2025-05-03 06:44:18', 'inactive'),
(17, 23, 'Marketing', NULL, '2025-05-03 06:44:49', 'active'),
(18, 23, 'Finance', NULL, '2025-05-03 06:45:19', 'inactive'),
(19, 23, 'Finance1', NULL, '2025-05-04 14:43:42', 'inactive'),
(20, 23, 'Finance3', NULL, '2025-05-04 14:45:12', 'inactive'),
(21, 23, 'design1', NULL, '2025-05-05 11:27:32', 'inactive'),
(22, 23, 'design3', NULL, '2025-05-05 11:27:56', 'active'),
(23, 23, 'design5', NULL, '2025-05-12 00:22:14', 'active'),
(24, 23, 'SAM1', 21, '2025-05-13 18:23:31', 'active'),
(25, 23, 'Front', 36, '2025-05-13 18:28:02', 'active'),
(26, 23, 'design7', 36, '2025-05-15 21:20:00', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `documentpermissions`
--

CREATE TABLE `documentpermissions` (
  `id` int NOT NULL,
  `document_id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `user_id` int NOT NULL,
  `permission_type` enum('author','editor','reviewer','approver','viewer') COLLATE utf8mb4_general_ci NOT NULL,
  `assigned_by` int NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('active','inactive') COLLATE utf8mb4_general_ci DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `documentpermissions`
--

INSERT INTO `documentpermissions` (`id`, `document_id`, `user_id`, `permission_type`, `assigned_by`, `assigned_at`, `status`) VALUES
(57, '767bf162-cf24-4f83-af67-c11337f099f4', 21, 'author', 21, '2025-05-03 06:29:47', 'active'),
(58, 'cb0d5ffa-f806-45d3-bf98-73a123197002', 21, 'author', 21, '2025-05-03 06:30:39', 'active'),
(59, 'df7b10cb-8875-4ccc-97f6-1720e318e405', 21, 'author', 21, '2025-05-16 15:09:21', 'active'),
(60, '69acc04b-b6c8-41c6-803c-8d4b45642187', 21, 'author', 21, '2025-05-18 13:32:53', 'active'),
(61, 'bcb80f8e-1eea-4d63-a77b-98e1b67bf682', 21, 'author', 21, '2025-05-18 13:34:52', 'active'),
(62, '372d237d-9809-44e5-8e05-55f077bce798', 21, 'author', 21, '2025-05-18 13:37:23', 'active'),
(63, 'd508fbfb-02d1-4c05-a45b-1d7aa5eff207', 21, 'author', 21, '2025-05-18 14:07:15', 'active'),
(64, 'c105a6ff-2134-4907-b501-f0ebf727a0e1', 21, 'author', 21, '2025-05-23 17:35:04', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `documentreferences`
--

CREATE TABLE `documentreferences` (
  `id` int NOT NULL,
  `document_id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `referenced_document_id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `documentrevisions`
--

CREATE TABLE `documentrevisions` (
  `id` int NOT NULL,
  `document_id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `revision_number` decimal(3,1) NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `elements` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE `documents` (
  `document_id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `organization_id` int NOT NULL,
  `template_id` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `elements` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `current_revision` decimal(3,1) DEFAULT '1.0',
  `created_by` int NOT NULL,
  `folder_id` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` enum('draft','in_review','for_approval','rejected','approved','published') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'draft',
  `cover_page_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin
) ;

--
-- Dumping data for table `documents`
--

INSERT INTO `documents` (`document_id`, `organization_id`, `template_id`, `title`, `content`, `elements`, `current_revision`, `created_by`, `folder_id`, `created_at`, `updated_at`, `status`, `cover_page_data`) VALUES
('05da83d2-2407-4cda-8927-a79c00af2611', 3, NULL, 'New', '\"<br>\"', '{\"comments\":[],\"suggestedEdits\":[]}', 1.0, 8, 0, '2025-04-07 10:35:26', '2025-04-07 10:35:26', 'draft', NULL),
('06fcbcf0-5dfb-4157-99a6-de78ee16f443', 3, NULL, 'test', '\"<br>\"', '{\"comments\":[],\"suggestedEdits\":[]}', 1.0, 8, 0, '2025-04-07 02:23:21', '2025-04-07 02:44:14', 'draft', NULL),
('372d237d-9809-44e5-8e05-55f077bce798', 23, '702d87e1-e186-4b4c-b1b3-37d723f8a3fc', '1', '\"ABC\"', '{\"comments\":[],\"suggestedEdits\":[]}', 1.0, 21, NULL, '2025-05-18 13:37:23', '2025-05-18 13:37:28', 'published', NULL),
('69acc04b-b6c8-41c6-803c-8d4b45642187', 23, '14be2151-9cd0-4a6c-9ea3-dc390ab30e8e', '1', '\"none\"', '{\"comments\":[],\"suggestedEdits\":[]}', 1.0, 21, NULL, '2025-05-18 13:32:53', '2025-05-18 13:32:59', 'published', NULL),
('767bf162-cf24-4f83-af67-c11337f099f4', 23, NULL, 'Test Document 1', '\"<span class=\\\"highlighted-text\\\" data-comment-id=\\\"comment-1746886566130-08qjr09ao\\\" contenteditable=\\\"false\\\" style=\\\"background-color: lightgreen;\\\">sedrftghjk</span><div><br></div><div><br></div>\"', '{\"comments\":[{\"id\":\"comment-1746886566130-08qjr09ao\",\"type\":\"comment\",\"user\":\"admin@gmail.com\",\"selectedText\":\"sedrftghjk\",\"text\":\"jhgjhfgdfd\",\"position\":{\"top\":77.58334350585938,\"selectedText\":\"sedrftghjk\"},\"status\":\"open\",\"replies\":[]}],\"suggestedEdits\":[]}', 1.0, 21, NULL, '2025-05-03 06:29:47', '2025-05-10 14:16:09', 'draft', NULL),
('bcb80f8e-1eea-4d63-a77b-98e1b67bf682', 23, '702d87e1-e186-4b4c-b1b3-37d723f8a3fc', '1', '\"ABC\"', '{\"comments\":[],\"suggestedEdits\":[]}', 1.0, 21, NULL, '2025-05-18 13:34:52', '2025-05-18 13:34:54', 'published', NULL),
('c105a6ff-2134-4907-b501-f0ebf727a0e1', 23, '1bf49f32-3725-4c09-b236-cee78404c994', 'a', '\"Hekjhjh&nbsp;<div>ghgh <span class=\\\"highlighted-text\\\" data-suggestededit-id=\\\"suggestededit-1748021733465-8ty96pnzq\\\" contenteditable=\\\"false\\\" style=\\\"background-color: lightblue;\\\"><ins>ghgh gh </ins><del>g</del></span>ghgh e</div>\"', '{\"comments\":[],\"suggestedEdits\":[{\"id\":\"suggestededit-1748021733465-8ty96pnzq\",\"type\":\"suggestededit\",\"user\":\"admin@gmail.com\",\"selectedText\":\"g\",\"text\":\"ghgh gh \",\"position\":{\"top\":101.1875,\"selectedText\":\"g\"},\"status\":\"pending\",\"replies\":[]}]}', 1.0, 21, NULL, '2025-05-23 17:35:04', '2025-05-23 17:35:50', 'published', NULL),
('cb0d5ffa-f806-45d3-bf98-73a123197002', 23, NULL, 'Test Document 2', '\"<br>\"', '{\"comments\":[],\"suggestedEdits\":[]}', 1.0, 21, NULL, '2025-05-03 06:30:39', '2025-05-03 06:30:39', 'draft', NULL),
('d508fbfb-02d1-4c05-a45b-1d7aa5eff207', 23, '702d87e1-e186-4b4c-b1b3-37d723f8a3fc', 'e', '\"ABC\"', '{\"comments\":[],\"suggestedEdits\":[]}', 1.0, 21, NULL, '2025-05-18 14:07:15', '2025-05-18 14:07:15', 'draft', NULL),
('df7b10cb-8875-4ccc-97f6-1720e318e405', 23, '702d87e1-e186-4b4c-b1b3-37d723f8a3fc', '1', '\"Hello Husi<span class=\\\"highlighted-text\\\" data-comment-id=\\\"comment-1747408180789-nb9nu0caw\\\" contenteditable=\\\"false\\\" style=\\\"background-color: lightgreen;\\\">a</span>n&nbsp;\"', '{\"comments\":[{\"id\":\"comment-1747408180789-nb9nu0caw\",\"type\":\"comment\",\"user\":\"admin@gmail.com\",\"selectedText\":\"a\",\"text\":\"change to Belal\",\"position\":{\"top\":77.1875,\"selectedText\":\"a\"},\"status\":\"open\",\"replies\":[]}],\"suggestedEdits\":[]}', 1.0, 21, NULL, '2025-05-16 15:09:21', '2025-05-16 15:09:40', 'draft', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `eventdocuments`
--

CREATE TABLE `eventdocuments` (
  `id` int NOT NULL,
  `event_id` int NOT NULL,
  `document_id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `eventparticipants`
--

CREATE TABLE `eventparticipants` (
  `id` int NOT NULL,
  `event_id` int NOT NULL,
  `user_id` int NOT NULL,
  `status` enum('invited','accepted','declined') COLLATE utf8mb4_general_ci DEFAULT 'invited'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `id` int NOT NULL,
  `organization_id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `created_by` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('scheduled','canceled','completed') COLLATE utf8mb4_general_ci DEFAULT 'scheduled'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invited_users`
--

CREATE TABLE `invited_users` (
  `id` int NOT NULL,
  `organization_id` int NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `message` text COLLATE utf8mb4_general_ci,
  `password_hash` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `department` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `role` enum('admin','author','project_manager','reviewer','approver','viewer') COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('invited','pending') COLLATE utf8mb4_general_ci DEFAULT 'invited'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `invited_users`
--

INSERT INTO `invited_users` (`id`, `organization_id`, `email`, `message`, `password_hash`, `first_name`, `last_name`, `department`, `role`, `created_at`, `status`) VALUES
(4, 3, 'Asds@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, '2025-05-03 01:39:00', 'invited'),
(5, 24, 'zxcxz@sdfsd.com', NULL, NULL, NULL, NULL, NULL, NULL, '2025-05-03 06:20:12', 'invited'),
(6, 23, 'alice.super@test.com', NULL, NULL, NULL, NULL, NULL, 'reviewer', '2025-05-03 06:40:28', 'invited'),
(7, 23, 'bob.demo@test.com', NULL, NULL, NULL, NULL, NULL, 'viewer', '2025-05-03 06:40:53', 'invited'),
(8, 23, 'cristine.manager@test.com', NULL, NULL, NULL, NULL, NULL, NULL, '2025-05-03 06:42:38', 'invited'),
(11, 23, 'carlos.m@demo.test', NULL, '$2b$10$vmYJO.cu0QilRt5DrLdcq.ksjm4eNJU1nHbUmo2nPuNwffE/acTJi', 'Carlos ', 'Mendoza', 'Marketing', 'viewer', '2025-05-03 10:50:42', 'pending');

-- --------------------------------------------------------

--
-- Table structure for table `noterecipients`
--

CREATE TABLE `noterecipients` (
  `id` int NOT NULL,
  `note_id` int NOT NULL,
  `recipient_id` int NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `status` enum('delivered','read') COLLATE utf8mb4_general_ci DEFAULT 'delivered'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notes`
--

CREATE TABLE `notes` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `document_id` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `content` text COLLATE utf8mb4_general_ci NOT NULL,
  `is_private` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `organizationfolders`
--

CREATE TABLE `organizationfolders` (
  `id` int NOT NULL,
  `organization_id` int NOT NULL,
  `folder_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `folder_path` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `class` enum('document','template') COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `organizations`
--

CREATE TABLE `organizations` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin
) ;

--
-- Dumping data for table `organizations`
--

INSERT INTO `organizations` (`id`, `name`, `created_at`, `settings`) VALUES
(3, 'test company', '2025-04-07 02:06:52', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(4, 'sam', '2025-04-08 01:36:58', '{\"general\":{\"timezone\":\"America/Toronto\",\"default_language\":\"en\"}}'),
(5, 'KD', '2025-04-11 22:40:27', '{\"general\":{\"timezone\":\"America/New_York\",\"default_language\":\"en\"}}'),
(6, 'ASDS', '2025-04-12 04:36:53', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(7, 'ASDS', '2025-04-17 03:52:24', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(8, 'Honda', '2025-05-01 00:51:51', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(9, 'Honda', '2025-05-01 00:51:59', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(10, 'Honda', '2025-05-01 01:13:06', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(11, 'Honda', '2025-05-01 01:13:38', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(12, 'Honda', '2025-05-01 01:14:26', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(13, 'Honda', '2025-05-01 01:15:12', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(14, 'Honda', '2025-05-01 01:16:01', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(15, 'honda', '2025-05-01 01:17:08', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(16, 'honda', '2025-05-01 01:22:20', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(17, 'honda', '2025-05-01 01:23:15', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(18, '565', '2025-05-01 11:36:04', '{\"general\":{\"timezone\":\"America/Toronto\",\"default_language\":\"en\"}}'),
(19, 'doc', '2025-05-02 02:11:49', '{\"general\":{\"timezone\":\"America/Toronto\",\"default_language\":\"en\"}}'),
(20, '123', '2025-05-02 02:36:00', '{\"general\":{\"timezone\":\"America/New_York\",\"default_language\":\"en\"}}'),
(21, '123', '2025-05-02 02:36:04', '{\"general\":{\"timezone\":\"America/New_York\",\"default_language\":\"en\"}}'),
(22, '123dfdf', '2025-05-02 02:36:30', '{\"general\":{\"timezone\":\"America/New_York\",\"default_language\":\"en\"}}'),
(23, 'Sample Corporation', '2025-05-02 14:20:16', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(24, 'asds', '2025-05-03 06:19:33', '{\"general\":{\"timezone\":\"Asia/Manila\",\"default_language\":\"en\"}}'),
(25, 'doc', '2025-05-03 23:46:58', '{\"general\":{\"timezone\":\"America/Toronto\",\"default_language\":\"en\"}}'),
(26, 'doc', '2025-05-03 23:47:00', '{\"general\":{\"timezone\":\"America/Toronto\",\"default_language\":\"en\"}}'),
(27, 'doc', '2025-05-03 23:47:01', '{\"general\":{\"timezone\":\"America/Toronto\",\"default_language\":\"en\"}}'),
(28, 'sam', '2025-05-03 23:47:56', '{\"general\":{\"timezone\":\"America/Toronto\",\"default_language\":\"en\"}}'),
(29, 'sam', '2025-05-03 23:47:57', '{\"general\":{\"timezone\":\"America/Toronto\",\"default_language\":\"en\"}}'),
(30, '1', '2025-05-04 01:01:36', '{\"general\":{\"timezone\":\"America/Toronto\",\"default_language\":\"en\"}}'),
(31, '1', '2025-05-04 01:01:37', '{\"general\":{\"timezone\":\"America/Toronto\",\"default_language\":\"en\"}}');

-- --------------------------------------------------------

--
-- Table structure for table `refresh_tokens`
--

CREATE TABLE `refresh_tokens` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `refresh_tokens`
--

INSERT INTO `refresh_tokens` (`id`, `user_id`, `token`, `expires_at`, `created_at`) VALUES
(150, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJpYXQiOjE3NDc4ODA2NDcsImV4cCI6MTc0ODQ4NTQ0N30.Xx8JKdJ4YGvNthz5l1se_DAqkShFgdi3OkpMfnlyc-U', '2025-05-29 02:24:08', '2025-05-22 02:24:07'),
(151, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJpYXQiOjE3NDc5MDczMzUsImV4cCI6MTc0ODUxMjEzNX0.Q3au-Mkxc8OSwO6bWi1-cexQPJKVfSG1QGTQK4Qezlc', '2025-05-29 09:48:56', '2025-05-22 09:48:55'),
(152, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJpYXQiOjE3NDgwMDE1MzAsImV4cCI6MTc0ODYwNjMzMH0.mctS-pP95E8eq47Y1tI2vf44Avnjmf8YMFdZt-In6PU', '2025-05-30 11:58:51', '2025-05-23 11:58:50');

-- --------------------------------------------------------

--
-- Table structure for table `reviewassignments`
--

CREATE TABLE `reviewassignments` (
  `id` int NOT NULL,
  `review_stage_id` int NOT NULL,
  `user_id` int NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  `status` enum('pending','completed','rejected') COLLATE utf8mb4_general_ci DEFAULT 'pending',
  `is_mandatory` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviewstages`
--

CREATE TABLE `reviewstages` (
  `id` int NOT NULL,
  `document_id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `stage_order` int NOT NULL,
  `stage_type` enum('peer_review','team_review','approval') COLLATE utf8mb4_general_ci NOT NULL,
  `is_mandatory` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `taskassignments`
--

CREATE TABLE `taskassignments` (
  `id` int NOT NULL,
  `task_id` varchar(225) COLLATE utf8mb4_general_ci NOT NULL,
  `assigned_to` int NOT NULL,
  `assigned_by` int NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  `status` enum('pending','in_progress','completed') COLLATE utf8mb4_general_ci DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `taskassignments`
--

INSERT INTO `taskassignments` (`id`, `task_id`, `assigned_to`, `assigned_by`, `assigned_at`, `completed_at`, `status`) VALUES
(13, '90a9e16f-cd19-4873-bda2-f24dd9ee97d5', 21, 21, '2025-05-03 06:29:47', NULL, 'pending'),
(14, '45cd0dd4-e009-477a-83da-da55eda5f8eb', 21, 21, '2025-05-03 06:30:39', NULL, 'pending'),
(15, 'edebad47-3991-4fad-bdc6-6922aff19c2e', 21, 21, '2025-05-16 15:09:21', NULL, 'pending'),
(16, 'f384f6ce-ce96-48ff-a7c7-085fcfe45a10', 21, 21, '2025-05-18 13:32:53', NULL, 'pending'),
(17, '2cd99a00-8229-440a-ad89-6ac2b0dbe6ff', 21, 21, '2025-05-18 13:34:52', NULL, 'pending'),
(18, '800d928e-466d-4d8d-8bff-b81d3b1a2bd5', 21, 21, '2025-05-18 13:37:23', NULL, 'pending'),
(19, 'ce17f13a-9451-4a39-b94d-e7888d9a0458', 21, 21, '2025-05-18 14:07:15', NULL, 'pending'),
(20, 'f0a9da29-7643-45e2-befd-fc2b68ad3e40', 21, 21, '2025-05-23 17:35:04', NULL, 'pending');

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `organization_id` int NOT NULL,
  `document_id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci,
  `due_date` date DEFAULT NULL,
  `priority` enum('low','medium','high') COLLATE utf8mb4_general_ci DEFAULT 'medium',
  `created_by` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('not_started','in_progress','completed') COLLATE utf8mb4_general_ci DEFAULT 'not_started'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `organization_id`, `document_id`, `title`, `description`, `due_date`, `priority`, `created_by`, `created_at`, `status`) VALUES
('2cd99a00-8229-440a-ad89-6ac2b0dbe6ff', 23, 'bcb80f8e-1eea-4d63-a77b-98e1b67bf682', '1', NULL, NULL, 'medium', 21, '2025-05-18 13:34:52', 'not_started'),
('45cd0dd4-e009-477a-83da-da55eda5f8eb', 23, 'cb0d5ffa-f806-45d3-bf98-73a123197002', 'Task 2', 'Description', NULL, 'medium', 21, '2025-05-03 06:30:39', 'not_started'),
('800d928e-466d-4d8d-8bff-b81d3b1a2bd5', 23, '372d237d-9809-44e5-8e05-55f077bce798', '1', NULL, NULL, 'medium', 21, '2025-05-18 13:37:23', 'not_started'),
('90a9e16f-cd19-4873-bda2-f24dd9ee97d5', 23, '767bf162-cf24-4f83-af67-c11337f099f4', 'Task 1', 'Description', NULL, 'medium', 21, '2025-05-03 06:29:47', 'not_started'),
('ce17f13a-9451-4a39-b94d-e7888d9a0458', 23, 'd508fbfb-02d1-4c05-a45b-1d7aa5eff207', 'd', 'd', NULL, 'medium', 21, '2025-05-18 14:07:15', 'not_started'),
('edebad47-3991-4fad-bdc6-6922aff19c2e', 23, 'df7b10cb-8875-4ccc-97f6-1720e318e405', '1', NULL, NULL, 'medium', 21, '2025-05-16 15:09:21', 'not_started'),
('f0a9da29-7643-45e2-befd-fc2b68ad3e40', 23, 'c105a6ff-2134-4907-b501-f0ebf727a0e1', 'a', NULL, NULL, 'medium', 21, '2025-05-23 17:35:04', 'not_started'),
('f384f6ce-ce96-48ff-a7c7-085fcfe45a10', 23, '69acc04b-b6c8-41c6-803c-8d4b45642187', '1', NULL, NULL, 'medium', 21, '2025-05-18 13:32:53', 'not_started');

-- --------------------------------------------------------

--
-- Table structure for table `templates`
--

CREATE TABLE `templates` (
  `id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `organization_id` int NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Untitled Template',
  `description` text COLLATE utf8mb4_general_ci,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `template_structure` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `required_approvers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `impact` longtext COLLATE utf8mb4_general_ci,
  `notes` text COLLATE utf8mb4_general_ci,
  `template_approvers` longtext COLLATE utf8mb4_general_ci,
  `comments` longtext COLLATE utf8mb4_general_ci,
  `created_by` int NOT NULL,
  `category_id` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` enum('draft','submitted','in_progress','for_publish','rejected','published','archived') COLLATE utf8mb4_general_ci DEFAULT 'draft'
) ;

--
-- Dumping data for table `templates`
--

INSERT INTO `templates` (`id`, `organization_id`, `name`, `description`, `content`, `template_structure`, `required_approvers`, `impact`, `notes`, `template_approvers`, `comments`, `created_by`, `category_id`, `created_at`, `updated_at`, `status`) VALUES
('002d14bd-374d-4423-bccc-7269804243d4', 23, 'Dan18May', 'Hello 18May', '{}', '{\"locked_elements\":{\"content\":false,\"fontSize\":false,\"fontStyle\":false,\"borders\":false,\"headerFooter\":false},\"allowAttachments\":false,\"includeTableOfContents\":false}', '[{\"key\":0,\"department\":\"Engineering\",\"participants\":[{\"userId\":25,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":true,\"stage\":1,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null,\"dueDate\":null},{\"key\":1,\"department\":\"Marketing\",\"participants\":[{\"userId\":26,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":true,\"stage\":2,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null,\"dueDate\":null},{\"key\":2,\"department\":\"Front\",\"participants\":[{\"userId\":37,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":false,\"stage\":3,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null,\"dueDate\":null}]', '{\"departmentImpacts\":[],\"affectedSystems\":[],\"implementationEffort\":\"medium\",\"trainingRequired\":false,\"impactNotes\":\"\"}', '', NULL, NULL, 21, 11, '2025-05-18 13:26:21', '2025-05-18 13:45:46', 'submitted'),
('05daab85-2239-49d6-900a-87b22914e766', 23, '123MAY', '123MAY', '{\"content\":\"<span class=\\\"highlighted-text\\\" data-comment-id=\\\"comment-1747999162454-wrx59nfkx\\\" data-fragment-id=\\\":~:text=2\\\">2</span>3MA<span class=\\\"highlighted-text\\\" data-comment-id=\\\"comment-1748021907337-ewkdcll6d\\\" data-fragment-id=\\\":~:text=23MA,y\\\">y</span>\",\"comments\":[{\"id\":\"comment-1747999162454-wrx59nfkx\",\"text\":\"24MAY\",\"highlightedText\":\"2\",\"fragmentId\":\":~:text=2\",\"timestamp\":\"2025-05-23T11:19:22.454Z\",\"user\":\"Current User\",\"email\":\"admin@gmail.com\",\"status\":\"open\"},{\"id\":\"comment-1748021907337-ewkdcll6d\",\"text\":\"Change 36MAYT\",\"highlightedText\":\"y\",\"fragmentId\":\":~:text=23MA,y\",\"timestamp\":\"2025-05-23T17:38:27.337Z\",\"user\":\"Current User\",\"email\":\"admin@gmail.com\",\"status\":\"open\"}]}', '{\"locked_elements\":{\"content\":false,\"fontSize\":false,\"fontStyle\":false,\"borders\":false,\"headerFooter\":false},\"allowAttachments\":false,\"includeTableOfContents\":false}', '[{\"key\":0,\"department\":\"Design\",\"mandatory\":true,\"stage\":1,\"participants\":[]},{\"key\":1,\"department\":\"design1\",\"mandatory\":false,\"stage\":1,\"participants\":[]}]', '{\"departmentImpacts\":[],\"affectedSystems\":[],\"implementationEffort\":\"medium\",\"trainingRequired\":false}', '', '[{\"userId\":26,\"name\":\"Mike Tyson\",\"email\":\"mike.editor@test.com\",\"department\":\"Marketing\",\"role\":\"template_approver\"}]', '{\"content\":\"<span class=\\\"highlighted-text\\\" data-comment-id=\\\"comment-1747999162454-wrx59nfkx\\\" data-fragment-id=\\\":~:text=2\\\">2</span>3MA<span class=\\\"highlighted-text\\\" data-comment-id=\\\"comment-1748021907337-ewkdcll6d\\\" data-fragment-id=\\\":~:text=23MA,y\\\">y</span>\",\"comments\":[{\"id\":\"comment-1747999162454-wrx59nfkx\",\"text\":\"24MAY\",\"highlightedText\":\"2\",\"fragmentId\":\":~:text=2\",\"timestamp\":\"2025-05-23T11:19:22.454Z\",\"user\":\"Current User\",\"email\":\"admin@gmail.com\",\"status\":\"open\"},{\"id\":\"comment-1748021907337-ewkdcll6d\",\"text\":\"Change 36MAYT\",\"highlightedText\":\"y\",\"fragmentId\":\":~:text=23MA,y\",\"timestamp\":\"2025-05-23T17:38:27.337Z\",\"user\":\"Current User\",\"email\":\"admin@gmail.com\",\"status\":\"open\"}]}', 21, 11, '2025-05-23 11:17:29', '2025-05-23 17:38:27', 'submitted'),
('0d132eb1-6cdd-41d0-a254-cafce5f347cd', 23, '1', '2', '{\"content\":\"TEST ONE\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-20T19:20:17.837Z\"}', '{\"locked_elements\":{\"content\":true,\"fontSize\":false,\"fontStyle\":false,\"borders\":false,\"headerFooter\":false},\"allowAttachments\":false,\"includeTableOfContents\":false}', '[{\"key\":0,\"department\":\"Engineering\",\"participants\":[{\"userId\":24,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":false,\"stage\":1,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null,\"dueDate\":null}]', '{\"departmentImpacts\":[],\"affectedSystems\":[],\"implementationEffort\":\"medium\",\"trainingRequired\":false}', '', NULL, NULL, 21, NULL, '2025-05-20 19:19:54', '2025-05-20 19:20:26', 'submitted'),
('14be2151-9cd0-4a6c-9ea3-dc390ab30e8e', 23, 'TEST 2 18MAy', 'test', '{\"content\":\"<h3 id=\\\"heading-0\\\">Subject1</h3><div><br></div>Hello Dan<div><br></div><h3 id=\\\"heading-1\\\">Subject2</h3><div><br></div><div><br></div><div><br></div><div><br></div><div>fgfhg&nbsp;</div><div>aghgs&nbsp;</div><div>agghgf&nbsp;<br><br></div><div><br></div><h3 id=\\\"heading-2\\\">subject3</h3><div><br></div>\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-18T13:49:54.260Z\"}', '{\"locked_elements\":[],\"allowAttachments\":false,\"includeTableOfContents\":true}', '[]', '{\"departmentImpacts\":[],\"affectedSystems\":[],\"implementationEffort\":\"medium\",\"trainingRequired\":false,\"impactNotes\":\"\"}', '', NULL, NULL, 21, 11, '2025-05-15 03:06:04', '2025-05-18 13:50:58', 'submitted'),
('1bf49f32-3725-4c09-b236-cee78404c994', 23, 'Template 2', 'None', '{\"content\":\"\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-03T06:32:38.463Z\"}', '{\"locked_elements\":[],\"allowAttachments\":false,\"includeTableOfContents\":false}', '[]', NULL, '', NULL, NULL, 21, NULL, '2025-05-03 06:32:43', '2025-05-03 06:32:43', 'submitted'),
('2218efc8-0af4-447e-8fd4-55e0d71056ec', 23, '123MAY2787878b ', 'd', '{}', '{\"locked_elements\":{\"content\":false,\"fontSize\":false,\"fontStyle\":false,\"borders\":false,\"headerFooter\":false},\"allowAttachments\":false,\"includeTableOfContents\":false}', '[]', '{\"departmentImpacts\":[],\"affectedSystems\":[],\"implementationEffort\":\"medium\",\"trainingRequired\":false}', '', '[{\"userId\":26,\"name\":\"Mike Tyson\",\"email\":\"mike.editor@test.com\",\"department\":\"Marketing\",\"role\":\"template_approver\"}]', '{}', 21, NULL, '2025-05-23 17:33:29', '2025-05-23 17:33:44', 'submitted'),
('49439597-bb6e-4f19-b914-ea666c4cd6a3', 23, 'My CV', 'cv description', '{\"content\":\"\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-03T10:59:18.453Z\"}', '{\"locked_elements\":[],\"allowAttachments\":true,\"includeTableOfContents\":true}', '[]', NULL, '', NULL, NULL, 21, 15, '2025-05-03 10:59:28', '2025-05-03 10:59:28', 'submitted'),
('69c2fd5f-677a-423d-a360-9712e7585870', 23, 'Template 1', 'Description', '{\"content\":\"\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-03T06:31:55.518Z\"}', '{\"locked_elements\":[],\"allowAttachments\":false,\"includeTableOfContents\":false}', '[]', NULL, 'note', NULL, NULL, 21, NULL, '2025-05-03 06:32:19', '2025-05-03 06:32:19', 'draft'),
('702d87e1-e186-4b4c-b1b3-37d723f8a3fc', 23, '1', '1', '{\"content\":\"ABC\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-08T16:29:27.198Z\"}', '{\"locked_elements\":[],\"allowAttachments\":false,\"includeTableOfContents\":false}', '[{\"key\":0,\"department\":\"Engineering\",\"participants\":[{\"userId\":24,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":false,\"stage\":1,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null}]', NULL, '123', NULL, NULL, 21, 11, '2025-05-08 16:29:44', '2025-05-08 16:29:44', 'submitted'),
('969d5eea-7564-4b45-94f7-bbc3ff58b4f8', 23, 'tester', 'tester', '{\"content\":\"<h2 style=\\\"box-sizing: inherit; border: 0px; font-size: 2.625rem; font-weight: 700; margin-right: 0px; margin-bottom: 0.7em; margin-left: 0px; outline: 0px; padding: 0px; vertical-align: baseline; clear: both; color: rgb(30, 24, 16); line-height: 1.3em; font-family: &quot;Open Sans&quot;, sans-serif;\\\" id=\\\"heading-0\\\">What is Social Engineering?</h2><p style=\\\"box-sizing: inherit; border: 0px; font-size: 16px; margin-right: 0px; margin-bottom: 1.6em; margin-left: 0px; outline: 0px; padding: 0px; vertical-align: baseline; color: rgb(98, 97, 92); font-family: &quot;Work Sans&quot;, sans-serif;\\\">Social engineering refers to the psychological manipulation employed by cybercriminals to influence individuals into divulging confidential information. It is a technique that exploits human emotions, cognitive biases, and trust to gain unauthorized access to sensitive data, often circumventing traditional security measures. Unlike conventional hacking methods, social engineering focuses on the human element, emphasizing the importance of understanding how individuals react in various scenarios.</p><p style=\\\"box-sizing: inherit; border: 0px; font-size: 16px; margin-right: 0px; margin-bottom: 1.6em; margin-left: 0px; outline: 0px; padding: 0px; vertical-align: baseline; color: rgb(98, 97, 92); font-family: &quot;Work Sans&quot;, sans-serif;\\\">One prevalent tactic within social engineering is phishing, where attackers masquerade as legitimate entities, often through emails, to trick recipients into providing personal information or clicking on malicious links. This approach preys on the innate trust individuals place in recognizable brands or colleagues. Phishing schemes often invoke a sense of urgency or fear, prompting targets to act quickly without adequate scrutiny.</p><p style=\\\"box-sizing: inherit; border: 0px; font-size: 16px; margin-right: 0px; margin-bottom: 1.6em; margin-left: 0px; outline: 0px; padding: 0px; vertical-align: baseline; color: rgb(98, 97, 92); font-family: &quot;Work Sans&quot;, sans-serif;\\\">Another common method is pretexting, where the attacker creates a fabricated scenario to engage the target in a manner that feels legitimate. For instance, the hacker might pose as a bank representative requesting verification of account details. This tactic leverages the target’s trust in authority figures, effectively lowering their defenses against divulging sensitive information.</p><p style=\\\"box-sizing: inherit; border: 0px; font-size: 16px; margin-right: 0px; margin-bottom: 1.6em; margin-left: 0px; outline: 0px; padding: 0px; vertical-align: baseline; color: rgb(98, 97, 92); font-family: &quot;Work Sans&quot;, sans-serif;\\\">Baiting, which offers something enticing to lure victims into a trap, is also a noted strategy in the social engineering arsenal. This can manifest in various forms, such as a free download that infects a system with malware or physical devices left in public spaces to entice individuals to connect to unfamiliar networks, thus jeopardizing their cybersecurity.</p><p style=\\\"box-sizing: inherit; border: 0px; font-size: 16px; margin-right: 0px; margin-bottom: 1.6em; margin-left: 0px; outline: 0px; padding: 0px; vertical-align: baseline; color: rgb(98, 97, 92); font-family: &quot;Work Sans&quot;, sans-serif;\\\">Overall, the essence of social engineering lies in its intricate understanding of human behavior. Cybercriminals adept in these tactics can create compelling narratives that compel individuals to relinquish their personal data. Recognizing the psychological factors at play is crucial in fortifying defenses against these manipulative techniques.</p><h2 style=\\\"box-sizing: inherit; border: 0px; font-size: 2.625rem; font-weight: 700; margin-right: 0px; margin-bottom: 0.7em; margin-left: 0px; outline: 0px; padding: 0px; vertical-align: baseline; clear: both; color: rgb(30, 24, 16); line-height: 1.3em; font-family: &quot;Open Sans&quot;, sans-serif;\\\" id=\\\"heading-1\\\">Common Techniques Used by Hackers</h2><p style=\\\"box-sizing: inherit; border: 0px; font-size: 16px; margin-right: 0px; margin-bottom: 1.6em; margin-left: 0px; outline: 0px; padding: 0px; vertical-align: baseline; color: rgb(98, 97, 92); font-family: &quot;Work Sans&quot;, sans-serif;\\\">Social engineering remains a significant threat within the realm of cybersecurity, exploiting human psychology to manipulate individuals into divulging confidential information. One prevalent technique employed by hackers is phishing, which involves sending deceptive emails that appear to come from legitimate sources. These messages often prompt victims to click on malicious links or provide sensitive information such as passwords, financial details, or personal identification. For instance, a well-known case involved a phishing email masquerading as a notification from a bank, leading numerous recipients to unwittingly surrender their login credentials.</p><p style=\\\"box-sizing: inherit; border: 0px; font-size: 16px; margin-right: 0px; margin-bottom: 1.6em; margin-left: 0px; outline: 0px; padding: 0px; vertical-align: baseline; color: rgb(98, 97, 92); font-family: &quot;Work Sans&quot;, sans-serif;\\\">Another tactic frequently utilized by cybercriminals is the creation of fake websites that closely mimic legitimate platforms. These counterfeit sites are designed to deceive users into entering their information, ultimately allowing hackers to capture sensitive data. An illustrative example of this is the use of cloned e-commerce websites during holiday sales, where unsuspecting shoppers may unknowingly provide their credit card details to a fraudulent entity.</p><div><br></div>\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-13T23:48:26.122Z\"}', '{\"locked_elements\":[],\"allowAttachments\":false,\"includeTableOfContents\":false}', '[]', NULL, '', NULL, NULL, 21, 12, '2025-05-13 23:48:37', '2025-05-13 23:48:37', 'submitted'),
('97446740-acb6-45fd-b64c-563d554b5886', 23, 'Document template 2', 'document template description', '{\"content\":\"\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-03T10:57:48.613Z\"}', '{\"locked_elements\":[],\"allowAttachments\":false,\"includeTableOfContents\":false}', '[{\"key\":0,\"department\":\"Engineering\",\"participants\":[{\"userId\":24,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":false,\"stage\":1,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null},{\"key\":1,\"department\":\"Marketing\",\"participants\":[{\"userId\":26,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":false,\"stage\":2,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null}]', NULL, 'notes 123', NULL, NULL, 21, 11, '2025-05-03 10:58:09', '2025-05-03 10:58:09', 'submitted'),
('9d2044f8-e5dc-43ec-be3e-1987a2483e0c', 23, '1', '1', '{\"content\":\"\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-10T01:44:06.563Z\"}', '{\"locked_elements\":[],\"allowAttachments\":false,\"includeTableOfContents\":false}', '[]', NULL, '', NULL, NULL, 21, 11, '2025-05-10 01:44:14', '2025-05-10 01:44:14', 'submitted'),
('ad4f5aa6-c3bf-4c88-ba66-7a5d5cca25c5', 23, 'tire ', 'hello ', '{\"content\":\"bfgfgfg 23MAY25\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-23T17:27:16.059Z\"}', '{\"locked_elements\":{\"content\":true,\"fontSize\":false,\"fontStyle\":true,\"borders\":false,\"headerFooter\":false},\"allowAttachments\":false,\"includeTableOfContents\":false}', '[{\"key\":0,\"department\":\"Design\",\"mandatory\":true,\"stage\":1,\"participants\":[]},{\"key\":1,\"department\":\"Engineering\",\"mandatory\":true,\"stage\":2,\"participants\":[]}]', '{\"departmentImpacts\":[],\"affectedSystems\":[],\"implementationEffort\":\"medium\",\"trainingRequired\":false}', 'hhhh  ', '[]', '{\"content\":\"bfgfgfg 23MAY25\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-23T17:27:16.059Z\"}', 21, 11, '2025-05-23 17:25:38', '2025-05-23 17:32:12', 'draft'),
('ae65773e-d322-43b3-9ca7-d3d396fb6527', 23, 'Resume Template', 'description', '{\"content\":\"\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-03T10:58:39.721Z\"}', '{\"locked_elements\":[],\"allowAttachments\":false,\"includeTableOfContents\":false}', '[{\"key\":0,\"department\":\"Engineering\",\"participants\":[{\"userId\":25,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":false,\"stage\":1,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null}]', '{\"departmentImpacts\":[\"Design\",\"design3\",\"design5\",\"design7\"],\"affectedSystems\":[\"accounting\",\"hr\",\"reporting\"],\"implementationEffort\":\"medium\",\"trainingRequired\":false,\"impactNotes\":\"\"}', '', NULL, NULL, 21, 12, '2025-05-03 10:58:45', '2025-05-20 02:47:15', 'draft'),
('baaeed71-8b64-4da5-931e-947e72d95cb1', 23, 'test', 'test 17May', '{\"content\":\"<h3 id=\\\"heading-0\\\">Introduction</h3><div><br></div>The is a test that was done on 17May<div><br></div><div><br></div><h3>Subject</h3>\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-17T11:40:56.617Z\"}', '{\"locked_elements\":{\"content\":true,\"fontSize\":false,\"fontStyle\":true,\"borders\":false,\"headerFooter\":true},\"allowAttachments\":true,\"includeTableOfContents\":false}', '[{\"key\":1,\"department\":\"Marketing\",\"participants\":[{\"userId\":26,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":true,\"stage\":1,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null,\"dueDate\":\"2025-05-23T04:00:00.000Z\"},{\"key\":0,\"department\":\"Engineering\",\"participants\":[{\"userId\":24,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":true,\"stage\":2,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null,\"dueDate\":\"2025-05-28T04:00:00.000Z\"}]', '{\"departmentImpacts\":[],\"affectedSystems\":[],\"implementationEffort\":\"medium\",\"trainingRequired\":false}', 'Thanks it it looks pretty good ', NULL, NULL, 21, 11, '2025-05-17 11:36:46', '2025-05-17 11:42:56', 'submitted'),
('c59bf16b-d3c1-4387-8ae8-9d693ce553fe', 23, '1', '343', '{\"content\":\"Hello test\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-23T01:25:08.288Z\"}', '{\"locked_elements\":{\"content\":true,\"fontSize\":false,\"fontStyle\":false,\"borders\":true,\"headerFooter\":false},\"allowAttachments\":false,\"includeTableOfContents\":false}', '[{\"key\":0,\"department\":\"Engineering\",\"mandatory\":true,\"stage\":1,\"participants\":[]},{\"key\":1,\"department\":\"Finance\",\"mandatory\":true,\"stage\":2,\"participants\":[]},{\"key\":2,\"department\":\"Finance3\",\"mandatory\":false,\"stage\":1,\"participants\":[]},{\"key\":3,\"department\":\"design5\",\"mandatory\":false,\"stage\":1,\"participants\":[]}]', '{\"departmentImpacts\":[],\"affectedSystems\":[],\"implementationEffort\":\"medium\",\"trainingRequired\":false}', 'ABC', '[{\"userId\":26,\"name\":\"Mike Tyson\",\"email\":\"mike.editor@test.com\",\"department\":\"Marketing\",\"role\":\"template_approver\"}]', '{\"content\":\"Hello test\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-23T01:25:08.288Z\"}', 21, 11, '2025-05-23 01:24:17', '2025-05-23 01:27:15', 'submitted'),
('d79a7f58-4f4f-47fe-b5e4-575766801379', 23, '1', '1', '{\"content\":\"Hello Josh\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-09T13:22:55.630Z\"}', '{\"locked_elements\":[],\"allowAttachments\":false,\"includeTableOfContents\":false}', '[{\"key\":0,\"department\":\"Engineering\",\"participants\":[{\"userId\":24,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":false,\"stage\":1,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null}]', NULL, 'hello vbye', NULL, NULL, 21, 11, '2025-05-09 13:23:48', '2025-05-09 13:23:48', 'submitted'),
('da44c38c-fcc3-46ea-9cfa-10bcfdca635b', 23, 'toaster', 'project', '{\"content\":\"<h2 id=\\\"heading-0\\\" style=\\\"box-sizing: inherit; margin-right: auto; margin-bottom: 32px; margin-left: auto; line-height: 39px; font-family: europa; font-weight: bold; font-size: 26px; color: rgb(17, 17, 17); padding-top: 40px;\\\">The Toaster Project</h2><p style=\\\"box-sizing: inherit; font-size: 21px; line-height: 34.65px; margin: 24px auto; color: rgb(17, 17, 17); font-family: minion-pro, serif;\\\">The victory was short-lived.</p><p style=\\\"box-sizing: inherit; font-size: 21px; line-height: 34.65px; margin: 24px auto; color: rgb(17, 17, 17); font-family: minion-pro, serif;\\\">When it came time to create the <span class=\\\"highlighted-text\\\" data-comment-id=\\\"comment-1747907654445-ts73b87ay\\\" data-fragment-id=\\\":~:text=time%20to%20create%20the,plastic\\\">plastic</span> case for his toaster, Thwaites realized he would need crude oil to make the plastic. This time, he called up BP and asked if they would fly him out to an oil rig and lend him some oil for the project. They immediately refused. It seems oil companies aren’t nearly as generous as iron mines.</p><p style=\\\"box-sizing: inherit; font-size: 21px; line-height: 34.65px; margin: 24px auto; color: rgb(17, 17, 17); font-family: minion-pro, serif;\\\">Thwaites had to settle for collecting plastic scraps and melting them into the shape of his toaster case. This is not as easy as it sounds. The homemade toaster ended up looking more like a melted cake than a kitchen appliance.</p><div><br></div>\",\"comments\":[{\"id\":\"comment-1747907654445-ts73b87ay\",\"text\":\"metal\",\"highlightedText\":\"plastic\",\"fragmentId\":\":~:text=time%20to%20create%20the,plastic\",\"timestamp\":\"2025-05-22T09:54:14.445Z\",\"user\":\"Current User\",\"email\":\"admin@gmail.com\",\"status\":\"open\"}]}', '{\"locked_elements\":{\"content\":true,\"fontSize\":true,\"fontStyle\":false,\"borders\":true,\"headerFooter\":true},\"allowAttachments\":true,\"includeTableOfContents\":true}', '[{\"key\":0,\"department\":\"Design\",\"mandatory\":true,\"stage\":2,\"participants\":[]},{\"key\":1,\"department\":\"Engineering\",\"mandatory\":true,\"stage\":1,\"participants\":[]},{\"key\":2,\"department\":\"Finance\",\"mandatory\":false,\"stage\":1,\"participants\":[]}]', '{\"departmentImpacts\":[],\"affectedSystems\":[],\"implementationEffort\":\"medium\",\"trainingRequired\":false,\"impactNotes\":\"\"}', 'note', '[{\"userId\":26,\"name\":\"Mike Tyson\",\"email\":\"mike.editor@test.com\",\"department\":\"Marketing\",\"role\":\"template_approver\"}]', '{\"content\":\"<h2 id=\\\"heading-0\\\" style=\\\"box-sizing: inherit; margin-right: auto; margin-bottom: 32px; margin-left: auto; line-height: 39px; font-family: europa; font-weight: bold; font-size: 26px; color: rgb(17, 17, 17); padding-top: 40px;\\\">The Toaster Project</h2><p style=\\\"box-sizing: inherit; font-size: 21px; line-height: 34.65px; margin: 24px auto; color: rgb(17, 17, 17); font-family: minion-pro, serif;\\\">The victory was short-lived.</p><p style=\\\"box-sizing: inherit; font-size: 21px; line-height: 34.65px; margin: 24px auto; color: rgb(17, 17, 17); font-family: minion-pro, serif;\\\">When it came time to create the <span class=\\\"highlighted-text\\\" data-comment-id=\\\"comment-1747907654445-ts73b87ay\\\" data-fragment-id=\\\":~:text=time%20to%20create%20the,plastic\\\">plastic</span> case for his toaster, Thwaites realized he would need crude oil to make the plastic. This time, he called up BP and asked if they would fly him out to an oil rig and lend him some oil for the project. They immediately refused. It seems oil companies aren’t nearly as generous as iron mines.</p><p style=\\\"box-sizing: inherit; font-size: 21px; line-height: 34.65px; margin: 24px auto; color: rgb(17, 17, 17); font-family: minion-pro, serif;\\\">Thwaites had to settle for collecting plastic scraps and melting them into the shape of his toaster case. This is not as easy as it sounds. The homemade toaster ended up looking more like a melted cake than a kitchen appliance.</p><div><br></div>\",\"comments\":[{\"id\":\"comment-1747907654445-ts73b87ay\",\"text\":\"metal\",\"highlightedText\":\"plastic\",\"fragmentId\":\":~:text=time%20to%20create%20the,plastic\",\"timestamp\":\"2025-05-22T09:54:14.445Z\",\"user\":\"Current User\",\"email\":\"admin@gmail.com\",\"status\":\"open\"}]}', 21, NULL, '2025-05-22 09:50:37', '2025-05-22 09:54:18', 'submitted'),
('e2efd2fb-c95c-41a4-82ba-a2a969783b55', 23, 'Varun1', 'Example 15MAY', '{\"content\":\"<h3>Subject</h3><div><br></div>Hello Varun\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-17T14:13:31.968Z\"}', '{\"locked_elements\":{\"content\":true,\"fontSize\":false,\"fontStyle\":true,\"borders\":false,\"headerFooter\":true},\"allowAttachments\":true,\"includeTableOfContents\":false}', '[{\"key\":1,\"department\":\"Marketing\",\"participants\":[{\"userId\":26,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":true,\"stage\":1,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null,\"dueDate\":null},{\"key\":0,\"department\":\"Engineering\",\"participants\":[{\"userId\":25,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":true,\"stage\":2,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null,\"dueDate\":null}]', '{\"departmentImpacts\":[],\"affectedSystems\":[],\"implementationEffort\":\"medium\",\"trainingRequired\":false}', 'we info from Simon', NULL, NULL, 21, 11, '2025-05-17 14:07:45', '2025-05-17 14:17:36', 'submitted'),
('f6c65fd7-6330-49b9-a54c-01343be32431', 23, 'BOM', '1', '{\"content\":\"bye\",\"paperSize\":\"A4\",\"lastModified\":\"2025-05-13T18:32:43.952Z\"}', '{\"locked_elements\":[],\"allowAttachments\":false,\"includeTableOfContents\":false}', '[{\"key\":0,\"department\":\"Engineering\",\"participants\":[{\"userId\":36,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":true,\"stage\":1,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null,\"dueDate\":null},{\"key\":1,\"department\":\"Front\",\"participants\":[{\"userId\":37,\"role\":\"approver\",\"status\":\"pending\",\"comments\":\"\",\"actionDate\":null}],\"mandatory\":true,\"stage\":2,\"stageStatus\":\"pending\",\"startDate\":null,\"completionDate\":null,\"dueDate\":null}]', NULL, '123', NULL, NULL, 21, 11, '2025-05-13 18:33:03', '2025-05-13 18:33:03', 'submitted');

-- --------------------------------------------------------

--
-- Table structure for table `template_categories`
--

CREATE TABLE `template_categories` (
  `category_id` int NOT NULL,
  `organization_id` int NOT NULL,
  `category_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `category_prefix` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `folder_path` varchar(512) COLLATE utf8mb4_general_ci NOT NULL,
  `parent_category_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `template_categories`
--

INSERT INTO `template_categories` (`category_id`, `organization_id`, `category_name`, `category_prefix`, `folder_path`, `parent_category_id`) VALUES
(11, 23, 'Documents', 'docs', '11', NULL),
(12, 23, 'Resume', 'resume', '12', NULL),
(14, 23, 'Legal Documents', 'legal', '14', NULL),
(15, 23, 'Curriculum Vitae', 'CV', '12/15', 12);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `organization_id` int NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `department` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `role` enum('admin','author','project_manager','reviewer','approver','viewer') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `template_approver` enum('yes','no') COLLATE utf8mb4_general_ci DEFAULT 'no',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login` timestamp NULL DEFAULT NULL,
  `status` enum('active','deactivated','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `organization_id`, `email`, `password_hash`, `first_name`, `last_name`, `department`, `role`, `template_approver`, `created_at`, `last_login`, `status`) VALUES
(8, 3, 'admin123@gmail.com', '$2b$10$oREecvjMKs/aK4xsf9fne.J.vzaJzqUArJheR3MLcu/55GM75k2xG', 'fname', 'lname', NULL, 'admin', 'no', '2025-04-07 02:06:52', NULL, 'active'),
(9, 3, 'member1@gmail.com', '$2b$10$tdqkXZmaX0F7PAjkzfWzvOQD5EPz8yddxlGoUNTy/anR02KT2W.dq', 'dan', 'niel', 'Design', NULL, 'no', '2025-04-07 02:08:00', NULL, 'active'),
(10, 3, 'danielventura20020902@gmail.com', '$2b$10$IQu2rL6LNuNL.j2uUv3MCeRO4V2kkV6qZsY6U5UVtM3EsnuSB0Iz6', 'Daniel', 'Ventura', 'Engineering', 'author', 'no', '2025-04-07 10:31:18', NULL, 'active'),
(11, 4, 'sam@sam.com', '$2b$10$IQu2rL6LNuNL.j2uUv3MCeRO4V2kkV6qZsY6U5UVtM3EsnuSB0Iz6', 'sam', 'samsam', NULL, 'admin', 'no', '2025-04-08 01:36:59', NULL, 'active'),
(12, 5, 'doyle.k@gmail.com', '$2b$10$IQu2rL6LNuNL.j2uUv3MCeRO4V2kkV6qZsY6U5UVtM3EsnuSB0Iz6', 'K', 'D', NULL, 'admin', 'no', '2025-04-11 22:40:27', NULL, 'active'),
(13, 6, 'araojoshua@gmail.com', '$2b$10$r7Byqs.hfF9Z/l7rkX10Dub.0uIYI1rs1MMLROOodTiQKIlA9iIK2', 'Joshua', 'Arao', NULL, 'admin', 'no', '2025-04-12 04:36:53', NULL, 'active'),
(14, 3, 'dventura@araosds.com', '$2b$10$s1p3TKMzMetgYjfcrTQYgOgkJAQnO3M6k46qdIKuvYz68fDtgXdRi', 'daniel', 'ventura', 'Marketing', NULL, 'no', '2025-04-17 08:40:18', NULL, 'deactivated'),
(15, 17, 'asdsadasdas@gmail.com', '$2b$10$kVLZxUm87Dba4aqJJkySQe/BhKdIbTVFD1MiAhGy83SbWQM/TFuIa', 'asdas', 'dasdas', NULL, 'admin', 'no', '2025-05-01 01:23:15', NULL, 'active'),
(16, 18, 'nader@doc.com', '$2b$10$JTVCWjGgaPqyBpblKQ6t1OmODGPvu1tDJzL.McYeqpOb2h4cEyHlu', '1', '2', NULL, 'admin', 'no', '2025-05-01 11:36:04', NULL, 'active'),
(17, 19, 'sam@123.com', '$2b$10$2X77k374z40kqF9BXti/P.CJOmM.Wr/uD1SZshGfplgRrMqpLRdoy', '1', '2', NULL, 'admin', 'no', '2025-05-02 02:11:50', NULL, 'active'),
(21, 23, 'admin@gmail.com', '$2b$10$HmtFXpWG6cMc52QrhaHhA.YWmthmxQ31cWhIaE8DjGKUtGiVc3QMi', 'Jhon', 'Doe', NULL, 'admin', 'no', '2025-05-02 14:20:16', NULL, 'active'),
(22, 24, 'asdas@as.asds', '$2b$10$7wcDJGyz73gFeclR58vHVeDRoS/.B0n4IvUDL9otVd3uCWEnn2oTW', 'das', 'dasd', NULL, 'admin', 'no', '2025-05-03 06:19:34', NULL, 'active'),
(23, 24, 'sdfdsfsd@asdfs.sdfd', '$2b$10$gzqKuruIU05t/jbyCLMW/uQpeXEaw6ib6Alls7LMZ0ZcQ/XH99t3K', 'sdfdf', 'dfsdf', NULL, 'reviewer', 'no', '2025-05-03 06:20:42', NULL, 'inactive'),
(24, 23, 'jane.doe@test.com', '$2b$10$13X1tWjFvTTez3YyaAfuCOT2EvKt7yFdva0jxetr5bdC/5hpWWKdW', 'Jane ', 'Doe', 'Engineering', 'author', 'no', '2025-05-03 06:35:30', NULL, 'active'),
(25, 23, 'tom.user@test.com', '$2b$10$cN3aH9EIDRqsrhipzQIvE.Vfs2jPvJqgmGvpUDhakIgb43jUwNDpe', 'Tom', 'Cruise', 'Engineering', 'project_manager', 'no', '2025-05-03 06:37:49', NULL, 'active'),
(26, 23, 'mike.editor@test.com', '$2b$10$pR3ntQYFhUJwbDfw1Q.Sd.lJMKD9i4mk.FY9AQ1Fc2AFT97zyHV0u', 'Mike', 'Tyson', 'Marketing', 'author', 'yes', '2025-05-03 06:38:46', NULL, 'active'),
(27, 23, 'mary.content@test.com', '$2b$10$z9FCiKzxUt1XwcD8ud7hlurPLNHMFH/Qw7UqAA0wXncUYhCBU.KcK', 'Rose', 'Mary', NULL, 'approver', 'no', '2025-05-03 06:39:36', NULL, 'active'),
(35, 23, 's.hernandez@testmail.net', '$2b$10$aGmuy6QPx3FVZ6QexgQuqOZZLEFd5QRrmmnJjsrRlt2IFMORsEHtK', 'Sofia ', 'Hernández', 'Engineering', 'approver', 'yes', '2025-05-05 11:35:01', NULL, 'active'),
(36, 23, 'nader@sam.com', '$2b$10$W4se0s5mcgKQdyFV4Nk37O7wbORGEDx.586q31jA3u7HFyrFdgIeW', 'nader1', 'nader2', 'Engineering', 'reviewer', 'no', '2025-05-13 18:24:49', NULL, 'active'),
(37, 23, 'samsam1@sam1.com', '$2b$10$UjK38KmUGqcJRJZvqTanC.ciB7bU509w7GpvOBbSSpVKVIKUdIpZG', 'samsam', 'samsam1', 'Front', 'reviewer', 'no', '2025-05-13 18:31:02', NULL, 'active');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accessrequests`
--
ALTER TABLE `accessrequests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `document_id` (`document_id`),
  ADD KEY `requested_by` (`requested_by`),
  ADD KEY `resolved_by` (`resolved_by`);

--
-- Indexes for table `audittrail`
--
ALTER TABLE `audittrail`
  ADD PRIMARY KEY (`id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `idx_audit_trail_user` (`user_id`),
  ADD KEY `idx_audit_trail_document` (`document_id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `documentpermissions`
--
ALTER TABLE `documentpermissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `assigned_by` (`assigned_by`),
  ADD KEY `idx_document_permissions_document` (`document_id`),
  ADD KEY `idx_document_permissions_user` (`user_id`);

--
-- Indexes for table `documentreferences`
--
ALTER TABLE `documentreferences`
  ADD PRIMARY KEY (`id`),
  ADD KEY `document_id` (`document_id`),
  ADD KEY `referenced_document_id` (`referenced_document_id`);

--
-- Indexes for table `documentrevisions`
--
ALTER TABLE `documentrevisions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_document_revisions_document` (`document_id`);

--
-- Indexes for table `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`document_id`),
  ADD KEY `idx_documents_organization` (`organization_id`),
  ADD KEY `idx_documents_template` (`template_id`),
  ADD KEY `idx_documents_created_by` (`created_by`),
  ADD KEY `folder_id` (`folder_id`);

--
-- Indexes for table `eventdocuments`
--
ALTER TABLE `eventdocuments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `event_id` (`event_id`),
  ADD KEY `document_id` (`document_id`);

--
-- Indexes for table `eventparticipants`
--
ALTER TABLE `eventparticipants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `event_id` (`event_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `invited_users`
--
ALTER TABLE `invited_users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `noterecipients`
--
ALTER TABLE `noterecipients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `note_id` (`note_id`),
  ADD KEY `recipient_id` (`recipient_id`);

--
-- Indexes for table `notes`
--
ALTER TABLE `notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `document_id` (`document_id`);

--
-- Indexes for table `organizationfolders`
--
ALTER TABLE `organizationfolders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `organizations`
--
ALTER TABLE `organizations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `reviewassignments`
--
ALTER TABLE `reviewassignments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `review_stage_id` (`review_stage_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `reviewstages`
--
ALTER TABLE `reviewstages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `document_id` (`document_id`);

--
-- Indexes for table `taskassignments`
--
ALTER TABLE `taskassignments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `task_id` (`task_id`),
  ADD KEY `assigned_to` (`assigned_to`),
  ADD KEY `assigned_by` (`assigned_by`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `templates`
--
ALTER TABLE `templates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `template_categories`
--
ALTER TABLE `template_categories`
  ADD PRIMARY KEY (`category_id`),
  ADD KEY `parent_category_id` (`parent_category_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_users_organization` (`organization_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accessrequests`
--
ALTER TABLE `accessrequests`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audittrail`
--
ALTER TABLE `audittrail`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `documentpermissions`
--
ALTER TABLE `documentpermissions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `documentreferences`
--
ALTER TABLE `documentreferences`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `documentrevisions`
--
ALTER TABLE `documentrevisions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `eventdocuments`
--
ALTER TABLE `eventdocuments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `eventparticipants`
--
ALTER TABLE `eventparticipants`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `invited_users`
--
ALTER TABLE `invited_users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `noterecipients`
--
ALTER TABLE `noterecipients`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notes`
--
ALTER TABLE `notes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `organizationfolders`
--
ALTER TABLE `organizationfolders`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `organizations`
--
ALTER TABLE `organizations`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=153;

--
-- AUTO_INCREMENT for table `reviewassignments`
--
ALTER TABLE `reviewassignments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reviewstages`
--
ALTER TABLE `reviewstages`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `taskassignments`
--
ALTER TABLE `taskassignments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `template_categories`
--
ALTER TABLE `template_categories`
  MODIFY `category_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `accessrequests`
--
ALTER TABLE `accessrequests`
  ADD CONSTRAINT `accessrequests_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`document_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `accessrequests_ibfk_2` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `accessrequests_ibfk_3` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `audittrail`
--
ALTER TABLE `audittrail`
  ADD CONSTRAINT `audittrail_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `audittrail_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `audittrail_ibfk_3` FOREIGN KEY (`document_id`) REFERENCES `documents` (`document_id`) ON DELETE SET NULL;

--
-- Constraints for table `documentpermissions`
--
ALTER TABLE `documentpermissions`
  ADD CONSTRAINT `documentpermissions_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`document_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documentpermissions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documentpermissions_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `documentreferences`
--
ALTER TABLE `documentreferences`
  ADD CONSTRAINT `documentreferences_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`document_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documentreferences_ibfk_2` FOREIGN KEY (`referenced_document_id`) REFERENCES `documents` (`document_id`) ON DELETE CASCADE;

--
-- Constraints for table `documentrevisions`
--
ALTER TABLE `documentrevisions`
  ADD CONSTRAINT `documentrevisions_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`document_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documentrevisions_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documents_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `eventdocuments`
--
ALTER TABLE `eventdocuments`
  ADD CONSTRAINT `eventdocuments_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `eventdocuments_ibfk_2` FOREIGN KEY (`document_id`) REFERENCES `documents` (`document_id`) ON DELETE CASCADE;

--
-- Constraints for table `eventparticipants`
--
ALTER TABLE `eventparticipants`
  ADD CONSTRAINT `eventparticipants_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `eventparticipants_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `events`
--
ALTER TABLE `events`
  ADD CONSTRAINT `events_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `events_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `noterecipients`
--
ALTER TABLE `noterecipients`
  ADD CONSTRAINT `noterecipients_ibfk_1` FOREIGN KEY (`note_id`) REFERENCES `notes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `noterecipients_ibfk_2` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notes`
--
ALTER TABLE `notes`
  ADD CONSTRAINT `notes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notes_ibfk_2` FOREIGN KEY (`document_id`) REFERENCES `documents` (`document_id`) ON DELETE SET NULL;

--
-- Constraints for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD CONSTRAINT `refresh_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reviewassignments`
--
ALTER TABLE `reviewassignments`
  ADD CONSTRAINT `reviewassignments_ibfk_1` FOREIGN KEY (`review_stage_id`) REFERENCES `reviewstages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviewassignments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reviewstages`
--
ALTER TABLE `reviewstages`
  ADD CONSTRAINT `reviewstages_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`document_id`) ON DELETE CASCADE;

--
-- Constraints for table `taskassignments`
--
ALTER TABLE `taskassignments`
  ADD CONSTRAINT `taskassignments_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `taskassignments_ibfk_2` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `taskassignments_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tasks_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `templates`
--
ALTER TABLE `templates`
  ADD CONSTRAINT `templates_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `templates_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `template_categories`
--
ALTER TABLE `template_categories`
  ADD CONSTRAINT `template_categories_ibfk_1` FOREIGN KEY (`parent_category_id`) REFERENCES `template_categories` (`category_id`) ON DELETE SET NULL;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
