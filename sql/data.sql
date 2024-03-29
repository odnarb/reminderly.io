
INSERT INTO users (
    first_name,
    last_name,
    email_address,
    phone_number,
    enabled,
    password_hash
) VALUES
('Brandon','Chambers', 'brandon@test.com', '(123) 123-1234',1,'12345'); -- no it's not a real pw hash.. chill out.
*/

INSERT INTO company (
    name,
    alias,
    details,
    active
) VALUES
('Test Company', 'TST-01', '{}', 1);

INSERT INTO customer (
    name,
    company_id,
    details,
    active
) VALUES
('Test Customer', 1, '{}', 1);

INSERT INTO customer_location (
    customer_id,
    name,
    address_1,
    city,
    state,
    zip
) VALUES
(1, 'Test Location', '123 Nowhere', 'Tucson', 'AZ','85737');

-- you, the client or support, name what the data source filename is supposed to be
INSERT INTO customer_campaigns (
    customer_id,
    name,
    description,
    timezone,
    active,
    data
)
VALUES
    (1, 'Test Campaign 1', 'Test Doctor', 'America/Phoenix',1,'{"contact_days": [1,2,3,4,5], "contact_window": { "start": "08:00", "end": "16:30"}, "contact_methods":[1,2,3],"data_ingest_source": 1, "data_source": "doctor_smith_appointments.csv", "messages": { "sms": "Hello, {data.first_name|name} you have an appointment on {data.date} at our {data.location.name} office. Reply 1 to CONFIRM, 2 to CANCEL and 3 to UNSUBSCRIBE. Please call {location.phone} to reschedule." } }'),
    (1, 'Test Campaign 2', 'Test Commercial','America/Los_Angeles', 1, '{"contact_days": [2,3,4,5], "contact_window": { "start": "07:00", "end": "17:00"}, "contact_methods":[1,2,3], "data_ingest_source": 1, "data_source": "internet_installs.csv", "messages": { "sms": "Hello, {data.first_name|name}! You have an appointment on {data.date} at {data.time} for internet installation. Reply 1 to CONFIRM, 2 to CANCEL and 3 to UNSUBSCRIBE. Please call {location.phone} to reschedule." } }'),
    (1, 'Test Campaign 3', 'Test School', 'America/New_York',1,'{"contact_days": [3,4,5,6,7], "contact_window": "now", "contact_methods":[1,2,3], "data_ingest_source": 1, "data_source": "early_out.csv", "messages": { "sms": "Hello {data.first_name|name}, your child {data.child_name|name} has early out tomorrow {data.date} {data.time}. Reply 1 to CONFIRM, 3 to UNSUBSCRIBE." } }'),
    (1, 'Test Campaign 4', 'Test Real Estate','America/Chicago',1,'{"contact_days": [2,3,4,5,6], "contact_window": { "start": "07:00", "end": "17:00"}, "contact_methods":[1,2,3], "data_ingest_source": 1, "data_source": "house_showings.csv", "messages": { "sms": "Hello, {data.first_name|name}! You have an appointment on {data.date} for a house showing at {data.location.address}. Reply 1 to CONFIRM, 2 to CANCEL and 3 to UNSUBSCRIBE. Please call {location.phone} to reschedule." } }');

/*
timezone conversion is: convert_tz( datetime, from, to ):
    convert_tz( now() , 'UTC', data.timezone )
*/

-- for windows of NOW
SELECT
    id,
    c.data->'$.contact_window' as contact_window,
    c.data->'$.data_source' as data_source
FROM customer_campaigns c
WHERE
    -- the contact day is this day
    LOCATE( dayofweek( convert_tz( now(), 'UTC', c.timezone ) ), c.data->'$.contact_days' )
    -- the window is NOW
    AND UPPER(JSON_UNQUOTE(c.data->'$.contact_window')) = 'NOW';

--------

SELECT
    id,
    json_unquote (data->'$.data_source') as data_source,
    timezone,
    json_unquote( json_extract(data, '$.contact_window.start') ) as start_time,
    json_unquote( json_extract(data, '$.contact_window.end') ) as end_time
FROM customer_campaigns
WHERE
    -- the contact day is this day
    LOCATE( dayofweek( convert_tz( now(), 'UTC', timezone ) ), data->'$.contact_days' )

    -- time start is correct per client campaign settings
    AND convert_tz( now(), 'UTC', timezone ) > concat(
        date_format( convert_tz(now(), 'UTC', timezone ), '%Y-%m-%d' ),
        ' ',
        json_unquote( json_extract(data, '$.contact_window.start') )
    )

    -- time start is correct per client campaign settings
    AND convert_tz( now(), 'UTC', timezone ) < concat(
        date_format( convert_tz(now(), 'UTC', timezone ), '%Y-%m-%d' ),
        ' ',
        json_unquote( json_extract(data, '$.contact_window.end') )
    );

-- 1 - API, 2 - UI
-- data_ingest_source table
INSERT INTO data_ingest_source (
    name,
    description
)
VALUES
    ('SFTP','This source means the data packet came from the SFTP source'),
    ('API','This source means the data packet came from the API'),
    ('UI','This source means the data packet came from our web portal upload');

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
INSERT INTO data_ingest_stage (
    name,
    description
)
VALUES
    ('Prepared', 'The data packet table is prepared for ingest.'),
    ('Ingested', 'The data packet sent to our system has been saved into our general area.'),
    ('Loaded', 'The data packet sent to our system has been loaded into the system.'),
    ('Mapped', 'The data packet sent to our system has been mapped according to your load map.'),
    ('Queued', 'The data packet sent to our system has been queued and is out for delivery.'),
    ('Complete', 'The data packet sent to our system has been completed.');

INSERT INTO contact_status (
    name,
    contact_status
)
VALUES
    ('not sent','The message has not been sent yet.'),
    ('polled','The message has been prepared for insert into the queue.'),
    ('queue','The message has been queued.'),
    ('sent','The message has been sent.'),
    ('error','There was an error with sending the message.');

INSERT INTO contact_methods
    (name)
VALUES
    ('sms'),
    ('email'),
    ('phone');

INSERT INTO data_packet
(
    campaign_id,
    data_ingest_source_id,
    data_ingest_stage_id,
    server_name,
    table_name,
    version,
    num_tries,
    metadata
)
VALUES
    (1,1,1,'localhost','',1,0,'{}'),
    (2,1,1,'localhost','',1,0,'{}'),
    (3,1,1,'localhost','',1,0,'{}'),
    (4,1,1,'localhost','',1,0,'{}');

/*
packet tables example:
    packet_1337_07022020_1_raw
    packet_1337_07022020_1_mapped
    packet_1337_07022020_1_queued
