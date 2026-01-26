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
INSERT INTO `cache` VALUES ('laravel-cache-boost.roster.scan','a:2:{s:6:\"roster\";O:21:\"Laravel\\Roster\\Roster\":3:{s:13:\"\0*\0approaches\";O:29:\"Illuminate\\Support\\Collection\":2:{s:8:\"\0*\0items\";a:0:{}s:28:\"\0*\0escapeWhenCastingToString\";b:0;}s:11:\"\0*\0packages\";O:32:\"Laravel\\Roster\\PackageCollection\":2:{s:8:\"\0*\0items\";a:25:{i:0;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:1;s:13:\"\0*\0constraint\";s:4:\"^2.0\";s:10:\"\0*\0package\";E:37:\"Laravel\\Roster\\Enums\\Packages:INERTIA\";s:14:\"\0*\0packageName\";s:25:\"inertiajs/inertia-laravel\";s:10:\"\0*\0version\";s:6:\"2.0.19\";s:6:\"\0*\0dev\";b:0;}i:1;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:1;s:13:\"\0*\0constraint\";s:4:\"^2.0\";s:10:\"\0*\0package\";E:45:\"Laravel\\Roster\\Enums\\Packages:INERTIA_LARAVEL\";s:14:\"\0*\0packageName\";s:25:\"inertiajs/inertia-laravel\";s:10:\"\0*\0version\";s:6:\"2.0.19\";s:6:\"\0*\0dev\";b:0;}i:2;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:1;s:13:\"\0*\0constraint\";s:5:\"^12.0\";s:10:\"\0*\0package\";E:37:\"Laravel\\Roster\\Enums\\Packages:LARAVEL\";s:14:\"\0*\0packageName\";s:17:\"laravel/framework\";s:10:\"\0*\0version\";s:7:\"12.47.0\";s:6:\"\0*\0dev\";b:0;}i:3;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:7:\"v0.3.10\";s:10:\"\0*\0package\";E:37:\"Laravel\\Roster\\Enums\\Packages:PROMPTS\";s:14:\"\0*\0packageName\";s:15:\"laravel/prompts\";s:10:\"\0*\0version\";s:6:\"0.3.10\";s:6:\"\0*\0dev\";b:0;}i:4;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:1;s:13:\"\0*\0constraint\";s:4:\"^4.0\";s:10:\"\0*\0package\";E:37:\"Laravel\\Roster\\Enums\\Packages:SANCTUM\";s:14:\"\0*\0packageName\";s:15:\"laravel/sanctum\";s:10:\"\0*\0version\";s:5:\"4.2.3\";s:6:\"\0*\0dev\";b:0;}i:5;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:1;s:13:\"\0*\0constraint\";s:7:\"^0.1.11\";s:10:\"\0*\0package\";E:39:\"Laravel\\Roster\\Enums\\Packages:WAYFINDER\";s:14:\"\0*\0packageName\";s:17:\"laravel/wayfinder\";s:10:\"\0*\0version\";s:6:\"0.1.13\";s:6:\"\0*\0dev\";b:0;}i:6;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:1;s:13:\"\0*\0constraint\";s:7:\"^0.1.11\";s:10:\"\0*\0package\";E:47:\"Laravel\\Roster\\Enums\\Packages:WAYFINDER_LARAVEL\";s:14:\"\0*\0packageName\";s:17:\"laravel/wayfinder\";s:10:\"\0*\0version\";s:6:\"0.1.13\";s:6:\"\0*\0dev\";b:0;}i:7;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:1;s:13:\"\0*\0constraint\";s:4:\"^2.0\";s:10:\"\0*\0package\";E:35:\"Laravel\\Roster\\Enums\\Packages:ZIGGY\";s:14:\"\0*\0packageName\";s:15:\"tightenco/ziggy\";s:10:\"\0*\0version\";s:5:\"2.6.0\";s:6:\"\0*\0dev\";b:0;}i:8;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:1;s:13:\"\0*\0constraint\";s:4:\"^2.3\";s:10:\"\0*\0package\";E:36:\"Laravel\\Roster\\Enums\\Packages:BREEZE\";s:14:\"\0*\0packageName\";s:14:\"laravel/breeze\";s:10:\"\0*\0version\";s:5:\"2.3.8\";s:6:\"\0*\0dev\";b:1;}i:9;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:6:\"v0.5.2\";s:10:\"\0*\0package\";E:33:\"Laravel\\Roster\\Enums\\Packages:MCP\";s:14:\"\0*\0packageName\";s:11:\"laravel/mcp\";s:10:\"\0*\0version\";s:5:\"0.5.2\";s:6:\"\0*\0dev\";b:1;}i:10;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:1;s:13:\"\0*\0constraint\";s:5:\"^1.24\";s:10:\"\0*\0package\";E:34:\"Laravel\\Roster\\Enums\\Packages:PINT\";s:14:\"\0*\0packageName\";s:12:\"laravel/pint\";s:10:\"\0*\0version\";s:6:\"1.27.0\";s:6:\"\0*\0dev\";b:1;}i:11;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:1;s:13:\"\0*\0constraint\";s:5:\"^1.41\";s:10:\"\0*\0package\";E:34:\"Laravel\\Roster\\Enums\\Packages:SAIL\";s:14:\"\0*\0packageName\";s:12:\"laravel/sail\";s:10:\"\0*\0version\";s:6:\"1.52.0\";s:6:\"\0*\0dev\";b:1;}i:12;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:1;s:13:\"\0*\0constraint\";s:7:\"^11.5.3\";s:10:\"\0*\0package\";E:37:\"Laravel\\Roster\\Enums\\Packages:PHPUNIT\";s:14:\"\0*\0packageName\";s:15:\"phpunit/phpunit\";s:10:\"\0*\0version\";s:7:\"11.5.48\";s:6:\"\0*\0dev\";b:1;}i:13;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";r:11;s:14:\"\0*\0packageName\";s:15:\"@inertiajs/vue3\";s:10:\"\0*\0version\";s:6:\"2.3.10\";s:6:\"\0*\0dev\";b:0;}i:14;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";E:41:\"Laravel\\Roster\\Enums\\Packages:INERTIA_VUE\";s:14:\"\0*\0packageName\";s:15:\"@inertiajs/vue3\";s:10:\"\0*\0version\";s:6:\"2.3.10\";s:6:\"\0*\0dev\";b:0;}i:15;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";E:41:\"Laravel\\Roster\\Enums\\Packages:TAILWINDCSS\";s:14:\"\0*\0packageName\";s:11:\"tailwindcss\";s:10:\"\0*\0version\";s:6:\"3.4.19\";s:6:\"\0*\0dev\";b:0;}i:16;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";E:33:\"Laravel\\Roster\\Enums\\Packages:VUE\";s:14:\"\0*\0packageName\";s:3:\"vue\";s:10:\"\0*\0version\";s:6:\"3.5.26\";s:6:\"\0*\0dev\";b:0;}i:17;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";r:11;s:14:\"\0*\0packageName\";s:15:\"@inertiajs/vue3\";s:10:\"\0*\0version\";s:6:\"2.3.10\";s:6:\"\0*\0dev\";b:1;}i:18;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";r:109;s:14:\"\0*\0packageName\";s:15:\"@inertiajs/vue3\";s:10:\"\0*\0version\";s:6:\"2.3.10\";s:6:\"\0*\0dev\";b:1;}i:19;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";r:46;s:14:\"\0*\0packageName\";s:30:\"@laravel/vite-plugin-wayfinder\";s:10:\"\0*\0version\";s:5:\"0.1.7\";s:6:\"\0*\0dev\";b:1;}i:20;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";E:44:\"Laravel\\Roster\\Enums\\Packages:WAYFINDER_VITE\";s:14:\"\0*\0packageName\";s:30:\"@laravel/vite-plugin-wayfinder\";s:10:\"\0*\0version\";s:5:\"0.1.7\";s:6:\"\0*\0dev\";b:1;}i:21;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";E:36:\"Laravel\\Roster\\Enums\\Packages:ESLINT\";s:14:\"\0*\0packageName\";s:6:\"eslint\";s:10:\"\0*\0version\";s:6:\"9.39.2\";s:6:\"\0*\0dev\";b:1;}i:22;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";E:38:\"Laravel\\Roster\\Enums\\Packages:PRETTIER\";s:14:\"\0*\0packageName\";s:8:\"prettier\";s:10:\"\0*\0version\";s:5:\"3.8.0\";s:6:\"\0*\0dev\";b:1;}i:23;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";r:116;s:14:\"\0*\0packageName\";s:11:\"tailwindcss\";s:10:\"\0*\0version\";s:6:\"3.4.19\";s:6:\"\0*\0dev\";b:1;}i:24;O:22:\"Laravel\\Roster\\Package\":6:{s:9:\"\0*\0direct\";b:0;s:13:\"\0*\0constraint\";s:0:\"\";s:10:\"\0*\0package\";r:123;s:14:\"\0*\0packageName\";s:3:\"vue\";s:10:\"\0*\0version\";s:6:\"3.5.26\";s:6:\"\0*\0dev\";b:1;}}s:28:\"\0*\0escapeWhenCastingToString\";b:0;}s:21:\"\0*\0nodePackageManager\";E:43:\"Laravel\\Roster\\Enums\\NodePackageManager:NPM\";}s:9:\"timestamp\";i:1768656186;}',1768742586),('laravel-cache-demo@localhost.com|127.0.0.1','i:1;',1769080252),('laravel-cache-demo@localhost.com|127.0.0.1:timer','i:1769080252;',1769080252);
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
  `designation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_salary` decimal(12,2) NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `employees_employee_id_unique` (`employee_id`),
  KEY `employees_user_id_foreign` (`user_id`),
  CONSTRAINT `employees_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (2,'EMP01','Manager John','GM',5000.00,NULL,'2026-01-17 00:26:55','2026-01-17 00:26:55'),(3,'PIL-101','Abdur Rahman','Senior Mechanic',45000.00,NULL,'2026-01-17 13:05:01','2026-01-17 13:05:01'),(4,'PIL-102','Kashem Ali','Hydraulic Technician',38000.00,NULL,'2026-01-17 13:05:01','2026-01-17 13:05:01'),(5,'PIL-103','Sarker Mahmud','Maintenance Engineer',55000.00,NULL,'2026-01-17 13:05:01','2026-01-17 13:05:01'),(6,'PIL-104','Jasim Uddin','Rig Operator',42000.00,NULL,'2026-01-17 13:05:01','2026-01-17 13:05:01'),(7,'PIL-105','Nurul Islam','Assistant Mechanic',28000.00,NULL,'2026-01-17 13:05:01','2026-01-17 13:05:01');
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
INSERT INTO `equipment` VALUES (3,'Piling Rig Rig-01',NULL,'SN999','Maintenance',5,NULL,'2026-01-17 00:26:57','2026-01-18 02:44:14',2,4,0),(4,'Hydraulic Rig',NULL,'SN-001','Working',5,NULL,'2026-01-17 00:42:51','2026-01-17 02:01:18',2,4,0),(5,'Hydraulic Rig 2',NULL,'SN102','Working',3,NULL,'2026-01-17 02:12:38','2026-01-17 02:13:04',2,4,0),(6,'SANY SR2850',NULL,'SN-9920-X','Under Repair',4,NULL,'2026-01-17 02:56:00','2026-01-17 02:56:12',1,1,0),(57,'Rotary Drilling Rig SR285',NULL,'SN-SR285-101','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,1,0),(58,'Rotary Drilling Rig BG25',NULL,'SN-BG25-V2','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,2,0),(59,'Hydraulic Piling Rig KR125',NULL,'SN-KR125-09','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,3,0),(60,'Crawler Crane 50-Ton',NULL,'SN-CR-50T-01','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,1,0),(61,'Crawler Crane 75-Ton',NULL,'SN-CR-75T-05','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(62,'Vibro Hammer 60kW',NULL,'SN-VH-60-12','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(63,'Vibro Hammer 90kW',NULL,'SN-VH-90-03','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(64,'Concrete Pump Trailer',NULL,'SN-CP-880','Working',5,NULL,'2026-01-17 10:19:23','2026-01-17 05:04:40',1,6,0),(65,'Concrete Pump Truck',NULL,'SN-CPT-S9','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,1,0),(66,'Excavator PC200',NULL,'SN-EX-PC200-1','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(67,'Excavator 320D',NULL,'SN-EX-320D-2','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(68,'Wheel Loader L956F',NULL,'SN-WL-956','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(69,'Diesel Generator 150kVA',NULL,'SN-GEN-150-A','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,7,0),(70,'Diesel Generator 250kVA',NULL,'SN-GEN-250-B','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,7,0),(71,'Bentonite Mixing Plant',NULL,'SN-BMP-500','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',1,6,0),(72,'PIT Integrity Tester',NULL,'SN-PIT-882','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,4,0),(73,'PDA Dynamic Load Tester',NULL,'SN-PDA-001','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,4,0),(74,'Hydraulic Jack 500-Ton',NULL,'SN-JK-500-A','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(75,'Hydraulic Jack 500-Ton',NULL,'SN-JK-500-B','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(76,'Hydraulic Jack 800-Ton',NULL,'SN-JK-800-X','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(77,'Digital Dial Gauge 25mm',NULL,'SN-DG-01','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,5,0),(78,'Digital Dial Gauge 25mm',NULL,'SN-DG-02','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,5,0),(79,'Digital Dial Gauge 50mm',NULL,'SN-DG-03','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,5,0),(80,'Marsh Funnel Viscometer',NULL,'SN-MF-77','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,8,0),(81,'Mud Balance Scale',NULL,'SN-MB-99','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,8,0),(82,'Sand Content Kit',NULL,'SN-SC-12','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(83,'Total Station TS06',NULL,'SN-TS-009','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,9,0),(84,'Auto Level NA720',NULL,'SN-AL-101','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,9,0),(85,'Ultrasonic Pile Monitor',NULL,'SN-UPM-22','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(86,'Slump Cone Test Kit',NULL,'SN-SLUMP-01','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',2,6,0),(87,'Rock Auger 1000mm',NULL,'SN-AUG-1000R','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,2,0),(88,'Soil Auger 1200mm',NULL,'SN-AUG-1200S','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,1,0),(89,'Core Barrel 1000mm',NULL,'SN-CB-1000','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(90,'Core Barrel 1500mm',NULL,'SN-CB-1500','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(91,'Cleaning Bucket 1200mm',NULL,'SN-BK-1200','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(92,'Drilling Bucket 1000mm',NULL,'SN-BK-1000','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(93,'Kelly Bar 4-Section (48m)',NULL,'SN-KB-48','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,2,0),(94,'Kelly Bar 3-Section (36m)',NULL,'SN-KB-36','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,1,0),(95,'Casing Pipe 1200mm (6m)',NULL,'SN-CSG-1200-A','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(96,'Casing Pipe 1200mm (6m)',NULL,'SN-CSG-1200-B','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(97,'Casing Drive Adapter',NULL,'SN-CDA-1200','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(98,'Tremie Pipe Set (20m)',NULL,'SN-TP-20','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(99,'Tremie Pipe Set (30m)',NULL,'SN-TP-30','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(100,'Tremie Hopper (1.5m3)',NULL,'SN-TH-01','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(101,'Lifting Belt 10-Ton',NULL,'SN-BELT-10T','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(102,'Welding Machine 400A',NULL,'SN-WELD-400','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(103,'Air Compressor',NULL,'SN-AIR-05','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(104,'Slurry Submersible Pump',NULL,'SN-PUMP-01','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(105,'Slurry Submersible Pump',NULL,'SN-PUMP-02','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(106,'Rebar Bending Machine',NULL,'SN-BEND-01','Working',1,NULL,'2026-01-17 10:19:23','2026-01-17 10:19:23',3,6,0),(108,'Hydraulic Pressure Gauge (700 Bar)',NULL,'PG-SLT-9901','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,6,0),(109,'Digital Pressure Gauge',NULL,'DPG-MT-202','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,5,0),(110,'High-Pressure Hydraulic Hose (10m)',NULL,'HPH-10M-01','Working',4,NULL,'2026-01-17 11:06:26','2026-01-17 05:23:12',2,6,0),(111,'Mechanical Dial Gauge (50mm Travel)',NULL,'DG-50-A1','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,5,0),(112,'Mechanical Dial Gauge (50mm Travel)',NULL,'DG-50-A2','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,5,0),(113,'Digital Dial Gauge (25mm Travel)',NULL,'DDG-25-01','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,5,0),(114,'Magnetic Base for Dial Gauge',NULL,'MB-DG-01','Working',4,NULL,'2026-01-17 11:06:26','2026-01-17 23:07:08',2,6,0),(115,'Crosshole Sonic Logger (CHSL)',NULL,'CSL-PDI-101','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(116,'Sonic Logging Transducer (Emitter)',NULL,'SLT-E-202','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(117,'Sonic Logging Transducer (Receiver)',NULL,'SLT-R-203','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(118,'CSL Depth Encoder',NULL,'ENC-CSL-05','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(119,'PDA Model 8G Data Acquisition',NULL,'PDA-8G-772','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(120,'PDA Strain Transducer',NULL,'PDA-ST-01','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(121,'PDA Piezoelectric Accelerometer',NULL,'PDA-ACC-05','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(122,'Main Connection Cable (PDA to Sensors)',NULL,'CBL-PDA-15M','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(123,'PIT-V Integrity Tester',NULL,'PIT-V-330','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(124,'PIT Handheld Hammer (Large)',NULL,'PIT-HM-L','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(125,'PIT Handheld Hammer (Small)',NULL,'PIT-HM-S','Working',1,NULL,'2026-01-17 11:06:26','2026-01-17 11:06:26',2,4,0),(126,'Kelly Bar 15m Interlocking',NULL,'KB-R01-01','In Stock',5,4,'2026-01-17 12:50:35','2026-01-18 02:53:30',2,4,1),(127,'Drilling Bucket 1200mm',NULL,'DB-R01-1200','Working',5,3,'2026-01-17 12:50:35','2026-01-17 12:50:35',2,4,1),(128,'Rock Auger 800mm',NULL,'RA-R02-800','Working',5,3,'2026-01-17 12:50:35','2026-01-22 05:11:51',2,4,1),(129,'Kelly Bar 18m','Interlocking','KB-18M-001','Working',5,3,'2026-01-17 13:35:22','2026-01-17 13:35:22',2,4,1),(130,'Drilling Bucket 1500mm','Clay Type','DB-1500-05','Working',5,3,'2026-01-17 13:35:22','2026-01-17 13:35:22',2,4,1),(131,'Rock Auger 600mm','Heavy Duty','RA-600-12','Working',5,3,'2026-01-17 13:35:22','2026-01-17 13:35:22',2,4,1),(132,'Tremie Pipe Set 25m','TP-Series','TP-25-99','Working',5,3,'2026-01-17 13:35:22','2026-01-17 13:35:22',2,4,1),(133,'Casing Oscillator','1200mm','CO-1200-X','Maintenance',5,3,'2026-01-17 13:35:22','2026-01-17 13:35:22',2,4,1),(137,'Hydraulic Pump Rexroth',NULL,'PUMP-001','In Stock',1,NULL,'2026-01-18 04:40:03','2026-01-18 04:40:03',NULL,NULL,1),(138,'Engine Oil Filter XL',NULL,'FLT-990','In Stock',1,124,'2026-01-18 04:40:03','2026-01-18 03:46:20',NULL,NULL,1),(139,'Main Winch Rope 50m',NULL,'WNC-50','In Stock',1,NULL,'2026-01-18 04:40:03','2026-01-18 04:40:03',NULL,NULL,1),(140,'Kelly Bar 12m (Spare)',NULL,'KB-SP-12','In Stock',1,NULL,'2026-01-18 04:40:03','2026-01-18 04:40:03',NULL,NULL,1),(142,'Mac-5',NULL,'SN-5','Working',1,NULL,'2026-01-17 23:16:53','2026-01-17 23:16:53',NULL,NULL,0),(143,'MAC-6',NULL,'SN-6','Working',4,NULL,'2026-01-17 23:17:43','2026-01-17 23:17:43',NULL,NULL,0),(144,'KELLY - 500',NULL,'K-500','Working',5,NULL,'2026-01-17 23:19:37','2026-01-17 23:19:37',NULL,NULL,0),(145,'KElly - 102',NULL,'K-102','In Stock',4,NULL,'2026-01-17 23:21:06','2026-01-18 02:30:17',NULL,NULL,1),(147,'A',NULL,'VB','Working',5,NULL,'2026-01-18 01:50:50','2026-01-18 01:50:50',NULL,NULL,0),(148,'ABB',NULL,'EEE','Working',4,NULL,'2026-01-18 01:51:24','2026-01-18 01:51:24',NULL,NULL,0),(149,'ABD',NULL,'ABD - 1','Working',4,NULL,'2026-01-18 01:57:40','2026-01-18 01:57:40',2,9,0),(150,'Name 01',NULL,'SN - 00123','In Stock',4,NULL,'2026-01-18 01:58:06','2026-01-18 02:30:17',1,9,1),(151,'DEPO - 2',NULL,'D-2','In Stock',4,149,'2026-01-18 02:12:37','2026-01-18 02:18:51',1,8,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_movements`
--

