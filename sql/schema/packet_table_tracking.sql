-- this is for tracking the data packet tables we have in order to manage them, perform unions, etc
CREATE TABLE `packet_table_tracking` (
    `id` INT AUTO_INCREMENT,
    `campaign_id` INT NOT NULL,
    `server_name` VARCHAR(255) NOT NULL DEFAULT '',
    `table_name` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`campaign_id`) REFERENCES company_campaigns (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;