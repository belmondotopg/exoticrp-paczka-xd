
CREATE TABLE IF NOT EXISTS `daily_missions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) NOT NULL,
  `date` date NOT NULL,
  `mission_index` int(11) NOT NULL,
  `mission_type` varchar(50) NOT NULL,
  `goal` int(11) NOT NULL,
  `progress` int(11) DEFAULT 0,
  `completed` boolean DEFAULT false,
  `reward_money` int(11) NOT NULL,
  `reward_xp` int(11) NOT NULL,
  `description` varchar(255) NOT NULL,
  `data` longtext DEFAULT NULL, -- JSON dla dodatkowych danych (np. nazwa ryby)
  PRIMARY KEY (`id`),
  KEY `idx_daily_missions_identifier_date` (`identifier`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

