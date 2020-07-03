SET FOREIGN_KEY_CHECKS=0; -- to disable them

DROP TABLE IF EXISTS `company`;
DROP TABLE IF EXISTS `company_location`;
DROP TABLE IF EXISTS `customer`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `users_passwords`;
DROP TABLE IF EXISTS `roles`;
DROP TABLE IF EXISTS `policies`;
DROP TABLE IF EXISTS `roles_policies`;
DROP TABLE IF EXISTS `users_roles`;
DROP TABLE IF EXISTS `company_campaigns`;
DROP TABLE IF EXISTS `contact_methods`;
DROP TABLE IF EXISTS `contact_status`;
DROP TABLE IF EXISTS `contact_method_providers`;
DROP TABLE IF EXISTS `data_ingest_source`;
DROP TABLE IF EXISTS `data_ingest_stage`;
DROP TABLE IF EXISTS `data_packet`;
DROP TABLE IF EXISTS `packet_1337_07022020_1_data`;
DROP TABLE IF EXISTS `packet_table_tracking`;
DROP TABLE IF EXISTS `message_functions`;
DROP TABLE IF EXISTS `sms_unsubscribe`;

SET FOREIGN_KEY_CHECKS=1; -- to re-enable them

-- company table
/*
    For now the company locations are included in the details
*/
CREATE TABLE `company` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `alias` VARCHAR(255) NOT NULL DEFAULT '',
    `details` json NOT NULL,
    `active` INT NOT NULL DEFAULT 0,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


/*
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
*/

/*
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
*/

-- users table
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT,
    `first_name` VARCHAR(255) NOT NULL DEFAULT '',
    `last_name` VARCHAR(255) NOT NULL DEFAULT '',
    `email_address` VARCHAR(255) NOT NULL DEFAULT '',
    `phone_number` VARCHAR(50) NOT NULL DEFAULT '',
    `enabled` INT NOT NULL DEFAULT 0,
    `locked` INT NOT NULL DEFAULT 0,
    `login_attempts` INT NOT NULL DEFAULT 0,
    `password_hash` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;

/*
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
*/

-- these need to be fleshed out, primarily for the UI of the system
-- roles table
/*
CREATE TABLE `roles` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- policies table
CREATE TABLE `policies` (
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
    FOREIGN KEY (`role_id`) REFERENCES roles (`id`),
    FOREIGN KEY (`policy_id`) REFERENCES policies (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- users_roles table
CREATE TABLE `users_roles` (
    `id` INT AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `company_id` INT NOT NULL,
    `role_id` INT NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    FOREIGN KEY (`role_id`) REFERENCES roles (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;
*/

-- company_campaigns table
-- a campaign should have at least one data source.. (MVP just one)
-- a campaign each data source has a mapping
-- a campaign should have contact methods
-- a campaign should have messages defined
-- a campaign should have a schedule of contact windows.. or now..
-- a campaign should define if confirm, cancel, reschedule options available
/*
For certain contact types we will need a bare minimum of fields defined and mapped:
    sms: to, message body
    email: to, subject line, message body
    phone: to, message body

    * if the message template pulls from a field that's not available in the map, then we'll throw an error
*/
CREATE TABLE `company_campaigns` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `data` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- 1 - sms,2 - email, 3 - phone
-- contact_methods table
CREATE TABLE `contact_methods` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL,
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- this is for the status of the message in the system, before it goes out
-- 0 - not sent,1 - in queue,2 - sent, 3 - error
-- contact_status table
CREATE TABLE `contact_status` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL,
    `contact_status` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


