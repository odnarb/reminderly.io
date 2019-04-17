-- 1 - sms,2 - email, 3 - phone
CREATE TABLE `contact_method` (
    `id` INT AUTO_INCREMENT,
    `contact_method` VARCHAR(80) NOT NULL,
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;

-- 0 - not sent,1 - in queue,2 - sent, 3 - error
CREATE TABLE `contact_status` (
    `id` INT AUTO_INCREMENT,
    `contact_status` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;

-- messages table
CREATE TABLE `messages` (
    `id` INT AUTO_INCREMENT,
    `tx_guid` VARCHAR(255) NOT NULL DEFAULT '',
    `customer_id` INT NOT NULL,
    `contact_method` INT NOT NULL,
    `contact_status` INT NOT NULL,
    `message_body` json NOT NULL,
    `contact_date` DATETIME NOT NULL DEFAULT NOW(),
    `priority` INT NOT NULL,
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    FOREIGN KEY (`contact_method`) REFERENCES contact_method (`id`),
    FOREIGN KEY (`contact_status`) REFERENCES contact_status (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;

DROP PROCEDURE IF EXISTS GetMessagesReady;

DELIMITER //
CREATE PROCEDURE GetMessagesReady(IN v_contact_method VARCHAR(80))
BEGIN

    -- get a guid for this group
    SET @new_tx_guid=UUID();

    CREATE TEMPORARY TABLE tmp_msgs(
        `id` INT NOT NULL AUTO_INCREMENT,
        `contact_method` INT NOT NULL,
        `contact_status` INT NOT NULL,
        `message_body` json NOT NULL,
        PRIMARY KEY (`id`), KEY(`id`)
    )  ENGINE=INNODB SELECT
            msgs.id,
            msgs.contact_method,
            msgs.contact_status,
            msgs.message_body
        FROM
            messages msgs
        INNER JOIN contact_method cm ON msgs.contact_method = cm.id
        INNER JOIN contact_status cs ON msgs.contact_status = cs.id
        WHERE
            cm.contact_method = v_contact_method
            AND cs.contact_status = 'not sent'
            AND tx_guid = ''
        ORDER BY contact_date DESC
        LIMIT 1000;

    -- update each msg to contain a tx guid
    -- TODO: use inner join on contact status
    UPDATE messages
    SET
        tx_guid = @new_tx_guid,
        contact_status = 2
    WHERE id IN (SELECT id FROM tmp_msgs);

    -- SELECT @new_tx_guid;
    -- SELECT id FROM tmp_msgs;
    -- SELECT * from messages WHERE id IN (SELECT id FROM tmp_msgs);
    SELECT *,@new_tx_guid AS tx_guid FROM tmp_msgs;

    DROP TEMPORARY TABLE tmp_msgs;
 END //
DELIMITER ;


DROP PROCEDURE IF EXISTS SetMessagesProcessed;

DELIMITER //
CREATE PROCEDURE SetMessagesProcessed(IN p_tx_guid VARCHAR(80))
BEGIN

    -- SET @group_tx_guid='7566e977-5e23-11e9-9f1d-000c2988b5a1';

    UPDATE `messages` m
    INNER JOIN `contact_status` cs
    ON m.contact_status = cs.id
    SET m.contact_status = 3
    WHERE
        cs.contact_status = 'queue'
        and m.tx_guid = p_tx_guid;


 END //
DELIMITER ;


------------------------------------------------ 

/*
shards
    id
    state
    zip

customer_shard
    rule, not a table.. based on customer state and zip (if zip is available)
    --need a zip code - to region lookup or algo

##redundant? does company_load_map remove this requirement?
customer_xref
    customer_id
    external_customer_id
    updated_at
    created_at
*/

-- company table
CREATE TABLE `company` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `alias` VARCHAR(255) NOT NULL DEFAULT '',
    `details` json NOT NULL,
    `active` INT NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- groups table
CREATE TABLE `groups` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `alias` VARCHAR(255) NOT NULL DEFAULT '',
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- so companies can be part of a group, set one as master
-- company_group table
CREATE TABLE `company_group` (
    `id` INT AUTO_INCREMENT,
    `group_id` INT NOT NULL,
    `company_id` INT NOT NULL,
    `master` INT NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`group_id`) REFERENCES groups (`id`),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- customer table
CREATE TABLE `customer` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `company_id` INT NOT NULL,
    `details` json NOT NULL,
    `active` INT NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- company_apps table
CREATE TABLE `company_apps` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `restrict_to_customer_id` INT NOT NULL DEFAULT 0,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
--    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- company_apps_restriction table
CREATE TABLE `company_apps_restriction` (
    `id` INT AUTO_INCREMENT,
    `company_apps_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_apps_id`) REFERENCES company_apps (`id`),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- company_api table
CREATE TABLE `company_api` (
    `id` INT AUTO_INCREMENT,
    `company_apps_id` INT NOT NULL,
    `api_id` VARCHAR(255) NOT NULL DEFAULT UUID(),
    `api_key` VARCHAR(255) NOT NULL DEFAULT UUID(),
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_apps_id`) REFERENCES company_apps (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT,
    `first_name` VARCHAR(255) NOT NULL DEFAULT '',
    `last_name` VARCHAR(255) NOT NULL DEFAULT '',
    `email_address` VARCHAR(255) NOT NULL DEFAULT '',
    `phone_number` VARCHAR(50) NOT NULL DEFAULT '',
    `locked` INT NOT NULL,
    `login_attempts` INT NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- users_passwords table
CREATE TABLE `users_passwords` (
    `id` INT AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- these need to be fleshed out, primarily for the UI of the system
-- role table
CREATE TABLE `role` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`users_passwords_id`) REFERENCES users_passwords (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- policy table
CREATE TABLE `policy` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `module` VARCHAR(255) NOT NULL DEFAULT '',
    `function` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- roles_policies table
CREATE TABLE `roles_policies` (
    `id` INT AUTO_INCREMENT,
    `role_id` INT NOT NULL,
    `policy_id` INT NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`role_id`) REFERENCES role (`id`),
    FOREIGN KEY (`policy_id`) REFERENCES policy (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- user_role table
CREATE TABLE `user_role` (
    `id` INT AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `role_id` INT NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`user_id`) REFERENCES user (`id`),
    FOREIGN KEY (`role_id`) REFERENCES role (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- company_location table
CREATE TABLE `company_location` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `address_1` VARCHAR(80) NOT NULL DEFAULT '',
    `address_2` VARCHAR(80) NOT NULL DEFAULT '',
    `city` VARCHAR(80) NOT NULL DEFAULT '',
    `state` VARCHAR(80) NOT NULL DEFAULT '',
    `zip` VARCHAR(20) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- consider: what to do with additional data? overwrite / flush / append?
-- data_ingest_source table
CREATE TABLE `data_ingest_source` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(80) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- data_ingest_stage table
CREATE TABLE `data_ingest_stage` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(80) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- track the number of times we tried to load this file
-- data_packet table
CREATE TABLE `data_packet` (
    `id` INT AUTO_INCREMENT,
    `data_ingest_source_id` INT NOT NULL,
    `data_ingest_stage_id` INT NOT NULL,
    `company_id` INT NOT NULL,
    `tx_guid` VARCHAR(80) NOT NULL DEFAULT UUID(),
    `num_tries` INT NOT NULL,
    `metadata` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_ingest_source_id`) REFERENCES data_ingest_source (`id`),
    FOREIGN KEY (`data_ingest_stage_id`) REFERENCES data_ingest_stage (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- company_load_map table
CREATE TABLE `company_load_map` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `load_name` VARCHAR(80) NOT NULL DEFAULT '',
    `system_name` VARCHAR(80) NOT NULL DEFAULT '',
    `system_version` VARCHAR(80) NOT NULL DEFAULT '',
    `load_map` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- contact_blocks table
CREATE TABLE `contact_blocks` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `criteria` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- message_functions table
CREATE TABLE `message_functions` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


--  (HealthCare, School, Utilities, Commercial, etc)
-- template_types table
CREATE TABLE `template_types` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- template types just help one identify what it's useful for
-- global_templates table
CREATE TABLE `global_templates` (
    `id` INT AUTO_INCREMENT,
    `template_type_id` VARCHAR(80) NOT NULL DEFAULT '',
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `message` json NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`template_type_id`) REFERENCES template_types (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- company_templates table
CREATE TABLE `company_templates` (
    `id` INT AUTO_INCREMENT,
    `template_type_id` VARCHAR(80) NOT NULL DEFAULT '',
    `customer_id` INT NOT NULL,
    `company_id` INT NOT NULL,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `message` json NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`template_type_id`) REFERENCES template_types (`id`),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- message table
CREATE TABLE `messages` (
    `id` INT AUTO_INCREMENT,
    `data_packet_id` NOT NULL,
    `company_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `contact_method_id` INT NOT NULL,
    `contact_status_id` INT NOT NULL, -- {message sent, contacted, failed, etc}
    `processed_id` INT NOT NULL, -- (various flags/states of contacting in system queueing)
    `data` json NOT NULL DEFAULT '',
    `contact_date` DATETIME NOT NULL DEFAULT '',
    `contact_status_description` VARCHAR(255) NOT NULL DEFAULT '', -- {why it failed, etc}
    `raw_response` VARCHAR(80) NOT NULL DEFAULT '', -- [DTMF, character, word, raw data] -- we don't campture anything but phone calls
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_packet_id`) REFERENCES data_packet (`id`),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    FOREIGN KEY (`contact_method_id`) REFERENCES contact_method (`id`),
    FOREIGN KEY (`contact_status_id`) REFERENCES contact_status (`id`),
    FOREIGN KEY (`processed_id`) REFERENCES processed (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- this is just an example of history tables and how we'd use them
-- deletes suck
-- drops are quick.. once this table expires... drop it.
-- messages_history_4_1_2019 table
CREATE TABLE `messages_history_4_1_2019` (
    `id` INT AUTO_INCREMENT,
    `message_id` INT NOT NULL,
    `data_packet_id` NOT NULL,
    `company_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `contact_method_id` INT NOT NULL,
    `contact_status_id` INT NOT NULL, -- {message sent, contacted, failed, etc}
    `processed_id` INT NOT NULL, -- (various flags/states of contacting in system queueing)
    `data` json NOT NULL DEFAULT '',
    `contact_date` DATETIME NOT NULL DEFAULT '',
    `contact_status_description` VARCHAR(255) NOT NULL DEFAULT '', -- {why it failed, etc}
    `raw_response` VARCHAR(80) NOT NULL DEFAULT '', -- [DTMF, character, word, raw data] -- we don't campture anything but phone calls
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_packet_id`) REFERENCES data_packet (`id`),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    FOREIGN KEY (`contact_method_id`) REFERENCES contact_method (`id`),
    FOREIGN KEY (`contact_status_id`) REFERENCES contact_status (`id`),
    FOREIGN KEY (`processed_id`) REFERENCES processed (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- messages_history_5_1_2019 table
CREATE TABLE `messages_history_5_1_2019` (
    `id` INT AUTO_INCREMENT,
    `message_id` INT NOT NULL,
    `data_packet_id` NOT NULL,
    `company_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `contact_method_id` INT NOT NULL,
    `contact_status_id` INT NOT NULL, -- {message sent, contacted, failed, etc}
    `processed_id` INT NOT NULL, -- (various flags/states of contacting in system queueing)
    `data` json NOT NULL DEFAULT '',
    `contact_date` DATETIME NOT NULL DEFAULT '',
    `contact_status_description` VARCHAR(255) NOT NULL DEFAULT '', -- {why it failed, etc}
    `raw_response` VARCHAR(80) NOT NULL DEFAULT '', -- [DTMF, character, word, raw data] -- we don't campture anything but phone calls
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_packet_id`) REFERENCES data_packet (`id`),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    FOREIGN KEY (`contact_method_id`) REFERENCES contact_method (`id`),
    FOREIGN KEY (`contact_status_id`) REFERENCES contact_status (`id`),
    FOREIGN KEY (`processed_id`) REFERENCES processed (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- sms_queue table
CREATE TABLE `sms_queue` (
    `id` INT AUTO_INCREMENT,
    `message_id` INT NOT NULL,
    `to_phone` VARCHAR(20) NOT NULL DEFAULT '',
    `from_phone` VARCHAR(20) NOT NULL DEFAULT '',
    `data` json NOT NULL DEFAULT '',
    `contact_date` DATETIME NOT NULL DEFAULT '',
    `priority` INT NOT NULL DEFAULT 0,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`message_id`) REFERENCES messages (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- phone_queue table
CREATE TABLE `phone_queue` (
    `id` INT AUTO_INCREMENT,
    `message_id` INT NOT NULL,
    `to_phone` VARCHAR(20) NOT NULL DEFAULT '',
    `from_phone` VARCHAR(20) NOT NULL DEFAULT '',
    `data` json NOT NULL DEFAULT '',
    `contact_date` DATETIME NOT NULL DEFAULT '',
    `priority` INT NOT NULL DEFAULT 0,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`message_id`) REFERENCES messages (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- email_queue table
CREATE TABLE `email_queue` (
    `id` INT AUTO_INCREMENT,
    `message_id` INT NOT NULL,
    `to_email` VARCHAR(255) NOT NULL DEFAULT '',
    `from_email` VARCHAR(255) NOT NULL DEFAULT '',
    `reply_to` VARCHAR(255) NOT NULL DEFAULT '',
    `data` json NOT NULL DEFAULT '',
    `contact_date` DATETIME NOT NULL DEFAULT '',
    `priority` INT NOT NULL DEFAULT 0,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`message_id`) REFERENCES messages (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- products table
CREATE TABLE `products` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `descripton` VARCHAR(255) NOT NULL DEFAULT '',
    `credits_package_amt` INT NOT NULL,
    `price` INT NOT NULL,
    `price_per_credit` INT NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- all strings must have an english counterpart if there is a translation
-- i18n_string table
CREATE TABLE `i18n_string` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `string_en` VARCHAR(255) NOT NULL DEFAULT '',
    `string_translation` VARCHAR(255) NOT NULL DEFAULT '',
    `country_code` VARCHAR(2) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;