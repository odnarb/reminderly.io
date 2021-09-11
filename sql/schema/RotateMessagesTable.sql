DELIMITER //
CREATE PROCEDURE RotateMessagesTable()
BEGIN

    -- prepare a new messages table, based on the structure of the current one
    CREATE TABLE `messages_new` like `messages`;

    -- prep the statement
    PREPARE stmt1 FROM "RENAME TABLE `reminderly`.`messages` TO `reminderly`.`messages_history_?`";

    SET @current_history_num=0;

    -- get the next number we're to use for messages_history_# table name
    -- SELECT @group := `group` FROM user WHERE user = @user;

    SET @current_history_num = (SELECT
        max(id)+1
    FROM
        history_table_tracking
    WHERE
        table_name like 'messages_history%');

    -- further prepping
    PREPARE stmt FROM @current_history_num;

    -- do it.. move the current to be a backup
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- add our entry
    INSERT into history_table_tracking (`table_name`) VALUES ( CONCAT('messages_history_', @current_history_num ));

    -- bring the new table into production use
    RENAME TABLE `reminderly`.`messages_new` TO `reminderly`.`messages`;

 END //
DELIMITER ;