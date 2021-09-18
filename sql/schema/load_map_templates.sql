CREATE TABLE `load_map_templates` (
    `id` INT AUTO_INCREMENT,
    `load_name` VARCHAR(255) NOT NULL DEFAULT '',
    `system_name` VARCHAR(255) NOT NULL DEFAULT '',
    `system_version` VARCHAR(255) NOT NULL DEFAULT '',
    `load_map` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;