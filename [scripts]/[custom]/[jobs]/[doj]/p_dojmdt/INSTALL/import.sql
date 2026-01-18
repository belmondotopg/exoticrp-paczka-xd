CREATE TABLE `doj_accounts_note` (
  `account` varchar(60) NOT NULL,
  `note` longtext NOT NULL
);

CREATE TABLE `doj_announcements` (
  `id` int(11) NOT NULL,
  `title` varchar(60) NOT NULL,
  `content` longtext NOT NULL,
  `priority` int(1) NOT NULL DEFAULT 1,
  `job` varchar(60) NOT NULL,
  `author` varchar(46) NOT NULL,
  `expire` bigint(30) NOT NULL,
  `time` bigint(30) NOT NULL
);

CREATE TABLE `doj_citizen_profiles` (
  `player` varchar(46) NOT NULL,
  `picture` longtext DEFAULT NULL,
  `notes` longtext DEFAULT NULL,
  `tags` longtext DEFAULT NULL
);

CREATE TABLE `doj_companies` (
  `name` varchar(30) NOT NULL,
  `picture` longtext DEFAULT NULL,
  `invoices` longtext DEFAULT NULL
);

CREATE TABLE `doj_courts` (
  `id` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `type` varchar(30) NOT NULL,
  `room` varchar(10) NOT NULL,
  `status` int(1) NOT NULL DEFAULT 0,
  `requireAccused` tinyint(1) NOT NULL,
  `courtTime` bigint(25) NOT NULL,
  `time` bigint(20) NOT NULL,
  `notifications` longtext DEFAULT NULL,
  `jail` int(11) DEFAULT NULL,
  `fine` int(11) DEFAULT NULL,
  `verdict` varchar(20) DEFAULT NULL,
  `summary` longtext DEFAULT NULL
);

CREATE TABLE `doj_employee_profiles` (
  `identifier` varchar(46) NOT NULL,
  `picture` longtext DEFAULT NULL,
  `notes` longtext NOT NULL,
  `tags` longtext DEFAULT NULL,
  `licenses` longtext DEFAULT NULL,
  `joinDate` varchar(25) NOT NULL
);

CREATE TABLE `doj_inspections` (
  `id` int(11) NOT NULL,
  `place` varchar(50) NOT NULL,
  `representative` varchar(46) NOT NULL,
  `inspector` varchar(46) NOT NULL,
  `purpose` varchar(100) NOT NULL,
  `result` int(1) NOT NULL,
  `summary` longtext NOT NULL,
  `time` bigint(25) NOT NULL
);

CREATE TABLE `doj_reports` (
  `id` int(11) NOT NULL,
  `applicant` varchar(46) NOT NULL,
  `suing` varchar(46) NOT NULL,
  `accused` varchar(46) NOT NULL,
  `prosecutor` varchar(46) DEFAULT NULL,
  `judge` varchar(46) DEFAULT NULL,
  `reason` varchar(150) NOT NULL,
  `claims` longtext NOT NULL,
  `justification` longtext NOT NULL,
  `status` varchar(30) NOT NULL,
  `rejectReason` varchar(200) DEFAULT NULL,
  `job` varchar(20) NOT NULL,
  `time` bigint(25) NOT NULL,
  `shared` longtext DEFAULT NULL
);

CREATE TABLE `doj_society` (
  `job` varchar(30) NOT NULL,
  `balance` int(11) NOT NULL,
  `income` int(11) NOT NULL,
  `outcome` int(11) NOT NULL,
  `transactions` longtext DEFAULT NULL,
  `chart` longtext DEFAULT NULL
);

CREATE TABLE `doj_vehicle_profiles` (
  `plate` varchar(8) NOT NULL,
  `picture` longtext DEFAULT NULL,
  `tags` longtext DEFAULT NULL,
  `notes` longtext DEFAULT NULL,
  `ownership` longtext DEFAULT NULL
);

ALTER TABLE `doj_accounts_note`
  ADD PRIMARY KEY (`account`);

ALTER TABLE `doj_announcements`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `doj_citizen_profiles`
  ADD PRIMARY KEY (`player`);

ALTER TABLE `doj_companies`
  ADD PRIMARY KEY (`name`);

ALTER TABLE `doj_courts`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `doj_employee_profiles`
  ADD PRIMARY KEY (`identifier`);

ALTER TABLE `doj_inspections`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `doj_reports`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `doj_society`
  ADD PRIMARY KEY (`job`);

ALTER TABLE `doj_vehicle_profiles`
  ADD PRIMARY KEY (`plate`);

ALTER TABLE `doj_announcements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `doj_courts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `doj_inspections`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `doj_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;