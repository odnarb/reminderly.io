-- this would be a more visible on the platform than other log tables?
-- log the stages a packet is in
-- log_data_packet table
CREATE TABLE `log_data_packet` (
    `id` INT AUTO_INCREMENT,
    `data_packet_id` INT NOT NULL,
    -- `user_id` INT NOT NULL,
    `log` VARCHAR(1000),
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_packet_id`) REFERENCES data_packet (`id`),
    -- FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;