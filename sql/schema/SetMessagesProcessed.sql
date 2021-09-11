DELIMITER //
CREATE PROCEDURE SetMessagesProcessed(IN p_tx_guid VARCHAR(80))
BEGIN

    -- SET @tx_guid='7566e977-5e23-11e9-9f1d-000c2988b5a1';
    -- get messages with this tx_guid from status updates table

    INSERT INTO messages_status_updates
        (message_id, tx_guid, contact_status_id, created_at, updated_at)
    SELECT
        message_id, tx_guid, 2, created_at, updated_at
    FROM
       tmp_msgs;

    UPDATE messages m
    INNER JOIN contact_status cs
    ON m.contact_status = cs.id
    SET m.contact_status_id = 3
    WHERE
        cs.contact_status = 'queue'
        and m.tx_guid = p_tx_guid;

 END //
DELIMITER ;