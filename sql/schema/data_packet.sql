/*
!!! For now, this is rendundant..we'll offload the important cols (server and table name) to the data_packet table

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
*/

/*
 consider: what to do with additional data? overwrite / flush / append?
 track the number of times we tried to load this file
 maybe even md5sum the file to make part of table name?
 track the table name
*/
CREATE TABLE `data_packet` (
    `id` INT AUTO_INCREMENT,
    `campaign_id` INT NOT NULL,
    `data_ingest_source_id` INT NOT NULL,
    `data_ingest_stage_id` INT NOT NULL,
    -- `packet_table_tracking_id` INT NOT NULL,
    `server_name` VARCHAR(255) NOT NULL DEFAULT '',
    `table_name` VARCHAR(255) NOT NULL DEFAULT '',
    `tx_guid` VARCHAR(80) NOT NULL DEFAULT '',
    `version` INT NOT NULL DEFAULT 1,
    `num_tries` INT NOT NULL DEFAULT 0,
    `metadata` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`campaign_id`) REFERENCES customer_campaigns (`id`),
    FOREIGN KEY (`data_ingest_source_id`) REFERENCES data_ingest_source (`id`),
    FOREIGN KEY (`data_ingest_stage_id`) REFERENCES data_ingest_stage (`id`),
    -- FOREIGN KEY (`packet_table_tracking_id`) REFERENCES packet_table_tracking (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


/*
This is merely an example of the packet data table..

CREATE TABLE `packet_1337_07022020_1_data` (
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
*/