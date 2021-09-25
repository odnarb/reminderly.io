/*
    This is merely a template of the packet data table..
    name should be: packet_1337_07022020_1_data
*/
CREATE TABLE `packet_data_template` (
    `id` INT AUTO_INCREMENT,
    `data_packet_id` INT NOT NULL,
    `contact_status_id` INT NOT NULL, -- {message sent, contacted, failed, etc}
    `contact_method_id` INT NOT NULL, -- fill this after contact made?
    `data` json NOT NULL,
    `raw_response` VARCHAR(80) NOT NULL DEFAULT '', -- [DTMF, character, word, raw data] -- we don't capture anything but phone calls
    `num_tries` INT NOT NULL DEFAULT 0,
    `tx_guid` VARCHAR(80) NOT NULL DEFAULT '',
    `contact_date` DATETIME NOT NULL DEFAULT '1900-01-01', -- fill this after contact made?
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`contact_status_id`) REFERENCES contact_status (`id`),
    FOREIGN KEY (`contact_method_id`) REFERENCES contact_methods (`id`),
    FOREIGN KEY (`data_packet_id`) REFERENCES data_packet (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;