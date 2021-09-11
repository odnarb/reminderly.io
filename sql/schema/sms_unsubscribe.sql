CREATE TABLE `sms_unsubscribe` (
    `id` INT AUTO_INCREMENT,
    `customer_id` INT NOT NULL,
    `phone_number` VARCHAR(20) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;