LOCK TABLES `inventory_movements` WRITE;
/*!40000 ALTER TABLE `inventory_movements` DISABLE KEYS */;
INSERT INTO `inventory_movements` VALUES (1,3,3,3,'2026-01-17','2026-01-17 00:34:27','2026-01-17 00:34:27'),(2,3,3,4,'2026-01-17','2026-01-17 00:35:50','2026-01-17 00:35:50'),(3,3,4,5,'2026-01-17','2026-01-17 00:36:04','2026-01-17 00:36:04'),(4,4,5,3,'2026-01-17','2026-01-17 00:43:16','2026-01-17 00:43:16'),(5,3,5,3,'2026-01-17','2026-01-17 00:53:50','2026-01-17 00:53:50'),(6,3,3,4,'2026-01-17','2026-01-17 00:56:56','2026-01-17 00:56:56'),(7,4,3,5,'2026-01-29','2026-01-17 02:01:18','2026-01-17 02:01:18'),(8,3,4,3,'2026-01-17','2026-01-17 04:48:04','2026-01-17 04:48:04'),(9,3,3,4,'2026-01-17','2026-01-17 05:04:03','2026-01-17 05:04:03'),(10,64,1,5,'2026-01-17','2026-01-17 05:04:40','2026-01-17 05:04:40'),(11,3,4,5,'2026-01-17','2026-01-17 05:22:30','2026-01-17 05:22:30'),(12,110,1,4,'2026-01-17','2026-01-17 05:23:12','2026-01-17 05:23:12'),(13,114,1,4,'2026-01-18','2026-01-17 23:07:08','2026-01-17 23:07:08'),(14,3,5,4,'2026-01-18','2026-01-17 23:07:19','2026-01-17 23:07:19'),(15,3,4,3,'2026-01-18','2026-01-17 23:07:56','2026-01-17 23:07:56'),(16,3,3,5,'2026-01-18','2026-01-18 02:44:14','2026-01-18 02:44:14');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance_records`
--

LOCK TABLES `maintenance_records` WRITE;
/*!40000 ALTER TABLE `maintenance_records` DISABLE KEYS */;
INSERT INTO `maintenance_records` VALUES (2,3,2,'Routine Maintenance','2026-01-17',1250,'Hydraulic Oil Filter, Engine Oil Filter, Primary Fuel Filter',450.00,'Regular 250hr service completed.','2026-01-17 12:51:58','2026-01-17 12:51:58'),(3,3,3,'Routine Maintenance','2026-01-17',1250,'Hydraulic Oil Filter, Engine Oil Filter',450.00,'Service by Abdur Rahman.','2026-01-17 13:16:42','2026-01-17 13:16:42');
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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_01_17_054628_create_permission_tables',2),(5,'2026_01_17_055134_create_employees_table',3),(6,'2026_01_17_055134_create_sites_table',3),(7,'2026_01_17_055135_create_attendances_table',3),(8,'2026_01_17_055135_create_equipment_table',3),(9,'2026_01_17_055135_create_inventory_movements_table',3),(10,'2026_01_17_055137_create_salary_advances_table',3),(11,'2026_01_17_065223_change_status_to_string_in_equipment_table',4),(12,'2026_01_17_082034_add_category_and_brand_to_equipment_table',5),(13,'2026_01_17_090749_create_categories_and_brands_tables',6),(14,'2026_01_17_124155_add_parent_id_to_equipment_table',7),(15,'2026_01_17_124234_create_maintenance_records_table',7);
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
  `amount` decimal(12,2) NOT NULL,
  `advance_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `salary_advances_employee_id_foreign` (`employee_id`),
  CONSTRAINT `salary_advances_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_advances`
