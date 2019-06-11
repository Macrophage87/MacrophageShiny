-- MySQL dump 10.17  Distrib 10.3.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: transcriptome
-- ------------------------------------------------------
-- Server version	10.3.14-MariaDB-1:10.3.14+maria~bionic

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `DataSets`
--

DROP TABLE IF EXISTS `DataSets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DataSets` (
  `dataset_id` int(11) NOT NULL,
  `organism_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`dataset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `affymetrix_chips`
--

DROP TABLE IF EXISTS `affymetrix_chips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `affymetrix_chips` (
  `affymetrix_chip_id` int(11) NOT NULL AUTO_INCREMENT,
  `affymetrix_chip_name` varchar(200) DEFAULT NULL,
  `full_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`affymetrix_chip_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `app_list`
--

DROP TABLE IF EXISTS `app_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `app_list` (
  `app_id` int(11) NOT NULL AUTO_INCREMENT,
  `app_name` varchar(256) DEFAULT NULL,
  `srv_directory` varchar(256) DEFAULT NULL,
  `home_directory` varchar(256) DEFAULT NULL,
  `uri` varchar(256) DEFAULT NULL,
  `icon` varchar(256) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `order` int(11) DEFAULT NULL,
  `offline` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`app_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gene_groups`
--

DROP TABLE IF EXISTS `gene_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene_groups` (
  `gene_group_id` int(11) NOT NULL AUTO_INCREMENT,
  `gene_group_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`gene_group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1357 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gene_status`
--

DROP TABLE IF EXISTS `gene_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene_status` (
  `gene_status_id` int(11) NOT NULL AUTO_INCREMENT,
  `gene_status_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`gene_status_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `genes`
--

DROP TABLE IF EXISTS `genes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `genes` (
  `gene_id` int(11) NOT NULL AUTO_INCREMENT,
  `gene_symbol` varchar(200) DEFAULT NULL,
  `gene_name` varchar(200) DEFAULT NULL,
  `gene_status` int(11) DEFAULT NULL,
  `gene_synonyms` blob DEFAULT NULL,
  `chromosone` varchar(200) DEFAULT NULL,
  `ensembl_id` varchar(200) DEFAULT NULL,
  `hgnc_id` int(11) DEFAULT NULL,
  `ncbi_id` int(11) DEFAULT NULL,
  `pubmed_id` blob DEFAULT NULL,
  `accession_numbers` blob DEFAULT NULL,
  `refseq_ids` blob DEFAULT NULL,
  `species_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`gene_id`),
  KEY `gene_status` (`gene_status`),
  CONSTRAINT `genes_ibfk_1` FOREIGN KEY (`gene_status`) REFERENCES `gene_status` (`gene_status_id`)
) ENGINE=InnoDB AUTO_INCREMENT=92443 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kegg_pathways`
--

DROP TABLE IF EXISTS `kegg_pathways`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kegg_pathways` (
  `kegg_pw_id` int(11) NOT NULL AUTO_INCREMENT,
  `pathway_id` varchar(200) DEFAULT NULL,
  `pathway_name` varchar(200) DEFAULT NULL,
  `species_id` int(11) DEFAULT NULL,
  `png_exists` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`kegg_pw_id`)
) ENGINE=InnoDB AUTO_INCREMENT=331 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kegg_pw_mapping`
--

DROP TABLE IF EXISTS `kegg_pw_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kegg_pw_mapping` (
  `kegg_pw_map_id` int(11) NOT NULL AUTO_INCREMENT,
  `kegg_pw_id` int(11) DEFAULT NULL,
  `gene_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`kegg_pw_map_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28004 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kegg_statistics`
--

DROP TABLE IF EXISTS `kegg_statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kegg_statistics` (
  `kegg_statistic_id` int(11) NOT NULL AUTO_INCREMENT,
  `timepoint` double DEFAULT NULL,
  `kegg_pw_id` int(11) DEFAULT NULL,
  `sig_genes` int(11) DEFAULT NULL,
  `total_genes` int(11) DEFAULT NULL,
  `nlogp` double DEFAULT NULL,
  PRIMARY KEY (`kegg_statistic_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1621 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ontologies`
--

DROP TABLE IF EXISTS `ontologies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ontologies` (
  `ont_sql_id` int(11) NOT NULL AUTO_INCREMENT,
  `ontology_id` varchar(256) DEFAULT NULL,
  `ontology_name` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`ont_sql_id`)
) ENGINE=InnoDB AUTO_INCREMENT=45018 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ontology_analysis`
--

DROP TABLE IF EXISTS `ontology_analysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ontology_analysis` (
  `ont_anal_id` int(11) NOT NULL AUTO_INCREMENT,
  `ont_sql_id` int(11) DEFAULT NULL,
  `timepoint` double DEFAULT NULL,
  `sig_genes` int(11) DEFAULT NULL,
  `total_genes` int(11) DEFAULT NULL,
  `nlogp` double DEFAULT NULL,
  PRIMARY KEY (`ont_anal_id`)
) ENGINE=InnoDB AUTO_INCREMENT=95670 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ontology_gene_map`
--

DROP TABLE IF EXISTS `ontology_gene_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ontology_gene_map` (
  `ont_gene_map_id` int(11) NOT NULL AUTO_INCREMENT,
  `ont_sql_id` int(11) DEFAULT NULL,
  `gene_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`ont_gene_map_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1562445 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ontology_genes`
--

DROP TABLE IF EXISTS `ontology_genes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ontology_genes` (
  `ont_sql_id` int(11) DEFAULT NULL,
  `gene_id` int(11) DEFAULT NULL,
  `ont_gene_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `probes`
--

DROP TABLE IF EXISTS `probes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `probes` (
  `probe_id` int(11) NOT NULL AUTO_INCREMENT,
  `gene_id` int(11) DEFAULT NULL,
  `probeset` varchar(200) DEFAULT NULL,
  `nProbes` int(11) DEFAULT NULL,
  `ncbi_id` int(11) DEFAULT NULL,
  `process` double DEFAULT NULL,
  `specificity` double DEFAULT NULL,
  `coverage` double DEFAULT NULL,
  `robust` double DEFAULT NULL,
  `overall` double DEFAULT NULL,
  `symbol` varchar(200) DEFAULT NULL,
  `best` int(11) DEFAULT NULL,
  `affymetrix_chip_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`probe_id`),
  KEY `gene_id` (`gene_id`),
  CONSTRAINT `probes_ibfk_1` FOREIGN KEY (`gene_id`) REFERENCES `genes` (`gene_id`)
) ENGINE=InnoDB AUTO_INCREMENT=45568 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sample_info_virus`
--

DROP TABLE IF EXISTS `sample_info_virus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample_info_virus` (
  `siv_id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_id` int(11) DEFAULT NULL,
  `sample_type_id` int(11) DEFAULT NULL,
  `infected_species_id` int(11) DEFAULT NULL,
  `viral_strain_id` int(11) DEFAULT NULL,
  `timepoint` double DEFAULT NULL,
  `biol_replicate` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`siv_id`),
  KEY `sample_type_id` (`sample_type_id`),
  KEY `infected_species_id` (`infected_species_id`),
  CONSTRAINT `infected_species_id` FOREIGN KEY (`infected_species_id`) REFERENCES `species` (`species_id`),
  CONSTRAINT `sample_type_id` FOREIGN KEY (`sample_type_id`) REFERENCES `sample_types` (`sample_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sample_types`
--

DROP TABLE IF EXISTS `sample_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample_types` (
  `sample_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_type_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`sample_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `samples`
--

DROP TABLE IF EXISTS `samples`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `samples` (
  `sample_id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`sample_id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=ascii;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `species`
--

DROP TABLE IF EXISTS `species`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `species` (
  `species_id` int(1) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(200) DEFAULT NULL,
  `common_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`species_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tf_expts`
--

DROP TABLE IF EXISTS `tf_expts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tf_expts` (
  `tf_expt_id` int(11) NOT NULL,
  `experiment_name` varchar(200) DEFAULT NULL,
  `experimental` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`tf_expt_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tf_statistics`
--

DROP TABLE IF EXISTS `tf_statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tf_statistics` (
  `timepoint` double DEFAULT NULL,
  `tf_gene_id` int(11) DEFAULT NULL,
  `sig_genes` int(11) DEFAULT NULL,
  `total_genes` int(11) DEFAULT NULL,
  `nlogp` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `timepoints`
--

DROP TABLE IF EXISTS `timepoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `timepoints` (
  `timepoint_id` int(11) NOT NULL AUTO_INCREMENT,
  `timepoint_hrs` double DEFAULT NULL,
  `timepoint_friendly` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`timepoint_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trans_factor_map`
--

DROP TABLE IF EXISTS `trans_factor_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trans_factor_map` (
  `tf_map_id` int(11) NOT NULL AUTO_INCREMENT,
  `tf_expt_id` int(11) DEFAULT NULL,
  `tf_gene_id` int(11) DEFAULT NULL,
  `target_gene_id` int(11) DEFAULT NULL,
  `binding_score` double DEFAULT NULL,
  `p_value` double DEFAULT NULL,
  PRIMARY KEY (`tf_map_id`),
  KEY `tf_gene_id` (`tf_gene_id`),
  KEY `target_gene_id` (`target_gene_id`),
  CONSTRAINT `trans_factor_map_ibfk_1` FOREIGN KEY (`tf_gene_id`) REFERENCES `genes` (`gene_id`),
  CONSTRAINT `trans_factor_map_ibfk_2` FOREIGN KEY (`target_gene_id`) REFERENCES `genes` (`gene_id`)
) ENGINE=InnoDB AUTO_INCREMENT=54339476 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transcript_values`
--

DROP TABLE IF EXISTS `transcript_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transcript_values` (
  `transvalue_id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_id` int(11) DEFAULT NULL,
  `gene_id` int(11) DEFAULT NULL,
  `TPM` double DEFAULT NULL,
  `FPKM` double DEFAULT NULL,
  `expected_count` int(11) DEFAULT NULL,
  `length` double DEFAULT NULL,
  `effective_length` double DEFAULT NULL,
  PRIMARY KEY (`transvalue_id`),
  KEY `sample_id` (`sample_id`),
  KEY `gene_id` (`gene_id`),
  CONSTRAINT `gene_id` FOREIGN KEY (`gene_id`) REFERENCES `genes` (`gene_id`),
  CONSTRAINT `sample_id` FOREIGN KEY (`sample_id`) REFERENCES `samples` (`sample_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1787231 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `viral_strains`
--

DROP TABLE IF EXISTS `viral_strains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `viral_strains` (
  `viral_strain_id` int(11) NOT NULL AUTO_INCREMENT,
  `species_id` int(11) DEFAULT NULL,
  `viral_strain_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`viral_strain_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-06-11 21:07:57
