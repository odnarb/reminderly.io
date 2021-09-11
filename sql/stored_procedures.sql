/*
The rest of the procs in here are just a bunch of CRUD operations.
Not sure if I want to keep this. For now, I will focus on core operations,
such as packet loading, message queueing, etc.
*/


-- createCompany()
DELIMITER //
CREATE PROCEDURE createCompany(IN o_company JSON)
BEGIN

    DECLARE v_name VARCHAR(255) DEFAULT null;
    DECLARE v_alias VARCHAR(255) DEFAULT null;
    DECLARE j_details JSON DEFAULT null;

    SET v_name = JSON_UNQUOTE(JSON_EXTRACT(o_company,'$.name'));
    SET v_alias = JSON_UNQUOTE(JSON_EXTRACT(o_company,'$.alias'));
    SET j_details = JSON_UNQUOTE(JSON_EXTRACT(o_company,'$.details'));

    INSERT INTO
    `company` (
        `name`,
        `alias`,
        `details`
    ) VALUES (
        v_name,
        v_alias,
        j_details
    );

    select last_insert_id() as company_id;

END //

DELIMITER ;


-- removeCompany()
DELIMITER //
CREATE PROCEDURE removeCompany(IN o_company JSON)
BEGIN

    DECLARE i_company_id INT DEFAULT null;

    SET i_company_id = JSON_UNQUOTE(JSON_EXTRACT(o_company,'$.id'));

    delete from company where id = i_company_id;

END //

DELIMITER ;



-- getCompany()
DELIMITER //
CREATE PROCEDURE getCompany(IN o_company JSON)
BEGIN

    DECLARE i_company_id INT DEFAULT null;

    SET i_company_id = JSON_UNQUOTE(JSON_EXTRACT(o_company,'$.id'));

    select
        id,
        name,
        alias,
        details,
        active,
        updated_at,
        created_at
    from
        company
    where
        id = i_company_id;

END //

DELIMITER ;


-- updateCompany()
DELIMITER //
CREATE PROCEDURE updateCompany(IN o_company JSON)
BEGIN

    DECLARE i_company_id INT DEFAULT null;
    DECLARE v_name VARCHAR(255) DEFAULT null;
    DECLARE v_alias VARCHAR(255) DEFAULT null;
    DECLARE i_active INT DEFAULT null;
    DECLARE j_details JSON DEFAULT null;

    SET i_company_id = JSON_UNQUOTE(JSON_EXTRACT(o_company,'$.id'));
    SET v_name = JSON_UNQUOTE(JSON_EXTRACT(o_company,'$.name'));
    SET v_alias = JSON_UNQUOTE(JSON_EXTRACT(o_company,'$.alias'));
    SET i_active = JSON_UNQUOTE(JSON_EXTRACT(o_company,'$.active'));
    SET j_details = JSON_UNQUOTE(JSON_EXTRACT(o_company,'$.details'));

    update
        company
    SET
        name = v_name,
        alias = v_alias,
        details = j_details,
        active = i_active,
        updated_at = now()
    where id = i_company_id;

END //

DELIMITER ;


-- getCompanies()
DELIMITER //
CREATE PROCEDURE getCompanies(IN o_search JSON)
BEGIN

    DECLARE v_search VARCHAR(255) DEFAULT '';
    DECLARE v_order VARCHAR(80) DEFAULT 'name';
    DECLARE v_order_direction VARCHAR(80) DEFAULT 'ASC';
    DECLARE i_limit INT DEFAULT 10;
    DECLARE i_offset INT DEFAULT 0;
    DECLARE query VARCHAR(1000) DEFAULT '';

    DECLARE v_order_override VARCHAR(80) DEFAULT '';
    DECLARE v_order_direction_override VARCHAR(80) DEFAULT '';
    DECLARE i_limit_override INT DEFAULT 0;
    DECLARE i_offset_override INT DEFAULT 0;

    SET v_search = JSON_UNQUOTE(JSON_EXTRACT(o_search,'$.search'));

    SET v_order_override  = JSON_UNQUOTE(JSON_EXTRACT(o_search,'$.order'));
    SET v_order_direction_override = JSON_UNQUOTE(JSON_EXTRACT(o_search,'$.order_direction'));
    SET i_limit_override  = JSON_UNQUOTE(JSON_EXTRACT(o_search,'$.limit'));
    SET i_offset_override = JSON_UNQUOTE(JSON_EXTRACT(o_search,'$.offset'));

    IF v_order_override = 'id' OR v_order_override = 'name' OR v_order_override = 'alias' THEN
        SET v_order = v_order_override;
    END IF;

    IF v_order_direction_override = 'DESC' THEN
        SET v_order_direction = 'DESC';
    END IF;

    IF (i_limit_override > 10) AND (i_limit_override <= 100) THEN
        SET i_limit = i_limit_override;
    END IF;

    SET query = 'SELECT id,name,alias,active,updated_at,created_at FROM company';

    IF v_search <> '' THEN
        SET query = CONCAT(query, ' WHERE active=1 and name LIKE CONCAT(''%'',', v_search, ',''%'')' );
    ELSE
        SET query = CONCAT(query, ' WHERE active=1' );
    END IF;

    SET @query = CONCAT(query, ' ORDER BY ', v_order, ' ', v_order_direction, ' LIMIT ', i_limit);

    SET query = CONCAT(query, ' LIMIT ', i_limit);

    IF (i_offset_override > 0) THEN
        SET i_offset = i_offset_override;
        SET query = CONCAT(query,', ', i_offset);
    END IF;

    SET @query = CONCAT(query,';');

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END //

DELIMITER ;