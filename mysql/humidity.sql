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
