DELIMITER //
CREATE PROCEDURE RotateMessageStatusUpdatesTable()
BEGIN

    -- prepare a new messages_status_updates table, based on the structure of the current one
    CREATE TABLE `messages_status_updates_new` like `messages_status_updates`;

    -- prep the statement
    PREPARE stmt1 FROM "RENAME TABLE `reminderly`.`messages_status_updates` TO `reminderly`.`messages_status_updates_history_?`";

    SET @current_history_num=0;

    -- get the next number we're to use for messages_status_updates_history_# table name
    SET @current_history_num = (SELECT
        max(id)+1
    FROM
        history_table_tracking
    WHERE
        table_name like 'messages_status_updates_history%');

    -- further prepping
    PREPARE stmt FROM @current_history_num;

    -- do it.. move the current to be a backup
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- add our entry
    INSERT into history_table_tracking (`table_name`) VALUES ( CONCAT('messages_status_updates_history_', @current_history_num ));

    -- bring the new table into production use
    RENAME TABLE `reminderly`.`messages_status_updates_new` TO `reminderly`.`messages_status_updates`;

 END //
DELIMITER ;