CREATE TABLE `doj_outfits` (
  `id` int(11) NOT NULL,
  `job` varchar(30) NOT NULL,
  `grade` longtext NOT NULL,
  `label` varchar(60) NOT NULL,
  `gender` varchar(10) NOT NULL,
  `license` longtext DEFAULT 'none',
  `requirements` varchar(50) NOT NULL,
  `skin` longtext NOT NULL
);

ALTER TABLE `doj_outfits`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `doj_outfits`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;