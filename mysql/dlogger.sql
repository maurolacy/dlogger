--
-- Host: localhost    Database: dlogger
-- ------------------------------------------------------
-- Server version	5.5.31-0+wheezy1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `temp`
--

DROP TABLE IF EXISTS `temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temp` (
  `ts` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `c` float(4) NOT NULL,
  `duration` smallint(6) NOT NULL default '0',
  `interval` smallint(6) NOT NULL default '60',
  PRIMARY KEY  (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `pressure`
--

DROP TABLE IF EXISTS `pressure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pressure` (
  `ts` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `mb` int(4) NOT NULL,
  `duration` smallint(6) NOT NULL default '0',
  `interval` smallint(6) NOT NULL default '60',
  PRIMARY KEY  (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Table structure for table `rad`
--

DROP TABLE IF EXISTS `rad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rad` (
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `count` int(11) NOT NULL,
  `duration` smallint(6) NOT NULL DEFAULT '60',
  `interval` smallint(6) NOT NULL DEFAULT '60',
  PRIMARY KEY (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Table structure for table `X`
--

DROP TABLE IF EXISTS `X`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `X` (
  `ts` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `julian` float(6) NOT NULL,
  `seconds` smallint(6) NOT NULL,
  `short` float(6) NOT NULL,
  `long` float(6) NOT NULL,
  `duration` smallint(6) NOT NULL default '60',
  `interval` smallint(6) NOT NULL default '0',
  PRIMARY KEY  (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Table structure for table `accel`
--

DROP TABLE IF EXISTS `accel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accel` (
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `x` float(6) NOT NULL,
  `y` float(6) NOT NULL,
  `z` float(6) NOT NULL,
  `duration` smallint(6) NOT NULL DEFAULT '0',
  `interval` smallint(6) NOT NULL DEFAULT '10',
  PRIMARY KEY (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

-- Table structure for table `gps`
--

DROP TABLE IF EXISTS `gps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gps` (
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `time` timestamp NOT NULL,
  `lat` float(6) DEFAULT NULL,
  `lon` float(6) DEFAULT NULL,
  `alt` float(3) DEFAULT NULL,
  `track` float(4) DEFAULT NULL,
  `speed` float(3) DEFAULT NULL,
  `climb` float(3) DEFAULT NULL,
  `duration` smallint(6) NOT NULL DEFAULT '0',
  `interval` smallint(6) NOT NULL DEFAULT '30',
  PRIMARY KEY (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

-- Table structure for table `encoder`
--

DROP TABLE IF EXISTS `encoder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `encoder` (
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `counts` int(6) NOT NULL DEFAULT '0',
  `duration` smallint(6) NOT NULL DEFAULT '0',
  `interval` smallint(6) NOT NULL DEFAULT '10',
  PRIMARY KEY (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

-- Table structure for table `part`
--

DROP TABLE IF EXISTS `part`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `part` (
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hour` int(6) NOT NULL DEFAULT '0',
  `lat` float(4) NOT NULL DEFAULT '0',
  `lon` float(4) NOT NULL DEFAULT '0',
  `drift` int(6) NOT NULL DEFAULT '0',
  `speed` float(4) NOT NULL DEFAULT '0',
  `particles` int(6) NOT NULL DEFAULT '0',
  `duration` smallint(6) NOT NULL DEFAULT '0',
  `interval` smallint(6) NOT NULL DEFAULT '30',
  PRIMARY KEY (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

-- Table structure for table `dust`
--

DROP TABLE IF EXISTS `dust`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dust` (
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `low_percent` float(4) NOT NULL DEFAULT '0',
  `pcs` int(6) NOT NULL DEFAULT '0',
  `duration` smallint(6) NOT NULL DEFAULT '0',
  `interval` smallint(6) NOT NULL DEFAULT '30',
  PRIMARY KEY (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

-- Table structure for table `pressure`
--

DROP TABLE IF EXISTS `pressure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pressure` (
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `temp` float(1) NOT NULL DEFAULT '0',
  `pressure` float(2) NOT NULL DEFAULT '0',
  `duration` smallint(6) NOT NULL DEFAULT '0',
  `interval` smallint(6) NOT NULL DEFAULT '30',
  PRIMARY KEY (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;


-- Table structure for table `humidity`
--

DROP TABLE IF EXISTS `humidity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `humidity` (
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `humidity` float NOT NULL DEFAULT '0',
  `temperature` float NOT NULL DEFAULT '0',
  `result` char(3) NOT NULL DEFAULT 'BAD',
  `duration` smallint(6) NOT NULL DEFAULT '0',
  `interval` smallint(6) NOT NULL DEFAULT '30',
  PRIMARY KEY (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;


-- Table structure for table `mag`
--

DROP TABLE IF EXISTS `mag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mag` (
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `X` float NOT NULL DEFAULT '0',
  `Y` float NOT NULL DEFAULT '0',
  `Z` float NOT NULL DEFAULT '0',
  `duration` smallint(6) NOT NULL DEFAULT '0',
  `interval` smallint(6) NOT NULL DEFAULT '30',
  PRIMARY KEY (`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
