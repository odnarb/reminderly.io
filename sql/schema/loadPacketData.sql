DROP PROCEDURE loadPacketData;

DELIMITER //
CREATE PROCEDURE loadPacketData()
proc_label:BEGIN

    -- define limit.. if any
    DECLARE v_packet_table_name varchar(255) DEFAULT '';
    DECLARE v_filename varchar(255) DEFAULT '';

    DECLARE query varchar(1000) DEFAULT '';

    DECLARE i_data_packet_id INT DEFAULT 0;
    DECLARE i_campaign_id INT DEFAULT 0;

    -- set some vars for the loop
    DECLARE loop_max INT DEFAULT 0;
    DECLARE loop_counter INT DEFAULT 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        GET DIAGNOSTICS CONDITION 1 @msg_text = MESSAGE_TEXT;

        SELECT 'EXCEPTION DETECTED';

        IF @msg_text IS NULL THEN
        SELECT 'SETTING @msg_text..';
            SET @msg_text = '';
        END IF;

        INSERT INTO log_data_packet ( data_packet_id, log, details ) SELECT i_data_packet_id, CONCAT('ERROR:', @msg_text), '{}';

        SELECT CONCAT('DATA PACKET LOAD FAILED: ', i_data_packet_id );

        UPDATE
            data_packet
        SET
            num_tries = num_tries + 1
        WHERE
            id = i_data_packet_id;

        INSERT INTO log_data_packet ( data_packet_id, log, details ) SELECT i_data_packet_id, '---END (WITH ERROR)---', '{}';

        ROLLBACK;
    END;

    -- get the packet rows that need to be ingested
    DROP TABLE IF EXISTS tmp_campaign_ids_ready;
    CREATE TEMPORARY TABLE tmp_campaign_ids_ready (
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
            LIMIT 100
    );

    IF (SELECT count(*) FROM tmp_campaign_ids_ready) = 0 THEN
        LEAVE proc_label;
    END IF;

    SELECT COUNT(*) FROM tmp_campaign_ids_ready INTO loop_max;

    SET loop_counter=0;

    -- make sure it exists before trying?

    WHILE loop_counter < loop_max DO
        SELECT
            id,
            campaign_id,
            table_name,
            data_source
        INTO
            i_data_packet_id,
            i_campaign_id,
            v_packet_table_name,
            v_filename
        FROM tmp_campaign_ids_ready
        WHERE
            id = loop_counter+1;

        START TRANSACTION;

            INSERT INTO log_data_packet ( data_packet_id, log, details ) SELECT i_data_packet_id, '---START---', '{}';

            CANNOT LOAD FILE VIA PREPARED STATEMENT
            IT IS NOT SUPPORTED IN MYSQL
            I will have to run this from a script session to do it dynamically (node.js)
            SET query = CONCAT(
                'DROP TABLE IF EXISTS ',v_packet_table_name, ';',
                'CREATE TABLE ',v_packet_table_name,' like packet_data_template;',
                'LOAD DATA LOCAL INFILE ''/home/brandon/', v_filename, ''' ',
                'INTO TABLE ',v_packet_table_name, ' ',
                'CHARACTER SET utf8 ',
                'FIELDS ',
                'TERMINATED BY ''\\n'' ',
                'OPTIONALLY ENCLOSED BY ''"'' ',
                -- 'IGNORE 1 LINES ',
                '(raw_data)'
            );
            SET @query = CONCAT(query,';');

            INSERT INTO log_data_packet ( data_packet_id, log, details ) SELECT i_data_packet_id, CONCAT( 'BULK LOAD STATEMENT: ', @query ), '{}';

            PREPARE stmt FROM @query;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            INSERT INTO log_data_packet ( data_packet_id, log, details ) SELECT i_data_packet_id, 'BULK LOAD SUCCESSFUL', '{}';

            UPDATE
                data_packet
            SET
                num_tries = num_tries + 1,
                data_ingest_stage_id = 2
            WHERE
                id = i_data_packet_id;

            INSERT INTO log_data_packet ( data_packet_id, log, details ) SELECT i_data_packet_id, '---DONE---', '{}';

        COMMIT;

      SET loop_counter = loop_counter + 1;
    END WHILE;

END //

DELIMITER ;


truncate table log_data_packet;

call loadPacketData();

select * from log_data_packet;
