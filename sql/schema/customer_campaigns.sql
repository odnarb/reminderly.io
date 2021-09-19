/*
-a campaign should have at least one data source.. (MVP just one)
-a campaign each data source has a mapping
-a campaign should have contact methods
-a campaign should have messages defined
-a campaign should have a schedule of contact windows.. or now..
-a campaign should define if confirm, cancel, reschedule options available

For certain contact types we will need a bare minimum of fields defined and mapped:
    sms: to, message body
    email: to, subject line, message body
    phone: to, message body

    * if the message template pulls from a field that's not available in the map, then we'll throw an error
*/
CREATE TABLE `customer_campaigns` (
    `id` INT AUTO_INCREMENT,
    `customer_id` INT NOT NULL,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `data` json NOT NULL,
    `active` INT NOT NULL DEFAULT 0,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;