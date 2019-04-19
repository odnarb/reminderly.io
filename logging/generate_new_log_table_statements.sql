-- create the tables
SELECT
	CONCAT('CREATE TABLE `', table_schema, '`.`', table_name, '_new` LIKE `', table_schema, '`.`', table_name, '`;')
FROM
	information_schema.tables
WHERE
	table_schema = 'reminderly'
	AND table_name LIKE BINARY 'log\_%';


-- RENAME TABLE `reminderly`.`log_users_ui_groups` TO `reminderly`.`drop_log_users_ui_groups_41920190001`;
SELECT
	CONCAT('RENAME TABLE `', table_schema, '`.`', table_name, '` TO `', table_schema, '`.`drop_', table_name, '_', date_format( curdate(), '%m%d%Y0001'), '`;')
FROM
	information_schema.tables
WHERE
	table_schema = 'reminderly'
	AND table_name LIKE BINARY 'log\_%';


-- RENAME TABLE `reminderly`.`log_users_ui_groups_new` TO `reminderly`.`log_users_ui_groups`;
SELECT
	CONCAT('RENAME TABLE `', table_schema, '`.`', table_name, '_new` TO `', table_schema, '`.`', table_name, '`;')
FROM
	information_schema.tables
WHERE
	table_schema = 'reminderly'
	AND table_name LIKE BINARY 'log\_%';