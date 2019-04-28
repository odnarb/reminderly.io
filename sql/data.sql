-- 
-- 
-- NOW BEGIN DATA ENTRY
-- 

-- history_table_tracking table
INSERT INTO `history_table_tracking` (`table_name`, `created_at`, `updated_at`) VALUES
('messages_history_1', now(), now() ),
('messages_history_2', date_add(now(), INTERVAL -3 DAY), date_add(now(), INTERVAL -3 DAY) ),
('messages_history_3', date_add(now(), INTERVAL -10 DAY), date_add(now(), INTERVAL -10 DAY) ),
('messages_history_4', date_add(now(), INTERVAL -20 DAY), date_add(now(), INTERVAL -20 DAY) ),
('messages_history_5', date_add(now(), INTERVAL -30 DAY), date_add(now(), INTERVAL -30 DAY) ),
('messages_history_6', date_add(now(), INTERVAL -89 DAY), date_add(now(), INTERVAL -89 DAY) ),
('messages_history_7', date_add(now(), INTERVAL -90 DAY), date_add(now(), INTERVAL -90 DAY) ),
('messages_history_8', date_add(now(), INTERVAL -91 DAY), date_add(now(), INTERVAL -91 DAY) );
('messages_status_updates_history_1', now(), now() ),
('messages_status_updates_history_2', date_add(now(), INTERVAL -3 DAY), date_add(now(), INTERVAL -3 DAY) ),
('messages_status_updates_history_3', date_add(now(), INTERVAL -10 DAY), date_add(now(), INTERVAL -10 DAY) ),
('messages_status_updates_history_4', date_add(now(), INTERVAL -20 DAY), date_add(now(), INTERVAL -20 DAY) ),
('messages_status_updates_history_5', date_add(now(), INTERVAL -30 DAY), date_add(now(), INTERVAL -30 DAY) ),
('messages_status_updates_history_6', date_add(now(), INTERVAL -89 DAY), date_add(now(), INTERVAL -89 DAY) ),
('messages_status_updates_history_7', date_add(now(), INTERVAL -90 DAY), date_add(now(), INTERVAL -90 DAY) ),
('messages_status_updates_history_8', date_add(now(), INTERVAL -91 DAY), date_add(now(), INTERVAL -91 DAY) );


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


INSERT INTO `contact_status` (`contact_status`) VALUES
('not sent','The message has not been sent yet.'),
('queue','The message has been queued.'),
('sent','The message has been sent.'),
('error','There was an error with sending the message.');

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
