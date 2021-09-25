DELIMITER //
CREATE PROCEDURE prepPacketData()
proc_label:BEGIN

    /*
        Prep campaign data packets such that there's a table name prepared and entry in data_packet
    */
    DROP TABLE IF EXISTS tmp_campaign_ids_ready;

    CREATE TEMPORARY TABLE tmp_campaign_ids_ready (
        id INT,
        data_source VARCHAR(500),
        packet_table_name VARCHAR(500),
        version INT
    )
    AS (
        SELECT
            c.id,
            json_unquote (c.data->'$.data_source') as data_source,
            CONCAT('packet_',c.id,'_', DATE_FORMAT( now(), '%m%d%Y'),'_', (COALESCE( dp.version, 0 ) + 1),'_data') as packet_table_name,
            (COALESCE( dp.version, 0 ) + 1) as version
        FROM customer_campaigns c
        LEFT JOIN data_packet dp ON c.id = dp.campaign_id
        WHERE
            -- the contact day is this day
            LOCATE( dayofweek( convert_tz( now(), 'UTC', timezone ) ), c.data->'$.contact_days' )

            -- time start is correct per client campaign settings
            AND convert_tz( now(), 'UTC', timezone ) > concat(
                date_format( convert_tz(now(), 'UTC', timezone ), '%Y-%m-%d' ),
                ' ',
                json_unquote( json_extract(c.data, '$.contact_window.start') )
            )

            -- time start is correct per client campaign settings
            AND convert_tz( now(), 'UTC', timezone ) < concat(
                date_format( convert_tz(now(), 'UTC', timezone ), '%Y-%m-%d' ),
                ' ',
                json_unquote( json_extract(c.data, '$.contact_window.end') )
            )
            AND c.id NOT IN (
                SELECT c.id FROM data_packet WHERE data_ingest_stage_id < 6 AND dp.campaign_id = c.id
            )
    );

    IF (SELECT count(*) FROM tmp_campaign_ids_ready) = 0 THEN
        SELECT 'LEAVING';
        LEAVE proc_label;
    END IF;

    INSERT INTO data_packet (
        campaign_id,
        data_ingest_source_id,
        data_ingest_stage_id,
        server_name,
        table_name,
        data_source,
        version,
        num_tries,
        metadata
    ) SELECT
        id,
        1,
        1,
        'localhost',
        packet_table_name,
        data_source,
        version,
        0,
        '{}'
    FROM tmp_campaign_ids_ready;

END //

DELIMITER ;
