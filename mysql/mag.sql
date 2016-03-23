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
