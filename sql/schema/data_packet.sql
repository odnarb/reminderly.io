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
    `packet_table_tracking_id` INT NOT NULL,
    `tx_guid` VARCHAR(80) NOT NULL DEFAULT '',
    `version` INT NOT NULL DEFAULT 1,
    `num_tries` INT NOT NULL DEFAULT 0,
    `metadata` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`campaign_id`) REFERENCES customer_campaigns (`id`),
    FOREIGN KEY (`data_ingest_source_id`) REFERENCES data_ingest_source (`id`),
    FOREIGN KEY (`data_ingest_stage_id`) REFERENCES data_ingest_stage (`id`),
    FOREIGN KEY (`packet_table_tracking_id`) REFERENCES packet_table_tracking (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;
