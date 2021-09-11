DELIMITER //
CREATE PROCEDURE CleanupHistoryTables()
BEGIN

    -- drop older %_history tables.. anything older than 90 days, drop it
        -- get table names where `history_table_tracking`.`created_at` older than 90 days
        -- put them into a temp table
        CREATE TEMPORARY TABLE IF NOT EXISTS temp_hist_tables AS (
            SELECT
                *
            FROM
                history_table_tracking
            WHERE
                created_at < date_add(now(), INTERVAL -90 DAY)
        );

        -- drop em
        SET @tables = NULL;
        SELECT GROUP_CONCAT('`', table_name,'`') INTO @tables FROM temp_hist_tables;
        SET @tables = CONCAT('DROP TABLE IF EXISTS ', @tables);
        PREPARE stmt1 FROM @tables;
        EXECUTE stmt1;
        DEALLOCATE PREPARE stmt1;

        -- drop from the tracking table
        DELETE FROM history_table_tracking WHERE id IN (SELECT id FROM temp_hist_tables);

        DROP TEMPORARY TABLE temp_hist_tables;
        -- done with table maint

 END //
DELIMITER ;