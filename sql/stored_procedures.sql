
DROP PROCEDURE IF EXISTS GetMessagesReady;

DELIMITER //
CREATE PROCEDURE GetMessagesReady(IN v_contact_method VARCHAR(80))
BEGIN

    -- get a guid for this group
    SET @new_tx_guid=UUID();

    CREATE TEMPORARY TABLE tmp_msgs(
        `id` INT NOT NULL AUTO_INCREMENT,
        `contact_method_id` INT NOT NULL,
        `contact_status_id` INT NOT NULL,
        `data` json NOT NULL,
        PRIMARY KEY (`id`), KEY(`id`)
    )  ENGINE=INNODB SELECT
            msgs.id,
            msgs.contact_method_id,
            msgs.contact_status_id,
            msgs.data
        FROM
            messages msgs
        INNER JOIN contact_method cm ON msgs.contact_method_id = cm.id
        INNER JOIN contact_status cs ON msgs.contact_status_id = cs.id
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
        contact_status_id = 2
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
    SET m.contact_status_id = 3
    WHERE
        cs.contact_status = 'queue'
        and m.tx_guid = p_tx_guid;


 END //
DELIMITER ;
