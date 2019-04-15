-- 0 - not sent,1 - in queue,2 - sent, 3 - error
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
-- TODO: figure role company restriction (or allow list) via role table
-- need to track changes in db
-- need logging tables
-- need log offloaders

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
other features to be built out
-----------------
survey -- who responded the most, and who's most likely to respond to a survey
url shortener
auto reminders / cancellations

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
)  ENGINE=INNODB;


-- data_packet table
CREATE TABLE `data_packet` (
    `id` INT AUTO_INCREMENT,
    `data_ingest_source_id` INT NOT NULL,
    `data_ingest_stage_id` INT NOT NULL,
    `company_id` INT NOT NULL,
    `metadata` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_ingest_source_id`) REFERENCES data_ingest_source (`id`),
    FOREIGN KEY (`data_ingest_stage_id`) REFERENCES data_ingest_stage (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;


-- this would be a more visible on the platform than other log tables?
-- log the stages a packet  is in

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
)  ENGINE=INNODB;


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
)  ENGINE=INNODB;

/*
field mapping
-------------------
template
    per-company or per-customer defined
        --if commercial or schools, no need for "customer",
            or can use big school districts and delegate to Principals at each school
    field cleaning / validation
    messaging setup
        sms
            templates
        phone
            snippets, templates
        email
            spoof address (tier-1 clients ONLY)
            html email templates (tier-2 clients and above)
*/

-- they choose what to match on
    --needs to be at least first name, last name, phone|email

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
)  ENGINE=INNODB;


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
- {data.first_name} - capitalize the first letter, this is a proper name
- {data.last_name} - capitalize the first letter, this is a proper name
- {data.location} - capitalize the first letter, this is a proper name
- {company.name}
- {company.phone_number}
*/

message_functions
    id
    name
    created_at
    updated_at


global_phone_templates
    template_id
    name
    type (HealthCare, School, Utilities, Commercial, etc)
    message  (JSON)
        message contains a JSON structure or array with message snippet details
        will be tts and can contain message tags and functions
    updated_at
    created_at


phone_templates
    template_id
    customer_id
    company_id
    name
    message  (JSON)
        message contains a JSON structure or array with message snippet details
    updated_at
    created_at


global_sms_templates
    template_id
    name
    message
        message is a string with message tags and functions
    updated_at
    created_at


sms_templates
    template_id
    customer_id
    company_id
    name
    message
        message is a string with message tags and functions
    updated_at
    created_at


global_email_templates (these are templates designed by us and customers have access to)
    template_id
    html_email
    raw_text
    updated_at
    created_at


email_templates
    template_id
    customer_id
    company_id
    html_email
    raw_text
    updated_at
    created_at


global_confirmation_templates
    #this is for 

-- wth is this?
flags
    id
    flag
    description


data cleaning
    apply company rules based on field mapping
    filter duplicates

outbound rules
    auto responses
    days offset


-- consider the limitation of the json column here..
    -- maybe not a big deal
-- max size is server's max-allowed-packet size. defauly is 64MB
message
    id
    company_id
    customer_id
    data (JSON)
        -- { first_name, last_name, middle_name, phone_number, email_address, appointment_date, patient_id, customer, customer_id, etc... }
    contact_method [phone, email, sms]
    contact_date (UTC time)
    processed (various flags/states of contacting in system queueing)
    contact_status {message sent, contacted, failed, etc}
    contact_status_description {why it failed, etc}
    raw_response [DTMF, character, word, raw data]
    created_at
    updated_at


log_message
    id
    message_id
    user_id
    details JSON
    updated_at
    created_at


messages_history
    same fields as contact_records

messages_history_history ?
    same fields as contact_records


--proc moves data to history
    --removes entries from log tables

sms_queue (transient)
    message_id
    to_phone
    from_phone
    message_data
    contact_date
    priority
    created_at
    updated_at


phone_queue (transient)
    message_id
    to_phone
    from_phone
    message_data
    contact_date
    priority
    created_at
    updated_at


email_queue (transient)
    message_id
    to_email
    from_email
    reply_to
    message_data (includes HTML and text-only as a backup)
    contact_date
    priority
    created_at
    updated_at


message_updates (sms sent, bounces, complaints, rejects, etc)
    id
    message_id
    contact_method
    status JSON
    created_at
    updated_at


message_updates_history
    id
    message_id
    contact_method
    status JSON
    created_at
    updated_at


-- different tiers?
credit_prices
    id
    credits_package -- 5000, 20000, 50000
    price_per_credit -- .10, .08, .06
    created_at
    updated_at


log_price
    id
    company_id
    created_at
    updated_at


-- all strings must have an english counterpart
i18n_string
    id
    company_id
    string_en
    string_translation
    country_code
    created_at
    updated_at


log_i18n_strings
    id
    i18n_string_id
    user_id
    details JSON
    updated_at
    created_at


-- 
-- 
-- NOW BEGIN DATA ENTRY
-- 
INSERT INTO `contact_status` (`contact_status`) VALUES
('not sent'),
('queue'),
('sent'),
('error');

INSERT INTO `contact_method` (`contact_method`) VALUES
('phone'),
('sms'),
('email'),
('general');

INSERT INTO `customer` (`name`) VALUES
('test customer 1'),
('test customer 2'),
('test customer 3'),
('test customer 4');

INSERT INTO `messages`
(`customer_id`,`contact_method`,`contact_status`,`message_body`,`contact_date`,`priority`)
VALUES
-- customer 1
(1,1,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 1. Thank you!" }',now(),0),
(1,1,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 2. Thank you!" }',now(),0),
(1,1,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 3. Thank you!" }',now(),0),
(2,1,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 1. Thank you!" }',now(),0),
(2,1,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 2. Thank you!" }',now(),0),
(2,1,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 3. Thank you!" }',now(),0),
(3,1,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 1","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 1","html_body":"<html><body><h1>This is an HTML test 1</h1></body></html>"}',now(),0),
(3,1,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 2","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 2","html_body":"<html><body><h1>This is an HTML test 2</h1></body></html>"}',now(),0),
(3,1,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 3","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 3","html_body":"<html><body><h1>This is an HTML test 3</h1></body></html>"}',now(),0),

-- customer 2
(1,2,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 4. Thank you!" }',now(),0),
(1,2,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 5. Thank you!" }',now(),0),
(1,2,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 6. Thank you!" }',now(),0),
(2,2,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 1. Thank you!" }',now(),0),
(2,2,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 2. Thank you!" }',now(),0),
(2,2,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 3. Thank you!" }',now(),0),
(3,2,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 1","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 1","html_body":"<html><body><h1>This is an HTML test 1</h1></body></html>"}',now(),0),
(3,2,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 2","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 2","html_body":"<html><body><h1>This is an HTML test 2</h1></body></html>"}',now(),0),
(3,2,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 3","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 3","html_body":"<html><body><h1>This is an HTML test 3</h1></body></html>"}',now(),0),

-- customer 3
(1,3,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 7. Thank you!" }',now(),0),
(1,3,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 8. Thank you!" }',now(),0),
(1,3,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 9. Thank you!" }',now(),0),
(2,3,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 1. Thank you!" }',now(),0),
(2,3,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 2. Thank you!" }',now(),0),
(2,3,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 3. Thank you!" }',now(),0),
(3,3,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 1","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 1","html_body":"<html><body><h1>This is an HTML test 1</h1></body></html>"}',now(),0),
(3,3,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 2","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 2","html_body":"<html><body><h1>This is an HTML test 2</h1></body></html>"}',now(),0),
(3,3,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 3","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 3","html_body":"<html><body><h1>This is an HTML test 3</h1></body></html>"}',now(),0),

-- customer 4
(1,4,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 10. Thank you!" }',now(),0),
(1,4,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 11. Thank you!" }',now(),0),
(1,4,1,'{ "to": "(530) 908-2640", "body": "This is a test phone call 12. Thank you!" }',now(),0),
(2,4,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 1. Thank you!" }',now(),0),
(2,4,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 2. Thank you!" }',now(),0),
(2,4,1,'{ "to": "(530) 908-2640", "body": "This is a test sms 3. Thank you!" }',now(),0),
(3,4,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 1","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 1","html_body":"<html><body><h1>This is an HTML test 1</h1></body></html>"}',now(),0),
(3,4,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 2","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 2","html_body":"<html><body><h1>This is an HTML test 2</h1></body></html>"}',now(),0),
(3,4,1,'{"email_address":"bran.cham@gmail.com","subject":"El Rio - Appointment Reminder 3","from":"notifications@reminderly.io","reply_to":"notifications@reminderly.io","text_body":"This is a test 3","html_body":"<html><body><h1>This is an HTML test 3</h1></body></html>"}',now(),0);
