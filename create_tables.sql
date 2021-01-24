
SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

CREATE TABLE `agenda` (
  `code_agenda` bigint NOT NULL,
  `date_debut_agenda` datetime DEFAULT NULL,
  `date_fin_agenda` datetime DEFAULT NULL,
  `motif_agenda` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `matricule_enseignant` varchar(15) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`code_agenda`),
  KEY `FKi9xm9330cl1l6j2bfy38sb4g5` (`matricule_enseignant`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `calendrier` (
  `code_calendrier` bigint NOT NULL,
  `date_debut` datetime DEFAULT NULL,
  `date_fin` datetime DEFAULT NULL,
  `code_universite` bigint DEFAULT NULL,
  PRIMARY KEY (`code_calendrier`),
  KEY `FKmw3y3qpt9496f0o9tsfb3i4jm` (`code_universite`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `classe` (
  `code_classe` bigint NOT NULL,
  `matricule_enseignant` varchar(15) COLLATE utf8_bin DEFAULT NULL,
  `code_matiere` varchar(15) COLLATE utf8_bin DEFAULT NULL,
  `code_type_seance` bigint DEFAULT NULL,
  PRIMARY KEY (`code_classe`),
  KEY `FKoivrvu8bj7nqvmr96hperapnu` (`matricule_enseignant`),
  KEY `FK56c4637ya3ati6pxhh1c2eyre` (`code_matiere`),
  KEY `FKa3n6i8vb2u4tphwy7ul765uhd` (`code_type_seance`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `classe_contrainte` (
  `code_clase` bigint NOT NULL,
  `code_contrainte` bigint NOT NULL,
  KEY `FK3eh11ijn4l0dirr6pbkqv7o3g` (`code_contrainte`),
  KEY `FKt81oodwj2g2gb5m66359rhs8m` (`code_clase`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `classe_groupe` (
  `code_classe` bigint NOT NULL,
  `numero_groupe` bigint NOT NULL,
  KEY `FK59726gfr8a1m2nlsibihrlfd7` (`numero_groupe`),
  KEY `FKgb1q45pccpucqcfop84u12fw3` (`code_classe`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `classe_salle` (
  `code_classe` bigint NOT NULL,
  `code_salle` varchar(255) COLLATE utf8_bin NOT NULL,
  `penalty` int DEFAULT NULL,
  PRIMARY KEY (`code_classe`,`code_salle`),
  KEY `FKs3ml6utnm9y78xqwubpb6gt6h` (`code_salle`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `commentaire` (
  `numero_commentaire` bigint NOT NULL,
  `libelle_commentaire` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`numero_commentaire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `contrainte` (
  `code_contrainte` bigint NOT NULL,
  `type_contrainte` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`code_contrainte`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `departement` (
  `code_departement` bigint NOT NULL,
  `nom_departement` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_faculte` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`code_departement`),
  KEY `FKk4cv1gydvl4j96cqs8a2gf88s` (`code_faculte`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `diplome` (
  `code_diplome` bigint NOT NULL,
  `libelle_diplome` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_etape` varchar(15) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`code_diplome`),
  KEY `FKrsa150876enwxknlfmnrwmfpj` (`code_etape`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `enseignant` (
  `matricule_enseignant` varchar(15) COLLATE utf8_bin NOT NULL,
  `obligation_theorique_enseignent` int DEFAULT NULL,
  `email_enseignant` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `nom_enseignant` varchar(45) COLLATE utf8_bin DEFAULT NULL,
  `prenom_enseignant` varchar(60) COLLATE utf8_bin DEFAULT NULL,
  `code_departement` bigint DEFAULT NULL,
  `code_statut` bigint DEFAULT NULL,
  PRIMARY KEY (`matricule_enseignant`),
  KEY `FKpowvieb1no4nsit1o1cdhrkrm` (`code_departement`),
  KEY `FKr4s61bp5yux97flyk91da3vdx` (`code_statut`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `equipement` (
  `type_equipement` varchar(2) COLLATE utf8_bin NOT NULL,
  `code_equipement` bigint NOT NULL,
  `nom_equipement` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_salle` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_ue` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`code_equipement`),
  KEY `FK68v9eo3shu6lurwio3na5hxbo` (`code_salle`),
  KEY `FK3px70fx6f1mxvkbew2qg13g8h` (`code_ue`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `etape` (
  `code_etape` varchar(15) COLLATE utf8_bin NOT NULL,
  `libelle_etape` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `code_departement` bigint DEFAULT NULL,
  PRIMARY KEY (`code_etape`),
  KEY `FK1l3oqpo80effxjfns9a5n8d1o` (`code_departement`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `etudiant` (
  `code_etudiant` varchar(255) COLLATE utf8_bin NOT NULL,
  `email_etudiant` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `nom_etudiant` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `prenom_etudiant` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_groupe` bigint DEFAULT NULL,
  PRIMARY KEY (`code_etudiant`),
  KEY `FKrjjq13ic58vacwi09blk6c00c` (`code_groupe`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `evenement` (
  `code_evenement` bigint NOT NULL,
  `date_debut` datetime DEFAULT NULL,
  `date_fin` datetime DEFAULT NULL,
  `type_evenement` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_calendrier` bigint DEFAULT NULL,
  PRIMARY KEY (`code_evenement`),
  KEY `FK8sufww86ifysc0xx38elwjusg` (`code_calendrier`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `faculte` (
  `code_faculte` varchar(255) COLLATE utf8_bin NOT NULL,
  `lieu_faculte` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `nom_faculte` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `code_universite` bigint DEFAULT NULL,
  PRIMARY KEY (`code_faculte`),
  KEY `FKfti3usn1jt02b5afq9hd1yn9i` (`code_universite`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `groupe` (
  `numero_groupe` bigint NOT NULL,
  `libelle_groupe` varchar(30) COLLATE utf8_bin DEFAULT NULL,
  `code_groupe_parent` bigint DEFAULT NULL,
  `code_etape` varchar(15) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`numero_groupe`),
  KEY `FK2ya1r8xhar59bklcxs2nlvyhl` (`code_etape`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `hibernate_sequence` (
  `next_val` bigint DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `matiere` (
  `code_matiere` varchar(15) COLLATE utf8_bin NOT NULL,
  `charge_cm_matiere` int DEFAULT NULL,
  `charge_tp_matiere` int DEFAULT NULL,
  `ects_matiere` int DEFAULT NULL,
  `libelle_matiere` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `volume_horaire_matiere` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_ue` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`code_matiere`),
  KEY `FK6wh1bwxhwaee9chhsxb3vpwyg` (`code_ue`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `periode` (
  `code_periode` bigint NOT NULL,
  `annee_periode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `libelle_periode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`code_periode`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `programme` (
  `code_programme` bigint NOT NULL,
  `debut_programme` int DEFAULT NULL,
  `duree_programme` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `jour_programme` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `penalty_programme` int DEFAULT NULL,
  `semaine_programme` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_classe` bigint DEFAULT NULL,
  PRIMARY KEY (`code_programme`),
  KEY `FKas7hhp33w2rftxcildm5inb5r` (`code_classe`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `salle` (
  `code_salle` varchar(255) COLLATE utf8_bin NOT NULL,
  `capacite_salle` int DEFAULT NULL,
  `libelle_salle` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_departement` bigint DEFAULT NULL,
  `code_type_salle` bigint DEFAULT NULL,
  PRIMARY KEY (`code_salle`),
  KEY `FKfmch7mnncnd7rfuu54h633aba` (`code_departement`),
  KEY `FKgnf0h4lgps07vgvhr7a3eh9q1` (`code_type_salle`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `seance` (
  `code_seance` bigint NOT NULL,
  `date_seance` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `duree_seance` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `libelle_matiere` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_classe` bigint DEFAULT NULL,
  `numero_commentaire` bigint DEFAULT NULL,
  `code_salle` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_type_seance` bigint DEFAULT NULL,
  PRIMARY KEY (`code_seance`),
  KEY `FK8if8w2gaqd3htskn3s0w24f0m` (`code_classe`),
  KEY `FKet7u8dpkg1yym1fnlwut4tdwm` (`numero_commentaire`),
  KEY `FKs8qekijtd3segx8sumgllpi46` (`code_salle`),
  KEY `FKoh8f6edpbjfgct2ujhowsla32` (`code_type_seance`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `seance_enseignant` (
  `code_seance` bigint NOT NULL,
  `matricule_enseignant` varchar(15) COLLATE utf8_bin NOT NULL,
  KEY `FKse12ewhafppd6sc2gqspa4wps` (`matricule_enseignant`),
  KEY `FK2kch6c110x887q5pqxuxlcwgx` (`code_seance`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `statut_enseignant` (
  `code_statut` bigint NOT NULL,
  `libelle_statut` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`code_statut`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `type_salle` (
  `code_type_salle` bigint NOT NULL,
  `libelle_type_salle` varchar(30) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`code_type_salle`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `type_seance` (
  `code_type_seance` bigint NOT NULL,
  `couleur_type_cours` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `libelle_type_cours` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`code_type_seance`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `ue_etape` (
  `code_ue` varchar(255) COLLATE utf8_bin NOT NULL,
  `code_etape` varchar(15) COLLATE utf8_bin NOT NULL,
  KEY `FK51rrqqdljqvo4lxtrjxhyhufx` (`code_etape`),
  KEY `FKj3gih08xd2e97oynstvx7aos6` (`code_ue`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `unite_enseignement` (
  `code_ue` varchar(255) COLLATE utf8_bin NOT NULL,
  `ects_ue` int DEFAULT NULL,
  `charge_prevu_cm_ue` int DEFAULT NULL,
  `charge_prevu_tp_ue` int DEFAULT NULL,
  `effectif_prevu_ue` int DEFAULT NULL,
  `nom_ue` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `volume_horaire_ue` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code_periode` bigint DEFAULT NULL,
  PRIMARY KEY (`code_ue`),
  KEY `FKboxwqvl513hb4xio40bpi8rq7` (`code_periode`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `universite` (
  `code_universite` bigint NOT NULL,
  `lieu_universite` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `nom_universite` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`code_universite`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

