DELIMITER //
CREATE PROCEDURE prepPacketData(IN i_campaign_id INT)
BEGIN

/*
    or we 
*/

/*
    we can do this en masse by selecting campaign ids (based on some criteria that says they're ready)
*/

SELECT campaign_id FROM customer_campaigns into #tmp_campaign_ids_ready

    DECLARE v_packet_table_name VARCHAR(255) DEFAULT '';
    DECLARE i_packet_data_id INT DEFAULT 1;
    DECLARE i_version INT DEFAULT 1;

    INSERT INTO data_packet
    (
        campaign_id,
        data_ingest_source_id,
        data_ingest_stage_id,
        server_name,
        table_name,
        version,
        num_tries,
        metadata
    ) VALUES (
        i_campaign_id,
        1,
        1,
        'localhost',
        '',
        1,
        0,
        '{}'
    );

    SET i_packet_data_id = (SELECT LAST_INSERT_ID());

    SET i_version = (SELECT version FROM data_packet WHERE id = i_packet_data_id);

    SET v_packet_table_name = (SELECT CONCAT( 'packet_', i_packet_data_id, '_', date_format( now(), '%m%d%Y'), '_', i_version, '_raw' ));

    UPDATE data_packet SET table_name = v_packet_table_name
    WHERE
        id = i_packet_data_id
        AND data_ingest_stage_id = 1;

    SELECT v_packet_table_name AS PACKET_TABLE_NAME;

END //

DELIMITER ;
