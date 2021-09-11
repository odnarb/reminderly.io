CREATE TABLE `email_queue` (
    `id` INT AUTO_INCREMENT,
    `message_id` INT NOT NULL,
    `to_email` VARCHAR(255) NOT NULL DEFAULT '',
    `from_email` VARCHAR(255) NOT NULL DEFAULT '',
    `reply_to` VARCHAR(255) NOT NULL DEFAULT '',
    `data` json NOT NULL,
    `contact_date` DATETIME NOT NULL,
    `priority` INT NOT NULL DEFAULT 0,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`message_id`) REFERENCES messages (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;