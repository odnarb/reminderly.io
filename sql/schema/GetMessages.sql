DELIMITER //
CREATE PROCEDURE GetMessages(IN v_contact_method VARCHAR(80))
BEGIN

    -- get a guid for this group
    SET @new_tx_guid=UUID();

     CREATE TEMPORARY TABLE tmp_msgs(
        `message_id` INT NOT NULL,
        `contact_method_id` INT NOT NULL,
        `contact_status_id` INT NOT NULL,
        `tx_guid` VARCHAR(80) NOT NULL DEFAULT '',
        `data` json NOT NULL,
        PRIMARY KEY (`id`), KEY(`id`)
    )  ENGINE=INNODB SELECT
            msgs.id,
            msgs.contact_method_id,
            cs.id,
            @new_tx_guid,
            msgs.data
        FROM
            messages msgs
        INNER JOIN contact_method cm
            ON msgs.contact_method_id = cm.id
        INNER JOIN messages_status_updates msu
            ON msu.message_id = msgs.id
        INNER JOIN contact_status cs
            ON msu.contact_status_id = cs.id
        WHERE
            -- text match here: sms, email, phone. etc..maybe weak?
            cm.contact_method = v_contact_method
            AND ISNULL(cs.contact_status)
        ORDER BY contact_date DESC
        LIMIT 1000;

    -- insert an entry for each msg to contain a guid
    INSERT INTO messages_status_updates
        (message_id, tx_guid, contact_status_id, created_at, updated_at)
    SELECT
        ( message_id, @new_tx_guid, contact_status_id, getdate(), getdate() )
    FROM
       tmp_msgs;


    -- select from tmp_msgs insert into messages_status_updates

    -- SELECT @new_tx_guid;
    -- SELECT id FROM tmp_msgs;
    -- SELECT * from messages WHERE id IN (SELECT id FROM tmp_msgs);
    SELECT * FROM tmp_msgs;

    DROP TEMPORARY TABLE tmp_msgs;
 END //
DELIMITER ;