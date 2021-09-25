DROP PROCEDURE loadPacketData;

DELIMITER //
CREATE PROCEDURE loadPacketData()
proc_label:BEGIN

    -- define limit.. if any
    DECLARE v_packet_table_name varchar(255) DEFAULT '';
    DECLARE v_filename varchar(255) DEFAULT '';
    DECLARE query varchar(1000) DEFAULT '';

    -- set some vars for the loop
    DECLARE loop_max INT DEFAULT 0;
    DECLARE loop_counter INT DEFAULT 1;

    -- get the packet rows that need to be ingested
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_campaign_ids_ready (
        id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
        data_packet_id INT,
        table_name VARCHAR(500),
        data_source VARCHAR(500)
    )
    AS (
        SELECT
            id AS data_packet_id,
            campaign_id,
            table_name,
            data_source
        FROM data_packet
        WHERE
            -- data packets that are prepped
            data_ingest_stage_id = 1

            -- data packets from SFTP only
            AND data_ingest_source_id = 1

            -- with less than 3 tries
            AND num_tries < 3
    );

    IF (SELECT count(*) FROM tmp_campaign_ids_ready) = 0 THEN
        LEAVE proc_label;
    END IF;

    SELECT COUNT(*) FROM tmp_campaign_ids_ready INTO loop_max;

    SET loop_counter=1;

    -- before this runs, we need to convert the line endings from \r\n to \n

    -- find the path to the file

    -- make sure it exists before trying?

    WHILE loop_counter < loop_max DO
        SET v_packet_table_name = (SELECT table_name FROM tmp_campaign_ids_ready WHERE id = loop_counter);
        SET v_filename = (SELECT data_source FROM tmp_campaign_ids_ready WHERE id = loop_counter);

        DROP TABLE IF EXISTS v_packet_table_name;

        CREATE TABLE v_packet_table_name like packet_data_template;

        SET query = CONCAT(
            'LOAD DATA LOCAL INFILE ', v_filename,' INTO TABLE ', v_packet_table_name, ' ',
            'FIELDS TERMINATED BY '','' ',
            'OPTIONALLY ENCLOSED BY ''"'' ',
            'LINES TERMINATED BY ''\n'' ',
            'IGNORE 1 LINES'
        );
        SET @query = CONCAT(query,';');

        SELECT @query as dyn_sql;

        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

      SET loop_counter = loop_counter + 1;
    END WHILE;

END //

DELIMITER ;
