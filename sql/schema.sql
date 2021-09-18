SET FOREIGN_KEY_CHECKS=0; -- to disable them

DROP TABLE IF EXISTS `data_ingest_source`;
DROP TABLE IF EXISTS `data_ingest_stage`;
DROP TABLE IF EXISTS `data_packet`;
DROP TABLE IF EXISTS `packet_1337_07022020_1_data`;
DROP TABLE IF EXISTS `packet_table_tracking`;
DROP TABLE IF EXISTS `message_functions`;
DROP TABLE IF EXISTS `sms_unsubscribe`;

-- these are app level tables... not even needed for now
-- DROP TABLE IF EXISTS `users`;
-- DROP TABLE IF EXISTS `users_passwords`;
-- DROP TABLE IF EXISTS `roles`;
-- DROP TABLE IF EXISTS `policies`;
-- DROP TABLE IF EXISTS `roles_policies`;
-- DROP TABLE IF EXISTS `users_roles`;


SET FOREIGN_KEY_CHECKS=1; -- to re-enable them


/*
    Need a proc for dropping old packet tables
    Maybe keep a summary of the meta data...?  (# of contacts, per contact type...etc)

*/

/*

    a campaign will need to have a filename for the bulk load step
        what the filename will be saved as via upload or SFTP: acme.csv, my-health-practice-3days-out.csv
        then we can have that

    we split data packets by id -- and generate a new table per packet for tracking and reporting purposes..
    raw row data, unfiltered and un manipulated

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
CREATE TABLE `packet_[packet_id]_[date]_[version]_raw` (
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

load for campaign_id = 1

-- how do we know what to name the table on import?
    -- We derive it programmatically
-- raw table of data
CREATE TABLE `packet_1337_07022020_1_raw` (
    `id` INT AUTO_INCREMENT,
    `data_packet_id` INT NOT NULL,
    `data` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_packet_id`) REFERENCES data_packet (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;

-- for when the data is mapped to proper fields
CREATE TABLE `packet_1337_07022020_1_mapped` (
    `id` INT AUTO_INCREMENT,
    `data_packet_id` INT NOT NULL,
    `packet_table_name` VARCHAR(255) NOT NULL DEFAULT '', -- contains table name like: "packet_1337_07022020_1_mapped"
    `data` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_packet_id`) REFERENCES data_packet (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;

CREATE TABLE `packet_1337_07022020_1_queued` (
    `id` INT AUTO_INCREMENT,
    `data_packet_id` INT NOT NULL,
    `packet_table_name` VARCHAR(255) NOT NULL DEFAULT '', -- contains table name like: "packet_1337_07022020_1_queued"
    `contact_status_id` INT NOT NULL, -- {message sent, contacted, failed, etc}
    `contact_method_id` INT NOT NULL, -- fill this after contact made?
    `priority` INT NOT NULL DEFAULT 0,
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


/*
App tables not slated for MVP release

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

CREATE TABLE `users_passwords` (
    `id` INT AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;

CREATE TABLE `roles` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;

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


API not slated for MVP release

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