DELIMITER //
CREATE PROCEDURE prepPacketData(IN i_campaign_id INT)
BEGIN

    DECLARE v_packet_table_name VARCHAR(255) DEFAULT '';
    DECLARE i_packet_data_id INT DEFAULT 1;
    DECLARE i_version INT DEFAULT 1;

    insert into data_packet
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

    set i_packet_data_id = (select LAST_INSERT_ID());

    set i_version = (select version from data_packet where id = i_packet_data_id);

    set v_packet_table_name = (select CONCAT( 'packet_', i_packet_data_id, '_', date_format( now(), '%m%d%Y'), '_', i_version, '_raw' ));

    update data_packet set table_name = v_packet_table_name where id = i_packet_data_id;

    select v_packet_table_name as PACKET_TABLE_NAME;

END //

DELIMITER ;
