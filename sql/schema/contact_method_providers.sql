/*
table for our current contact method providers
*/
CREATE TABLE `contact_method_providers` (
    `id` INT AUTO_INCREMENT,
    `contact_method_id` INT NOT NULL,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `url` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`contact_method_id`) REFERENCES contact_methods (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;