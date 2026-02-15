-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: lpc_inventory_salary
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `advance_reasons`
--

DROP TABLE IF EXISTS `advance_reasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `advance_reasons` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `reason_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `advance_reasons`
--

LOCK TABLES `advance_reasons` WRITE;
/*!40000 ALTER TABLE `advance_reasons` DISABLE KEYS */;
INSERT INTO `advance_reasons` VALUES (1,'Medical Emergency','2026-01-25 04:03:33','2026-01-25 04:03:33'),(2,'Family Needs','2026-01-25 04:03:33','2026-01-25 04:03:33'),(3,'House Rent','2026-01-25 04:03:33','2026-01-25 04:03:33'),(4,'Other','2026-01-25 04:03:34','2026-01-25 04:03:34'),(5,'Reason 1','2026-02-14 00:17:02','2026-02-14 00:17:02');
/*!40000 ALTER TABLE `advance_reasons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendances`
--

DROP TABLE IF EXISTS `attendances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendances` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint unsigned NOT NULL,
  `date` date NOT NULL,
  `status` enum('present','absent','pay_leave') COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `attendances_employee_id_foreign` (`employee_id`),
  CONSTRAINT `attendances_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendances`
--

LOCK TABLES `attendances` WRITE;
/*!40000 ALTER TABLE `attendances` DISABLE KEYS */;
/*!40000 ALTER TABLE `attendances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `brands`
--

DROP TABLE IF EXISTS `brands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `brands` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `brands`
--

LOCK TABLES `brands` WRITE;
/*!40000 ALTER TABLE `brands` DISABLE KEYS */;
INSERT INTO `brands` VALUES (1,'SANY','2026-01-17 09:11:43','2026-01-17 09:11:43'),(2,'Bauer','2026-01-17 09:11:43','2026-01-17 09:11:43'),(3,'PDI','2026-01-17 09:11:43','2026-01-17 09:11:43'),(4,'Mitutoyo','2026-01-17 09:11:43','2026-01-17 09:11:43'),(5,'XCMG','2026-01-17 10:19:05','2026-01-17 10:19:05'),(6,'Generic','2026-01-17 10:19:05','2026-01-17 10:19:05'),(7,'Cummins','2026-01-17 10:19:05','2026-01-17 10:19:05'),(8,'Fann','2026-01-17 10:19:05','2026-01-17 10:19:05'),(9,'Leica','2026-01-17 10:19:05','2026-01-17 10:19:05');
/*!40000 ALTER TABLE `brands` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Machinery','2026-01-17 09:11:43','2026-01-17 09:11:43'),(2,'Testing Instruments','2026-01-17 09:11:43','2026-01-17 09:11:43'),(3,'Drilling Tools','2026-01-17 09:11:43','2026-01-17 09:11:43');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `designation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_salary` decimal(15,2) NOT NULL DEFAULT '0.00',
  `user_id` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `employees_employee_id_unique` (`employee_id`),
  KEY `employees_user_id_foreign` (`user_id`),
  CONSTRAINT `employees_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (2,'EMP01','Manager John','GM',5000.00,NULL,'2026-01-17 00:26:55','2026-01-17 00:26:55',NULL),(3,'PIL-101','Abdur Rahman','Senior Mechanic',45000.00,NULL,'2026-01-17 13:05:01','2026-01-17 13:05:01',NULL),(4,'PIL-102','Kashem Ali','Hydraulic Technician',38000.00,NULL,'2026-01-17 13:05:01','2026-01-17 13:05:01',NULL),(5,'PIL-103','Sarker Mahmud','Maintenance Engineer',55000.00,NULL,'2026-01-17 13:05:01','2026-01-17 13:05:01',NULL),(6,'PIL-104','Jasim Uddin','Rig Operator',42000.00,NULL,'2026-01-17 13:05:01','2026-01-17 13:05:01',NULL),(7,'PIL-105','Nurul Islam','Assistant Mechanic',28000.00,NULL,'2026-01-17 13:05:01','2026-01-17 13:05:01',NULL),(8,'EMP-001','Test User','Operator',30000.00,NULL,'2026-01-25 04:08:57','2026-01-25 04:08:57',NULL),(9,'EMP-0009','Sajid','Field Enginner',13000.00,NULL,'2026-02-09 04:08:43','2026-02-09 04:23:03',NULL),(10,'EMP-0010','Sajid 2','FD',25000.00,NULL,'2026-02-09 04:26:57','2026-02-09 05:23:28',NULL),(11,'EMP-0011','Sajid 3','Field Engineer',123454.00,NULL,'2026-02-09 05:24:15','2026-02-09 05:40:16',NULL),(12,'EMP-0012','Sajid 4','Field 2',17000.00,NULL,'2026-02-09 05:40:59','2026-02-09 05:40:59',NULL),(13,'EMP-0013','Sajid 4','Advocate',12580.00,NULL,'2026-02-09 05:41:27','2026-02-09 06:26:00',NULL),(14,'EMP-0014','e','f',12.00,NULL,'2026-02-09 05:44:24','2026-02-09 06:25:32','2026-02-09 06:25:32');
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipment`
--

DROP TABLE IF EXISTS `equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `equipment` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `serial_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Working',
  `current_site_id` bigint unsigned DEFAULT NULL,
  `parent_id` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `category_id` bigint unsigned DEFAULT NULL,
  `brand_id` bigint unsigned DEFAULT NULL,
  `is_attachment` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `equipment_serial_number_unique` (`serial_number`),
  KEY `equipment_current_site_id_foreign` (`current_site_id`),
  KEY `equipment_category_id_foreign` (`category_id`),
  KEY `equipment_brand_id_foreign` (`brand_id`),
  KEY `equipment_parent_id_foreign` (`parent_id`),
  CONSTRAINT `equipment_brand_id_foreign` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL,
  CONSTRAINT `equipment_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `equipment_current_site_id_foreign` FOREIGN KEY (`current_site_id`) REFERENCES `sites` (`id`),
  CONSTRAINT `equipment_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `equipment` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=152 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment`
--

LOCK TABLES `equipment` WRITE;
/*!40000 ALTER TABLE `equipment` DISABLE KEYS */;
INSERT INTO `equipment` VALUES (3,'Piling Rig Rig-01',NULL,'SN999','Maintenance',5,NULL,'2026-01-17 00:26:57','2026-02-14 05:47:28',2,4,0),(4,'Hydraulic Rig',NULL,'SN-001','Working',5,NULL,'2026-01-17 00:42:51','2026-01-17 02:01:18',2,4,0),(5,'Hydraulic Rig 2',NULL,'SN102','Working',3,NULL,'2026-01-17 02:12:38','2026-01-17 02:13:04',2,4,0),(6,'SANY SR2850',NULL,'SN-9920-X','Under Repair',4,NULL,'2026-01-17 02:56:00','2026-01-17 02:56:12',1,1,0),(57,'Rotary Drilling Rig SR285',NULL,'SN-SR285-101','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,1,0),(58,'Rotary Drilling Rig BG25',NULL,'SN-BG25-V2','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,2,0),(59,'Hydraulic Piling Rig KR125',NULL,'SN-KR125-09','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,3,0),(60,'Crawler Crane 50-Ton',NULL,'SN-CR-50T-01','Working',3,NULL,'2026-01-17 10:19:23','2026-02-14 04:19:27',1,1,0),(61,'Crawler Crane 75-Ton',NULL,'SN-CR-75T-05','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(62,'Vibro Hammer 60kW',NULL,'SN-VH-60-12','Working',4,NULL,'2026-01-17 10:19:23','2026-02-14 04:28:04',1,6,0),(63,'Vibro Hammer 90kW',NULL,'SN-VH-90-03','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(64,'Concrete Pump Trailer',NULL,'SN-CP-880','Working',5,NULL,'2026-01-17 10:19:23','2026-01-17 05:04:40',1,6,0),(65,'Concrete Pump Truck',NULL,'SN-CPT-S9','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,1,0),(66,'Excavator PC200',NULL,'SN-EX-PC200-1','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(67,'Excavator 320D',NULL,'SN-EX-320D-2','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(68,'Wheel Loader L956F',NULL,'SN-WL-956','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(69,'Diesel Generator 150kVA',NULL,'SN-GEN-150-A','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,7,0),(70,'Diesel Generator 250kVA',NULL,'SN-GEN-250-B','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,7,0),(71,'Bentonite Mixing Plant',NULL,'SN-BMP-500','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(72,'PIT Integrity Tester',NULL,'SN-PIT-882','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,4,0),(73,'PDA Dynamic Load Tester',NULL,'SN-PDA-001','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,4,0),(74,'Hydraulic Jack 500-Ton',NULL,'SN-JK-500-A','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(75,'Hydraulic Jack 500-Ton',NULL,'SN-JK-500-B','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(76,'Hydraulic Jack 800-Ton',NULL,'SN-JK-800-X','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(77,'Digital Dial Gauge 25mm',NULL,'SN-DG-01','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,5,0),(78,'Digital Dial Gauge 25mm',NULL,'SN-DG-02','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,5,0),(79,'Digital Dial Gauge 50mm',NULL,'SN-DG-03','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,5,0),(80,'Marsh Funnel Viscometer',NULL,'SN-MF-77','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,8,0),(81,'Mud Balance Scale',NULL,'SN-MB-99','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,8,0),(82,'Sand Content Kit',NULL,'SN-SC-12','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(83,'Total Station TS06',NULL,'SN-TS-009','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,9,0),(84,'Auto Level NA720',NULL,'SN-AL-101','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,9,0),(85,'Ultrasonic Pile Monitor',NULL,'SN-UPM-22','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(86,'Slump Cone Test Kit',NULL,'SN-SLUMP-01','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(87,'Rock Auger 1000mm',NULL,'SN-AUG-1000R','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,2,0),(88,'Soil Auger 1200mm',NULL,'SN-AUG-1200S','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,1,0),(89,'Core Barrel 1000mm',NULL,'SN-CB-1000','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(90,'Core Barrel 1500mm',NULL,'SN-CB-1500','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(91,'Cleaning Bucket 1200mm',NULL,'SN-BK-1200','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(92,'Drilling Bucket 1000mm',NULL,'SN-BK-1000','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(93,'Kelly Bar 4-Section (48m)',NULL,'SN-KB-48','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,2,0),(94,'Kelly Bar 3-Section (36m)',NULL,'SN-KB-36','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,1,0),(95,'Casing Pipe 1200mm (6m)',NULL,'SN-CSG-1200-A','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(96,'Casing Pipe 1200mm (6m)',NULL,'SN-CSG-1200-B','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(97,'Casing Drive Adapter',NULL,'SN-CDA-1200','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(98,'Tremie Pipe Set (20m)',NULL,'SN-TP-20','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(99,'Tremie Pipe Set (30m)',NULL,'SN-TP-30','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(100,'Tremie Hopper (1.5m3)',NULL,'SN-TH-01','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(101,'Lifting Belt 10-Ton',NULL,'SN-BELT-10T','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(102,'Welding Machine 400A',NULL,'SN-WELD-400','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(103,'Air Compressor',NULL,'SN-AIR-05','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(104,'Slurry Submersible Pump',NULL,'SN-PUMP-01','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(105,'Slurry Submersible Pump',NULL,'SN-PUMP-02','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(106,'Rebar Bending Machine',NULL,'SN-BEND-01','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(108,'Hydraulic Pressure Gauge (700 Bar)',NULL,'PG-SLT-9901','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,6,0),(109,'Digital Pressure Gauge',NULL,'DPG-MT-202','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,5,0),(110,'High-Pressure Hydraulic Hose (10m)',NULL,'HPH-10M-01','Working',4,NULL,'2026-01-17 11:06:26','2026-01-17 05:23:12',2,6,0),(111,'Mechanical Dial Gauge (50mm Travel)',NULL,'DG-50-A1','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,5,0),(112,'Mechanical Dial Gauge (50mm Travel)',NULL,'DG-50-A2','Working',4,NULL,'2026-01-17 11:06:26','2026-02-14 04:03:38',2,5,0),(113,'Digital Dial Gauge (25mm Travel)',NULL,'DDG-25-01','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,5,0),(114,'Magnetic Base for Dial Gauge',NULL,'MB-DG-01','Working',4,NULL,'2026-01-17 11:06:26','2026-01-17 23:07:08',2,6,0),(115,'Crosshole Sonic Logger (CHSL)',NULL,'CSL-PDI-101','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(116,'Sonic Logging Transducer (Emitter)',NULL,'SLT-E-202','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(117,'Sonic Logging Transducer (Receiver)',NULL,'SLT-R-203','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(118,'CSL Depth Encoder',NULL,'ENC-CSL-05','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(119,'PDA Model 8G Data Acquisition',NULL,'PDA-8G-772','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(120,'PDA Strain Transducer',NULL,'PDA-ST-01','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(121,'PDA Piezoelectric Accelerometer',NULL,'PDA-ACC-05','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(122,'Main Connection Cable (PDA to Sensors)',NULL,'CBL-PDA-15M','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(123,'PIT-V Integrity Tester',NULL,'PIT-V-330','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(124,'PIT Handheld Hammer (Large)',NULL,'PIT-HM-L','Working',5,NULL,'2026-01-17 11:06:26','2026-02-14 04:05:29',2,4,0),(125,'PIT Handheld Hammer (Small)',NULL,'PIT-HM-S','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(126,'Kelly Bar 15m Interlocking',NULL,'KB-R01-01','In Stock',5,4,'2026-01-17 12:50:35','2026-01-18 02:53:30',2,4,1),(127,'Drilling Bucket 1200mm',NULL,'DB-R01-1200','Working',5,3,'2026-01-17 12:50:35','2026-02-14 05:47:28',2,4,1),(128,'Rock Auger 800mm',NULL,'RA-R02-800','In Stock',1,NULL,'2026-01-17 12:50:35','2026-02-14 04:19:31',2,4,1),(129,'Kelly Bar 18m','Interlocking','KB-18M-001','Working',5,3,'2026-01-17 13:35:22','2026-02-14 05:47:28',2,4,1),(130,'Drilling Bucket 1500mm','Clay Type','DB-1500-05','Working',5,3,'2026-01-17 13:35:22','2026-02-14 05:47:28',2,4,1),(131,'Rock Auger 600mm','Heavy Duty','RA-600-12','Working',5,3,'2026-01-17 13:35:22','2026-02-14 05:47:28',2,4,1),(132,'Tremie Pipe Set 25m','TP-Series','TP-25-99','Working',5,3,'2026-01-17 13:35:22','2026-02-14 05:47:28',2,4,1),(133,'Casing Oscillator','1200mm','CO-1200-X','Maintenance',5,3,'2026-01-17 13:35:22','2026-02-14 05:47:28',2,4,1),(137,'Hydraulic Pump Rexroth',NULL,'PUMP-001','In Stock',1,NULL,'2026-01-18 04:40:03','2026-02-14 04:28:16',NULL,NULL,1),(138,'Engine Oil Filter XL',NULL,'FLT-990','In Stock',1,124,'2026-01-18 04:40:03','2026-01-18 03:46:20',NULL,NULL,1),(139,'Main Winch Rope 50m',NULL,'WNC-50','In Stock',1,123,'2026-01-18 04:40:03','2026-02-14 02:35:11',NULL,NULL,1),(140,'Kelly Bar 12m (Spare)',NULL,'KB-SP-12','In Stock',1,NULL,'2026-01-18 04:40:03','2026-02-14 03:36:59',NULL,NULL,1),(142,'Mac-5',NULL,'SN-5','Working',1,NULL,'2026-01-17 23:16:53','2026-01-17 23:16:53',NULL,NULL,0),(143,'MAC-6',NULL,'SN-6','Working',4,NULL,'2026-01-17 23:17:43','2026-01-17 23:17:43',NULL,NULL,0),(144,'KELLY - 500',NULL,'K-500','Working',5,NULL,'2026-01-17 23:19:37','2026-01-17 23:19:37',NULL,NULL,0),(145,'KElly - 102',NULL,'K-102','In Stock',4,6,'2026-01-17 23:21:06','2026-02-14 02:48:46',NULL,NULL,1),(147,'A',NULL,'VB','Working',5,NULL,'2026-01-18 01:50:50','2026-01-18 01:50:50',NULL,NULL,0),(148,'ABB',NULL,'EEE','Working',5,NULL,'2026-01-18 01:51:24','2026-02-14 04:38:07',NULL,NULL,0),(149,'ABD',NULL,'ABD - 1','Working',3,NULL,'2026-01-18 01:57:40','2026-02-14 04:32:47',2,9,0),(150,'Name 01',NULL,'SN - 00123','In Stock',4,NULL,'2026-01-18 01:58:06','2026-02-14 04:11:11',1,9,1),(151,'DEPO - 2',NULL,'D-2','In Stock',NULL,NULL,'2026-01-18 02:12:37','2026-02-14 04:38:20',1,8,1);
/*!40000 ALTER TABLE `equipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_movements`
--

DROP TABLE IF EXISTS `inventory_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_movements` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `equipment_id` bigint unsigned NOT NULL,
  `from_site_id` bigint unsigned DEFAULT NULL,
  `to_site_id` bigint unsigned NOT NULL,
  `transfer_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `inventory_movements_equipment_id_foreign` (`equipment_id`),
  KEY `inventory_movements_from_site_id_foreign` (`from_site_id`),
  KEY `inventory_movements_to_site_id_foreign` (`to_site_id`),
  CONSTRAINT `inventory_movements_equipment_id_foreign` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`id`),
  CONSTRAINT `inventory_movements_from_site_id_foreign` FOREIGN KEY (`from_site_id`) REFERENCES `sites` (`id`),
  CONSTRAINT `inventory_movements_to_site_id_foreign` FOREIGN KEY (`to_site_id`) REFERENCES `sites` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_movements`
--

LOCK TABLES `inventory_movements` WRITE;
/*!40000 ALTER TABLE `inventory_movements` DISABLE KEYS */;
INSERT INTO `inventory_movements` VALUES (1,3,3,3,'2026-01-17','2026-01-17 00:34:27','2026-01-17 00:34:27'),(2,3,3,4,'2026-01-17','2026-01-17 00:35:50','2026-01-17 00:35:50'),(3,3,4,5,'2026-01-17','2026-01-17 00:36:04','2026-01-17 00:36:04'),(4,4,5,3,'2026-01-17','2026-01-17 00:43:16','2026-01-17 00:43:16'),(5,3,5,3,'2026-01-17','2026-01-17 00:53:50','2026-01-17 00:53:50'),(6,3,3,4,'2026-01-17','2026-01-17 00:56:56','2026-01-17 00:56:56'),(7,4,3,5,'2026-01-29','2026-01-17 02:01:18','2026-01-17 02:01:18'),(8,3,4,3,'2026-01-17','2026-01-17 04:48:04','2026-01-17 04:48:04'),(9,3,3,4,'2026-01-17','2026-01-17 05:04:03','2026-01-17 05:04:03'),(10,64,1,5,'2026-01-17','2026-01-17 05:04:40','2026-01-17 05:04:40'),(11,3,4,5,'2026-01-17','2026-01-17 05:22:30','2026-01-17 05:22:30'),(12,110,1,4,'2026-01-17','2026-01-17 05:23:12','2026-01-17 05:23:12'),(13,114,1,4,'2026-01-18','2026-01-17 23:07:08','2026-01-17 23:07:08'),(14,3,5,4,'2026-01-18','2026-01-17 23:07:19','2026-01-17 23:07:19'),(15,3,4,3,'2026-01-18','2026-01-17 23:07:56','2026-01-17 23:07:56'),(16,3,3,5,'2026-01-18','2026-01-18 02:44:14','2026-01-18 02:44:14'),(17,3,5,4,'2026-02-08','2026-02-08 00:32:01','2026-02-08 00:32:01');
/*!40000 ALTER TABLE `inventory_movements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leaves`
--

DROP TABLE IF EXISTS `leaves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leaves` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint unsigned NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `expected_return_date` date NOT NULL,
  `actual_return_date` date DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Approved',
  `remarks` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `leaves_employee_id_foreign` (`employee_id`),
  CONSTRAINT `leaves_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leaves`
--

LOCK TABLES `leaves` WRITE;
/*!40000 ALTER TABLE `leaves` DISABLE KEYS */;
/*!40000 ALTER TABLE `leaves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maintenance_records`
--

DROP TABLE IF EXISTS `maintenance_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance_records` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `equipment_id` bigint unsigned NOT NULL,
  `mechanic_id` bigint unsigned NOT NULL,
  `service_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `service_date` date NOT NULL,
  `running_hours` int DEFAULT NULL,
  `parts_replaced` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `remarks` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `maintenance_records_equipment_id_foreign` (`equipment_id`),
  KEY `maintenance_records_mechanic_id_foreign` (`mechanic_id`),
  CONSTRAINT `maintenance_records_equipment_id_foreign` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`id`) ON DELETE CASCADE,
  CONSTRAINT `maintenance_records_mechanic_id_foreign` FOREIGN KEY (`mechanic_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance_records`
--

LOCK TABLES `maintenance_records` WRITE;
/*!40000 ALTER TABLE `maintenance_records` DISABLE KEYS */;
INSERT INTO `maintenance_records` VALUES (2,3,2,'Routine Maintenance','2026-01-17',1250,'Hydraulic Oil Filter, Engine Oil Filter, Primary Fuel Filter',450.00,'Regular 250hr service completed.','2026-01-17 12:51:58','2026-01-17 12:51:58'),(3,3,3,'Routine Maintenance','2026-01-17',1250,'Hydraulic Oil Filter, Engine Oil Filter',450.00,'Service by Abdur Rahman.','2026-01-17 13:16:42','2026-01-17 13:16:42'),(14,6,3,'Emergency Repair','2026-02-10',3150,'Hydraulic Seal Kit, Main Winch Rope',850.00,'Fixed oil leak in the main winch assembly.','2026-02-14 06:27:49','2026-02-14 06:27:49'),(15,66,4,'Routine Maintenance','2026-02-12',4200,'Engine Oil, Fuel Filter, Hydraulic Filter',320.00,'Standard 250hr interval service completed.','2026-02-14 06:27:49','2026-02-14 06:27:49'),(16,69,6,'Electrical Repair','2026-02-14',1800,'AVR Module, Battery Terminals',210.50,'Voltage fluctuation issue resolved.','2026-02-14 06:27:49','2026-02-14 06:27:49'),(17,57,3,'Routine Maintenance','2026-02-14',5100,'Primary Fuel Filter, Secondary Air Filter',440.00,'Regular maintenance check for upcoming project.','2026-02-14 06:27:49','2026-02-14 06:27:49'),(18,102,7,'Inspection','2026-02-14',950,'None',45.00,'General safety and wiring inspection.','2026-02-14 06:27:49','2026-02-14 06:27:49'),(19,3,3,'s','2026-02-14',10,'w',0.00,NULL,'2026-02-14 01:37:07','2026-02-14 01:37:07'),(20,3,4,'Ser 2','2026-02-14',12,'Work 2',0.00,NULL,'2026-02-14 01:38:16','2026-02-14 01:38:16'),(21,3,7,'service 3','2026-02-14',15,'Work 3',0.00,NULL,'2026-02-14 01:46:59','2026-02-14 01:46:59'),(22,3,2,'service 4','2026-02-14',102,'Work 4',0.00,NULL,'2026-02-14 03:28:29','2026-02-14 03:28:29'),(23,4,7,'1203','2026-02-14',150,'Lorem Ipsum is a standard placeholder text used in the printing and typesetting industry. It has been the industry\'s standard dummy text since the 1500s, when an unknown printer scrambled a galley of type to create a type specimen book. You can easily generate Lorem Ipsum text using various online generators, which allow you to create placeholder text in any number of characters, words, sentences, or paragraphs. This text is commonly used to give an impression of how a document will look once the actual content is added.',0.00,NULL,'2026-02-14 06:29:48','2026-02-14 06:29:48'),(24,4,7,'Routine maintainace','2026-02-14',150,'Lorem Ipsum is a standard placeholder text used in the printing and typesetting industry. It has been the industry\'s standard dummy text since the 1500s, when an unknown printer scrambled a galley of type to create a type specimen book. You can easily generate Lorem Ipsum text using various online generators, which allow you to create placeholder text in any number of characters, words, sentences, or paragraphs. This text is commonly used to give an impression of how a document will look once the actual content is added.',0.00,NULL,'2026-02-14 06:30:21','2026-02-14 06:30:21'),(25,4,5,'Routine maintainace 2','2026-02-14',420,'Lorem Ipsum is a standard placeholder text used in the printing and typesetting industry. It has been the industry\'s standard dummy text since the 1500s, when an unknown printer scrambled a galley of type to create a type specimen book. You can easily generate Lorem Ipsum text using various online generators, which allow you to create placeholder text in any number of characters, words, sentences, or paragraphs. This text is commonly used to give an impression of how a document will look once the actual content is added.',0.00,NULL,'2026-02-14 06:30:42','2026-02-14 06:30:42');
/*!40000 ALTER TABLE `maintenance_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_01_17_054628_create_permission_tables',2),(5,'2026_01_17_055134_create_employees_table',3),(6,'2026_01_17_055134_create_sites_table',3),(7,'2026_01_17_055135_create_attendances_table',3),(8,'2026_01_17_055135_create_equipment_table',3),(9,'2026_01_17_055135_create_inventory_movements_table',3),(10,'2026_01_17_055137_create_salary_advances_table',3),(11,'2026_01_17_065223_change_status_to_string_in_equipment_table',4),(12,'2026_01_17_082034_add_category_and_brand_to_equipment_table',5),(13,'2026_01_17_090749_create_categories_and_brands_tables',6),(14,'2026_01_17_124155_add_parent_id_to_equipment_table',7),(15,'2026_01_17_124234_create_maintenance_records_table',7),(16,'2026_01_25_091551_add_status_and_reason_to_salary_advances_table',8),(17,'2026_01_25_092800_create_leaves_table',9),(18,'2026_01_17_055136_create_advance_reasons_table',10),(19,'2026_01_25_093444_update_existing_salary_advances_table',10),(20,'2026_01_26_082118_create_salary_archive_tables',11),(21,'2026_02_09_102028_update_employees_table_make_fields_nullable',12),(22,'2026_02_09_122145_add_soft_deletes_to_employees_table',13);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_has_permissions`
--

DROP TABLE IF EXISTS `model_has_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `model_has_permissions` (
  `permission_id` bigint unsigned NOT NULL,
  `model_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`model_id`,`model_type`),
  KEY `model_has_permissions_model_id_model_type_index` (`model_id`,`model_type`),
  CONSTRAINT `model_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_has_permissions`
--

LOCK TABLES `model_has_permissions` WRITE;
/*!40000 ALTER TABLE `model_has_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `model_has_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_has_roles`
--

DROP TABLE IF EXISTS `model_has_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `model_has_roles` (
  `role_id` bigint unsigned NOT NULL,
  `model_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`model_id`,`model_type`),
  KEY `model_has_roles_model_id_model_type_index` (`model_id`,`model_type`),
  CONSTRAINT `model_has_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_has_roles`
--

LOCK TABLES `model_has_roles` WRITE;
/*!40000 ALTER TABLE `model_has_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `model_has_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `guard_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_has_permissions`
--

DROP TABLE IF EXISTS `role_has_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_has_permissions` (
  `permission_id` bigint unsigned NOT NULL,
  `role_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`role_id`),
  KEY `role_has_permissions_role_id_foreign` (`role_id`),
  CONSTRAINT `role_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_has_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_has_permissions`
--

LOCK TABLES `role_has_permissions` WRITE;
/*!40000 ALTER TABLE `role_has_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `role_has_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `guard_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_advances`
--

DROP TABLE IF EXISTS `salary_advances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_advances` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint unsigned NOT NULL,
  `reason_id` bigint unsigned DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `advance_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `salary_advances_employee_id_foreign` (`employee_id`),
  CONSTRAINT `salary_advances_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_advances`
--

LOCK TABLES `salary_advances` WRITE;
/*!40000 ALTER TABLE `salary_advances` DISABLE KEYS */;
INSERT INTO `salary_advances` VALUES (81,4,1,1460.00,'pending',NULL,'2026-02-14','2026-02-13 23:21:20','2026-02-13 23:21:20'),(82,6,1,600.00,'pending',NULL,'2026-02-14','2026-02-13 23:21:20','2026-02-13 23:21:20'),(83,7,1,2400.00,'pending',NULL,'2026-02-14','2026-02-13 23:21:20','2026-02-13 23:21:20'),(84,8,1,150.00,'pending',NULL,'2026-02-14','2026-02-13 23:21:20','2026-02-13 23:21:20'),(85,9,1,2000.00,'pending',NULL,'2026-02-14','2026-02-13 23:21:20','2026-02-13 23:21:20'),(86,4,3,1250.00,'pending',NULL,'2026-02-14','2026-02-13 23:31:07','2026-02-13 23:31:07');
/*!40000 ALTER TABLE `salary_advances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_sheet_details`
--

DROP TABLE IF EXISTS `salary_sheet_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_sheet_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `salary_sheet_id` bigint unsigned NOT NULL,
  `employee_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `base_salary` decimal(15,2) NOT NULL,
  `advance` decimal(15,2) NOT NULL,
  `net_payable` decimal(15,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `salary_sheet_details_salary_sheet_id_foreign` (`salary_sheet_id`),
  CONSTRAINT `salary_sheet_details_salary_sheet_id_foreign` FOREIGN KEY (`salary_sheet_id`) REFERENCES `salary_sheets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=145 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_sheet_details`
--

LOCK TABLES `salary_sheet_details` WRITE;
/*!40000 ALTER TABLE `salary_sheet_details` DISABLE KEYS */;
INSERT INTO `salary_sheet_details` VALUES (1,1,'LPC-001','John Doe',30000.00,5000.00,25000.00,NULL,NULL),(2,1,'LPC-002','Jane Smith',25000.00,5000.00,20000.00,NULL,NULL),(3,2,'LPC-001','John Doe',30000.00,8000.00,22000.00,NULL,NULL),(4,3,'LPC-TEST','Sample Employee',60000.00,10000.00,50000.00,NULL,NULL),(5,4,'LPC-TEST','Sample Employee',60000.00,10000.00,50000.00,NULL,NULL),(6,5,'LPC-TEST','Sample Employee',60000.00,10000.00,50000.00,NULL,NULL);
/*!40000 ALTER TABLE `salary_sheet_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_sheets`
--

DROP TABLE IF EXISTS `salary_sheets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_sheets` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `month` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `month_number` int NOT NULL,
  `year` int NOT NULL,
  `total_payout` decimal(15,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_sheets`
--

LOCK TABLES `salary_sheets` WRITE;
/*!40000 ALTER TABLE `salary_sheets` DISABLE KEYS */;
INSERT INTO `salary_sheets` VALUES (1,'December',12,2025,45000.00,'2026-01-26 02:34:23',NULL),(2,'November',11,2025,22000.00,'2026-01-26 02:34:23',NULL),(3,'October',10,2025,50000.00,'2026-01-26 02:35:50',NULL),(4,'September',9,2025,50000.00,'2026-01-26 02:35:50',NULL),(5,'August',8,2025,50000.00,'2026-01-26 02:35:50',NULL);
/*!40000 ALTER TABLE `salary_sheets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('M03oSHNFVQ3JQy31wFa3xrXx93FkvOlQKivNglid',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0','YTo2OntzOjY6Il90b2tlbiI7czo0MDoiNWp6RmUzRkxoNDJCMnduYUpqSWVaVnYyUkV4eGduUjYzSXNVWnlaeCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czozOiJ1cmwiO2E6MDp7fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9kZXBvP3NlYXJjaD0iO3M6NToicm91dGUiO3M6MTQ6ImludmVudG9yeS5kZXBvIjt9czoyMjoiUEhQREVCVUdCQVJfU1RBQ0tfREFUQSI7YTowOnt9fQ==',1771072262);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sites`
--

DROP TABLE IF EXISTS `sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sites` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `location_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `supervisor_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sites_supervisor_id_foreign` (`supervisor_id`),
  CONSTRAINT `sites_supervisor_id_foreign` FOREIGN KEY (`supervisor_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sites`
--

LOCK TABLES `sites` WRITE;
/*!40000 ALTER TABLE `sites` DISABLE KEYS */;
INSERT INTO `sites` VALUES (1,'Main Equipment Yard',2,'2026-01-17 10:15:54','2026-01-17 10:15:54'),(3,'Main Store',2,'2026-01-17 00:26:56','2026-01-17 00:26:56'),(4,'Dhaka Metro Project',2,'2026-01-17 00:35:36','2026-01-17 00:35:36'),(5,'Chittagong Port Site',2,'2026-01-17 00:35:38','2026-01-17 00:35:38');
/*!40000 ALTER TABLE `sites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'AB','admin@example.com',NULL,'$2y$12$7X9Y1g3Q13xQcWlW1YBVpOT9gUHI8.MQ6qcHKC6B7FzUqkz53RbV6','TqgHPEWf7bzC3mmpuucmkQFtFBvB3lKP0Jvoo4lSrqTUmDKNuS55pAQMM7J5','2026-01-16 23:24:19','2026-01-16 23:24:19');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-14 18:34:13
