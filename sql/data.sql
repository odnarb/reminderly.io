-- 
-- 
-- NOW BEGIN DATA ENTRY
-- 

-- 1 - API, 2 - UI
-- data_ingest_source table
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(80) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
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


INSERT INTO `contact_status` (`contact_status`) VALUES
('not sent'),
('queue'),
('sent'),
('error');

INSERT INTO `contact_method` (`contact_method`) VALUES
('sms'),
('email'),
('phone');

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
