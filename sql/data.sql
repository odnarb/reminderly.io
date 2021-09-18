/*
INSERT INTO `users` (
    `first_name`,
    `last_name`,
    `email_address`,
    `phone_number`,
    `enabled`,
    `password_hash`
) VALUES
('Brandon','Chambers', 'brandon@test.com', '(123) 123-1234',1,'12345'); -- no it's not a real pw hash.. chill out.
*/

INSERT INTO `company` (
    `name`,
    `alias`,
    `details`,
    `active`
) VALUES
('Test Company', 'TST-01', '{}', 1);

INSERT INTO `customer` (
    `name`,
    `company_id`,
    `details`,
    `active`
) VALUES
('Test Customer', 1, '{}', 1);

INSERT INTO `customer_location` (
    `customer_id`,
    `name`,
    `address_1`,
    `city`,
    `state`,
    `zip`
) VALUES
(1, 'Test Location', '123 Nowhere', 'Tucson', 'AZ','85737');

INSERT INTO `customer_campaigns` (
    `customer_id`,
    `name`,
    `description`,
    `data`
) VALUES
(1, 'Test Campaign', 'Test campaign for testing contacts', '{"timezone":"America/Phoenix"}');



-- 1 - API, 2 - UI
-- data_ingest_source table
INSERT INTO `data_ingest_source` (`name`,`description`) VALUES
('API','This source means the data packet came from the API'),
('UI','This source means the data packet came from someone uploading it via our web portal');

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
INSERT INTO `data_ingest_stage` (`name`,`description`) VALUES
('Ingested', 'The data packet sent to our system has been saved into our general area.'),
('Loaded', 'The data packet sent to our system has been loaded into the system.'),
('Mapped', 'The data packet sent to our system has been mapped according to your load map.'),
('Queued', 'The data packet sent to our system has been queued and is out for delivery.'),
('Complete', 'The data packet sent to our system has been completed.');


INSERT INTO `contact_status` (`name`,`contact_status`) VALUES
('not sent','The message has not been sent yet.'),
('polled','The message has been prepared for insert into the queue.'),
('queue','The message has been queued.'),
('sent','The message has been sent.'),
('error','There was an error with sending the message.');

INSERT INTO `contact_methods` (`name`) VALUES
('sms'),
('email'),
('phone');

/*
INSERT INTO `customer` (`name`) VALUES
('test customer 1'),
('test customer 2'),
('test customer 3'),
('test customer 4');
*/

-- history_table_tracking table
/*
INSERT INTO `packet_table_tracking` (`server_name`, `table_name`, `created_at`, `updated_at`) VALUES
('localhost','packet_1337_11082019_1_data', now(), now() ),
('localhost','packet_1337_11072019_1_data', date_add(now(), INTERVAL -3 DAY), date_add(now(), INTERVAL -3 DAY) ),
('localhost','packet_1337_11062019_1_data', date_add(now(), INTERVAL -10 DAY), date_add(now(), INTERVAL -10 DAY) ),
('localhost','packet_1337_11052019_1_data', date_add(now(), INTERVAL -20 DAY), date_add(now(), INTERVAL -20 DAY) ),
('localhost','packet_1337_11042019_1_data', date_add(now(), INTERVAL -30 DAY), date_add(now(), INTERVAL -30 DAY) ),
('localhost','packet_1337_11032019_1_data', date_add(now(), INTERVAL -89 DAY), date_add(now(), INTERVAL -89 DAY) ),
('localhost','packet_1337_11022019_1_data', date_add(now(), INTERVAL -90 DAY), date_add(now(), INTERVAL -90 DAY) ),
('localhost','packet_1337_07022020_1_data', date_add(now(), INTERVAL -91 DAY), date_add(now(), INTERVAL -91 DAY) );
*/

insert into data_packet
(
    campaign_id
    data_ingest_source_id,
    data_ingest_stage_id,
    server_name,
    table_name,
    version,
    num_tries,
    metadata,
    updated_at,
    created_at
) VALUES (
    1,
    1,
    1,
    'localhost',
    '',
    1,
    0,
    '{}'
);

INSERT INTO `packet_1337_07022020_1_data` (
    `data_packet_id`,
    `packet_table_name`,
    `contact_status_id`,
    `contact_method_id`,
    `data`
) VALUES
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 1", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 2", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 3", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 4", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 5", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 6", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 7", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 8", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 9", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 10", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 11", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 12", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 13", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 14", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 15", "phone_number": "(123) 123-4321"}'),
(8,'packet_1337_07022020_1_data',1,1,'{ "message": "This is a test 16", "phone_number": "(123) 123-4321"}');