/*
-- hard-coded table for our current contact method providers

*/
-- contact_method_providers table
CREATE TABLE `contact_method_providers` (
    `id` INT AUTO_INCREMENT,
    `contact_method_id` INT NOT NULL,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `url` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`contact_method_id`) REFERENCES contact_methods (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- 1 - API, 2 - UI
-- data_ingest_source table
CREATE TABLE `data_ingest_source` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(160) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


/*
1-ingested - file is recorded to be "in the system", but data not loaded yet
2-loaded - rows have been loaded into the system, no transformations made
3-mapped - rows have been tagged with appropriate metadata, or transformed
    -- message functions applied and built out
4-queued / contacting - rows have been copied into appropriate contact queue tables
    -- last chance to cancel contacts
5-complete
*/
-- data_ingest_stage table
CREATE TABLE `data_ingest_stage` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(80) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- this is for tracking the data packet tables we have in order to manage them, perform unions, etc
-- packet_table_tracking table
CREATE TABLE `packet_table_tracking` (
    `id` INT AUTO_INCREMENT,
    `server_name` VARCHAR(255) NOT NULL DEFAULT '',
    `table_name` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;

-- consider: what to do with additional data? overwrite / flush / append?
-- track the number of times we tried to load this file
-- data_packet table
-- track the table name
CREATE TABLE `data_packet` (
    `id` INT AUTO_INCREMENT,
    `campaign_id` INT NOT NULL,
    `data_ingest_source_id` INT NOT NULL,
    `data_ingest_stage_id` INT NOT NULL,
    `packet_table_tracking_id` INT NOT NULL,
    `company_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `tx_guid` VARCHAR(80) NOT NULL DEFAULT '',
    `version` INT NOT NULL DEFAULT 1,
    `num_tries` INT NOT NULL DEFAULT 0,
    `metadata` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`campaign_id`) REFERENCES company_campaigns (`id`),
    FOREIGN KEY (`data_ingest_source_id`) REFERENCES data_ingest_source (`id`),
    FOREIGN KEY (`data_ingest_stage_id`) REFERENCES data_ingest_stage (`id`),
    FOREIGN KEY (`packet_table_tracking_id`) REFERENCES packet_table_tracking (`id`),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- we split data packets by id -- and generate a new table per packet for tracking and reporting purposes..
-- raw row data, unfiltered and un manipulated
/*
    reports are generated on a per-table basis

    --might be useful to store the db shard or server that's hosting the campaign data
    -- or our middleware takes care of asking all the db servers where a table is located

    show tables like campaign_`${campaign_id}`_data
        if a row is returned we're safe to continue
    select * from campaign_`${campaign_id}`_data

    some basic validation here would be good for MVP.. even if it's just checking against the load map for the company
        -flag with error if our system detected an issue?
        -need a table of errors pertaining to campaign_id
*/

/*
CREATE TABLE `packet_[packet_id]_[date]_[version]_data` (
    `id` INT AUTO_INCREMENT,
    `data_packet_id` INT NOT NULL,
    `data` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_packet_id`) REFERENCES data_packet (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


packet data will need message fields like:
    `to_phone` VARCHAR(20) NOT NULL DEFAULT '',
    `from_phone` VARCHAR(20) NOT NULL DEFAULT '',
    `priority` INT NOT NULL DEFAULT 0,


*/

CREATE TABLE `packet_1337_07022020_1_data` (
    `id` INT AUTO_INCREMENT,
    `data_packet_id` INT NOT NULL,
    `packet_table_name` VARCHAR(255) NOT NULL DEFAULT '', -- contains table name like: "packet_1337_07022020_1_data"
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


-- message_functions table
-- when building a message, one can apply functions to a message such as:
--    {data.appointment_date|date|MM-DD-YYYY HH:MM A} - format date string
--    {data.first_name|name} - capitalize the first letter, this is a proper name
--    {data.last_name|name} - capitalize the first letter, this is a proper name
--    {data.phone_number|phone} - try to format into a phone number
CREATE TABLE `message_functions` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- sms_unsubscribe table
CREATE TABLE `sms_unsubscribe` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `phone_number` VARCHAR(20) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


/*
groups not slated for MVP

-- groups table
CREATE TABLE `groups` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `alias` VARCHAR(255) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
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
*/

/*
API not slated for MVP release

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
    `api_id` VARCHAR(255) NOT NULL DEFAULT '',
    `api_key` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_apps_id`) REFERENCES company_apps (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;
*/


/*
groups not slated for MVP

-- groups table
CREATE TABLE `ui_groups` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `alias` VARCHAR(255) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- roles_ui_groups table
CREATE TABLE `roles_ui_groups` (
    `id` INT AUTO_INCREMENT,
    `ui_groups_id` INT NOT NULL,
    `role_id` INT NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`ui_groups_id`) REFERENCES ui_groups (`id`),
    FOREIGN KEY (`role_id`) REFERENCES roles (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- users_ui_groups table
CREATE TABLE `users_ui_groups` (
    `id` INT AUTO_INCREMENT,
    `ui_groups_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`ui_groups_id`) REFERENCES ui_groups (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;
*/


/*
contact blocking not slated for MVP

-- contact_blocks table
----like a patient contact cancellation..? What about unsubscribe? maybe this is more for a temp block?
CREATE TABLE `contact_blocks` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `criteria` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;
*/

/*
email not slated for MVP

-- email_unsubscribe table
CREATE TABLE `email_unsubscribe` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `email` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;
*/


/*
phone not slated for MVP

-- phone_unsubscribe table
CREATE TABLE `phone_unsubscribe` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `phone_number` VARCHAR(20) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;
*/


/*

-- Don't even remember what this was meant for.. some subsystem for templated messages that companies can pull from?

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
    `template_type_id` INT NOT NULL,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `message` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`template_type_id`) REFERENCES template_types (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- company_templates table
CREATE TABLE `company_templates` (
    `id` INT AUTO_INCREMENT,
    `template_type_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `company_id` INT NOT NULL,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `message` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`template_type_id`) REFERENCES template_types (`id`),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;
*/


/*
phone not slated for MVP

-- phone_queue table
CREATE TABLE `phone_queue` (
    `id` INT AUTO_INCREMENT,
    `message_id` INT NOT NULL,
    `to_phone` VARCHAR(20) NOT NULL DEFAULT '',
    `from_phone` VARCHAR(20) NOT NULL DEFAULT '',
    `data` json NOT NULL,
    `contact_date` DATETIME NOT NULL,
    `priority` INT NOT NULL DEFAULT 0,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`message_id`) REFERENCES messages (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;
*/


/*
email not slated for MVP

-- email_queue table
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
*/

/*
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
*/

/*
internationalization not slated for MVP
--but we'll build support in for it -- piping all content through our own i18n function

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
*/
