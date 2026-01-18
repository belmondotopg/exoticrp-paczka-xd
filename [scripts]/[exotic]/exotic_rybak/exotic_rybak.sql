
DROP TABLE IF EXISTS `top_ryby`;
DROP TABLE IF EXISTS `gracze_rybacy`;

CREATE TABLE `gracze_rybacy` (
  `identifier` varchar(60) NOT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `udane_lowienia` int(11) DEFAULT 0,
  `nieudane_lowienia` int(11) DEFAULT 0,
  `najwieksza_ryba_nazwa` varchar(50) DEFAULT NULL,
  `najwieksza_ryba_waga` float DEFAULT 0,
  `najwieksza_ryba_rarity` VARCHAR(50) DEFAULT NULL,
  `player_level` int(11) DEFAULT 1,
  `player_xp` int(11) DEFAULT 0,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `top_ryby` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) NOT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `ryba_nazwa` varchar(255) NOT NULL,
  `ryba_waga` float NOT NULL,
  `data_zlowienia` timestamp NOT NULL DEFAULT current_timestamp(),
  `rarity` VARCHAR(50) NULL DEFAULT 'Pospolita',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `achievements_progress` (
  `identifier` varchar(60) NOT NULL,
  `achievement_id` varchar(50) NOT NULL,
  `current_progress` int(11) DEFAULT 0,
  `completed_tier` int(11) DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`, `achievement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
