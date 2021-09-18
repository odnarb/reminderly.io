DROP USER IF EXISTS reminderly;
DROP DATABASE IF EXISTS reminderly;
DROP DATABASE IF EXISTS _skeema_tmp;
CREATE DATABASE reminderly;
CREATE DATABASE _skeema_tmp;
CREATE USER 'reminderly'@'%' IDENTIFIED BY 'Rem!nDerly123!$';
GRANT ALL PRIVILEGES ON reminderly.* TO 'reminderly'@'%';

FLUSH PRIVILEGES;
USE reminderly;