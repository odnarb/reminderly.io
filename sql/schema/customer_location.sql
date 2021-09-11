CREATE TABLE `customer_location` (
    `id` INT AUTO_INCREMENT,
    `customer_id` INT NOT NULL,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `address_1` VARCHAR(80) NOT NULL DEFAULT '',
    `address_2` VARCHAR(80) NOT NULL DEFAULT '',
    `city` VARCHAR(80) NOT NULL DEFAULT '',
    `state` VARCHAR(80) NOT NULL DEFAULT '',
    `zip` VARCHAR(20) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;