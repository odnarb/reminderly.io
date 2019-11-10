DROP USER IF EXISTS reminderly;
DROP DATABASE IF EXISTS reminderly;
CREATE DATABASE reminderly;
CREATE USER 'reminderly'@'%' IDENTIFIED BY 'Rem!nDerly123!$';
GRANT ALL PRIVILEGES ON reminderly.* TO 'reminderly'@'%';
-- CREATE USER 'reminderly'@'localhost' IDENTIFIED BY 'Rem!nDerly123!$';
-- GRANT ALL PRIVILEGES ON reminderly.* TO 'reminderly'@'localhost';
FLUSH PRIVILEGES;
USE reminderly;