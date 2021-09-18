CREATE TABLE `campaign_load_map` (
    `id` INT AUTO_INCREMENT,
    `campaign_id` INT NOT NULL,
    `load_name` VARCHAR(255) NOT NULL DEFAULT '',
    `system_name` VARCHAR(255) NOT NULL DEFAULT '',
    `system_version` VARCHAR(255) NOT NULL DEFAULT '',
    `load_map` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`campaign_id`) REFERENCES customer_campaigns (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;