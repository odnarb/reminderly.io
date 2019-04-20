CREATE TABLE `messages_history_7` (
    `id` INT AUTO_INCREMENT,
    `data_packet_id` INT NOT NULL,
    `company_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `contact_method_id` INT NOT NULL,
    `contact_status_id` INT NOT NULL, -- {message sent, contacted, failed, etc}
    `data` json NOT NULL,
    `contact_date` DATETIME NOT NULL,
    `contact_status_description` VARCHAR(255) NOT NULL DEFAULT '', -- {why it failed, etc}
    `raw_response` VARCHAR(80) NOT NULL DEFAULT '', -- [DTMF, character, word, raw data] -- we don't campture anything but phone calls
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_packet_id`) REFERENCES data_packet (`id`),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    FOREIGN KEY (`contact_method_id`) REFERENCES contact_method (`id`),
    FOREIGN KEY (`contact_status_id`) REFERENCES contact_status (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;

CREATE TABLE `messages_history_8` (
    `id` INT AUTO_INCREMENT,
    `data_packet_id` INT NOT NULL,
    `company_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `contact_method_id` INT NOT NULL,
    `contact_status_id` INT NOT NULL, -- {message sent, contacted, failed, etc}
    `data` json NOT NULL,
    `contact_date` DATETIME NOT NULL,
    `contact_status_description` VARCHAR(255) NOT NULL DEFAULT '', -- {why it failed, etc}
    `raw_response` VARCHAR(80) NOT NULL DEFAULT '', -- [DTMF, character, word, raw data] -- we don't campture anything but phone calls
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_packet_id`) REFERENCES data_packet (`id`),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    FOREIGN KEY (`contact_method_id`) REFERENCES contact_method (`id`),
    FOREIGN KEY (`contact_status_id`) REFERENCES contact_status (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;
