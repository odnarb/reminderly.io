CREATE TABLE `phone_unsubscribe` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `phone_number` VARCHAR(20) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;