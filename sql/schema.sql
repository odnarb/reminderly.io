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
-- DONE - need logging tables
-- - need log offloader script
    -- log tables can be dumped out after x days to a .sql file, and then rotate the table
    -- simply use the mysqldump command for relevant tables
-- TODO: figure role company restriction (or allow list) via role table
-- proc moves data to history
    --removes entries from log tables

-- table of processed flags
-- table of contact methods
-- table of contact status / description
-- figure out a shard method
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

/*
- use MyIsam for logging or tables that might deadlock
- use table rotating for logs
- use gearman for caching inserts https://lornajane.net/posts/2011/using-persistent-storage-with-gearman

http://brian.moonspot.net/logging-with-mysql

create table messages_new like messages;
rename table messages to messages_history_2019041600001, messages_new to messages;


can query the system for tables that are messages_history_*: show tables like 'messages_history_%'

messages_history_2019041600001
messages_history_2019051600001
messages_history_2019061600001
etc

then union them for a complete poll of history
*/

/*
other features to be built out
-----------------
survey -- who responded the most, and who's most likely to respond to a survey
url shortener
auto reminders / cancellations
messae options - leave a different message on answering machine vs human

*/

/*
data ingest / file ingest
sources
-------------
    UI -> Excel-to-csv (self-inspection, mapping fields) ?
    excel-to-csv-to-s3
    UI -> CSV upload
    HTTPS->CSV->DB import
    csv-to-s3
    API
        api-to-s3
    Direct SQL
        push or pull
    Google Assistant?
    Google Calendar?
*/

/*
global_confirmation_templates
    #this is for confirmations and whatnot
    -- content for after clicking "confirm"/"cancel"/"reschedule"

data cleaning
    apply company rules based on field mapping
    filter duplicates

outbound rules
    auto responses
    days offset
*/

/*
-- wth is this?
flags
    id
    flag
    description
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


-- log_company table
CREATE TABLE `log_company` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
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

-- log_groups table
CREATE TABLE `log_groups` (
    `id` INT AUTO_INCREMENT,
    `group_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`group_id`) REFERENCES groups (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;

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


-- log_company_group table
CREATE TABLE `log_company_group` (
    `id` INT AUTO_INCREMENT,
    `company_group_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_group_id`) REFERENCES company_group (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_customer table
CREATE TABLE `log_customer` (
    `id` INT AUTO_INCREMENT,
    `customer_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_company_apps table
CREATE TABLE `log_company_apps` (
    `id` INT AUTO_INCREMENT,
    `company_apps_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_apps_id`) REFERENCES company_apps (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_company_apps_restriction table
CREATE TABLE `log_company_apps_restriction` (
    `id` INT AUTO_INCREMENT,
    `company_apps_restriction_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_apps_restriction_id`) REFERENCES company_apps_restriction (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_company_api table
CREATE TABLE `log_company_api` (
    `id` INT AUTO_INCREMENT,
    `company_api_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_api_id`) REFERENCES company_api (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- what if a user deletes themselves??? (foreign key issue?)
-- log_users table
CREATE TABLE `log_users` (
    `id` INT AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_users_passwords table
CREATE TABLE `log_users_passwords` (
    `id` INT AUTO_INCREMENT,
    `users_passwords_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`users_passwords_id`) REFERENCES users_passwords (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_role table
CREATE TABLE `log_role` (
    `id` INT AUTO_INCREMENT,
    `role_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`role_id`) REFERENCES role (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_policy table
CREATE TABLE `log_policy` (
    `id` INT AUTO_INCREMENT,
    `policy_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`policy_id`) REFERENCES policy (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_roles_policies table
CREATE TABLE `log_roles_policies` (
    `id` INT AUTO_INCREMENT,
    `roles_policies_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`roles_policies_id`) REFERENCES roles_policies (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;



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


-- log_user_role table
CREATE TABLE `log_user_role` (
    `id` INT AUTO_INCREMENT,
    `user_role_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`user_role_id`) REFERENCES roles_policies (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_company_location table
CREATE TABLE `log_company_location` (
    `id` INT AUTO_INCREMENT,
    `company_location_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_location_id`) REFERENCES company_location (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_data_ingest_source table
CREATE TABLE `log_data_ingest_source` (
    `id` INT AUTO_INCREMENT,
    `data_ingest_source_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_ingest_source_id`) REFERENCES data_ingest_source (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- data_ingest_stage table
CREATE TABLE `data_ingest_stage` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(80) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- log_data_ingest_stage table
CREATE TABLE `log_data_ingest_stage` (
    `id` INT AUTO_INCREMENT,
    `data_ingest_stage_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_ingest_stage_id`) REFERENCES data_ingest_stage (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;

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


-- this would be a more visible on the platform than other log tables?
-- log the stages a packet is in

-- log_data_ingest_stage table
CREATE TABLE `log_data_packet` (
    `id` INT AUTO_INCREMENT,
    `data_packet_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_packet_id`) REFERENCES data_packet (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- allow client/cust support to reset stage?

-- is this necessary if we're using json for the data field?
    -- this resolves the remote company data fields to fields mapped into the system
    -- this also allows companies to have several load maps to be active
        -- then each import (or data feed, or file) needs to reference a company_load_map.id
    -- this can also remove the requirement of having a "customer_xref" table..?

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


-- log_company_load_map table
CREATE TABLE `log_company_load_map` (
    `id` INT AUTO_INCREMENT,
    `company_load_map_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_load_map_id`) REFERENCES company_load_map (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_contact_blocks table
CREATE TABLE `log_contact_blocks` (
    `id` INT AUTO_INCREMENT,
    `contact_blocks_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`contact_blocks_id`) REFERENCES contact_blocks (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


messaging
------------------

-- message functions are crude pointers to a mysql function.. ? (date, time, provider name)
-- as well as data (depends on the load map)
/*
- the '{}' brackets mark the beginning of template mode.. or template language
- available template methods are:
    {data.[property]}
    {data.appointment_date|date|MM-DD-YYYY HH:MM:ss}
-You have an appointment on {data.appointment_date|date|MM-DD-YYYY HH:MM:ss} with {data.provider|name}
- {data.first_name|name} - capitalize the first letter, this is a proper name
- {data.last_name|name} - capitalize the first letter, this is a proper name
- {data.location|name} - capitalize the first letter, this is a proper name
- {company.name|name}
- {company.phone_number}
*/


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



-- consider the limitation of the json column here..
    -- maybe not a big deal
-- max size is server's max-allowed-packet size. defauly is 64MB

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


-- log_message table
CREATE TABLE `log_messages` (
    `id` INT AUTO_INCREMENT,
    `message_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`message_id`) REFERENCES messages (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
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


-- log_sms_queue table
CREATE TABLE `log_sms_queue` (
    `id` INT AUTO_INCREMENT,
    `sms_queue_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`sms_queue_id`) REFERENCES sms_queue (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_phone_queue table
CREATE TABLE `log_phone_queue` (
    `id` INT AUTO_INCREMENT,
    `phone_queue_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`phone_queue_id`) REFERENCES phone_queue (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_phone_queue table
CREATE TABLE `log_email_queue` (
    `id` INT AUTO_INCREMENT,
    `email_queue_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`email_queue_id`) REFERENCES email_queue (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_products table
CREATE TABLE `log_products` (
    `id` INT AUTO_INCREMENT,
    `product_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`product_id`) REFERENCES products (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


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


-- log_i18n_strings table
CREATE TABLE `log_i18n_strings` (
    `id` INT AUTO_INCREMENT,
    `i18n_string_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`i18n_string_id`) REFERENCES i18n_string (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;