--

LOCK TABLES `salary_advances` WRITE;
/*!40000 ALTER TABLE `salary_advances` DISABLE KEYS */;
/*!40000 ALTER TABLE `salary_advances` ENABLE KEYS */;
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
INSERT INTO `sessions` VALUES ('cstY2bTy4HXTDXdqa4XEpjF4Ae5D1AfKkU90ThQ3',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0','YTo0OntzOjY6Il90b2tlbiI7czo0MDoiZkdiWE0yQm1QSE9kVHNFRndqYndGODVTVWFzejR0ZlZYRkcyN0ZIRCI7czoyMjoiUEhQREVCVUdCQVJfU1RBQ0tfREFUQSI7YTowOnt9czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1769080163),('kCsxYFpkfmPJ4iOPrhUULMu4bjm9xOcuHvsSNDJ7',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiazU2THVrdFNjb21DclpTdU1iUkVhalBHTHYzd253TnNCaEVXMEVrMiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9pbnZlbnRvcnkiO3M6NToicm91dGUiO3M6MTU6ImludmVudG9yeS5pbmRleCI7fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7czoyMjoiUEhQREVCVUdCQVJfU1RBQ0tfREFUQSI7YTowOnt9fQ==',1768659169),('MnJLusNJa2LKF0qAc9MhnoTiwnUquyUFMbW7gLJf',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','YTo0OntzOjY6Il90b2tlbiI7czo0MDoidUhmdzdWQ3RYZXNza0xFYWpqc3l2YXBjZHp2Z2RHMGFMN2VHZzRkSyI7czoyMjoiUEhQREVCVUdCQVJfU1RBQ0tfREFUQSI7YTowOnt9czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1768710918),('nr4ZoOM9jEV5r3snusKJlutCHjFADBbj2Z5VvhJV',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','YTo2OntzOjY6Il90b2tlbiI7czo0MDoiWU1HUjlLcGN0aVRFUnRqN1hab2hkSkpDMGJSOFhrSlFsTm9vOVFiZyI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjM4OiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvaW52ZW50b3J5P3BhZ2U9NSI7czo1OiJyb3V0ZSI7czoxNToiaW52ZW50b3J5LmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTtzOjIyOiJQSFBERUJVR0JBUl9TVEFDS19EQVRBIjthOjA6e319',1768730652),('sBIUWQJKCfKTupTAaMgE56r25lffshSYhN0d8RlA',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0','YTo0OntzOjY6Il90b2tlbiI7czo0MDoiS0NNckl3MVhqMWhpZHhXUHFUTXRIWmowY1U2UG5YbWN1VUhFV2FtbyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9pbnZlbnRvcnkiO3M6NToicm91dGUiO3M6MTU6ImludmVudG9yeS5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==',1769316286),('UNU3frph7QPDWyIN8g38mDorhXpDRzhfGahculLy',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiV1JqQmpmN0l6NWl2SjFKYkttbDEwcDVpM2RDaWEzSVRhOHU2VE01ZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9pbnZlbnRvcnkiO3M6NToicm91dGUiO3M6MTU6ImludmVudG9yeS5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7czoyMjoiUEhQREVCVUdCQVJfU1RBQ0tfREFUQSI7YToxOntzOjI2OiIwMUtGSlBFS1Y0MkVHS0IzOFRNRFdWUkhTNSI7Tjt9fQ==',1769080312);
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
INSERT INTO `users` VALUES (1,'AB','admin@example.com',NULL,'$2y$12$7X9Y1g3Q13xQcWlW1YBVpOT9gUHI8.MQ6qcHKC6B7FzUqkz53RbV6','Vgx8EHGsHnd0dhk9EJOmTi26fXnHjGMZlPtco3XeDlgKyas9YHdhq0gQ774l','2026-01-16 23:24:19','2026-01-16 23:24:19');
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

-- Dump completed on 2026-01-25 10:51:10
