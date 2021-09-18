DELIMITER //
CREATE PROCEDURE loadPacketData(IN o_packet JSON)
BEGIN

    -- define limit.. if any
    DECLARE v_packet_table_name VARCHAR(255) DEFAULT '';
    DECLARE query VARCHAR(1000) DEFAULT '';

    SET v_packet_table_name  = JSON_UNQUOTE(JSON_EXTRACT(o_packet,'$.packet_table_name'));

    /*
    -- get pagination details
    SET query = CONCAT('SELECT count(*) as total_row_count FROM ', v_packet_table_name, ' ');
    SET query = CONCAT(query, 'WHERE contact_status_id=1 and num_tries < 3' );
    SET @query = CONCAT(query,';');

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    */

    -- before this runs, we need to convert the line endings from \r\n to \n

    -- find the path to the file

    -- make sure it exists before trying?

    /*
    LOAD DATA LOCAL INFILE "/path/to/file.csv"
    INTO TABLE @packet_table_name
    COLUMNS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES;
    */

END //

DELIMITER ;
