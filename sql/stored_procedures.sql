
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


DROP PROCEDURE IF EXISTS RotateMessagesTable;

DELIMITER //
CREATE PROCEDURE RotateMessagesTable()
BEGIN

    -- prepare a new messages table, based on the structure of the current one
    CREATE TABLE `messages_new` like `messages`;

    -- prep the statement
    PREPARE stmt1 FROM "RENAME TABLE `reminderly`.`messages` TO `reminderly`.`messages_history_?`";

    -- get the next number we're to use for messages_history_# table name
    SET @current_history_num = select max(id)+1 from messages_hist_tracking

    -- further prepping
    PREPARE stmt FROM @current_history_num;

    -- do it.. move the current to be a backup
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- add our entry
    INSERT into messages_hist_tracking (`table_name`) VALUES ( CONCAT('messages_history_', @current_history_num ));

    -- bring the new table into production use
    RENAME TABLE `reminderly`.`messages_new` TO `reminderly`.`messages`;

    -- now drop older messages tables.. anything older than 90 days, drop it
    -- TODO:
        -- get table names where `messages_hist_tracking`.`createdat` older than 90 days
        -- drop em

    -- done with table maint
 END //
DELIMITER ;