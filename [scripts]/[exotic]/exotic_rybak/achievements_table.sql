CREATE TABLE IF NOT EXISTS `achievements_progress` (
  `identifier` varchar(60) NOT NULL,
  `achievement_id` varchar(50) NOT NULL,
  `current_progress` int(11) DEFAULT 0,
  `completed_tier` int(11) DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`identifier`, `achievement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

