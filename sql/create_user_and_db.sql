DROP USER IF EXISTS reminderly;
DROP DATABASE IF EXISTS reminderly;
DROP DATABASE IF EXISTS _skeema_tmp;

CREATE DATABASE reminderly;
CREATE DATABASE _skeema_tmp;

CREATE USER 'reminderly'@'localhost' IDENTIFIED WITH mysql_native_password BY 'reminderly';
CREATE USER 'reminderly'@'%' IDENTIFIED WITH mysql_native_password BY 'reminderly';

GRANT ALL PRIVILEGES ON reminderly.* TO 'reminderly'@'%';
GRANT ALL PRIVILEGES ON _skeema_tmp.* TO 'reminderly'@'%';

GRANT ALL PRIVILEGES ON reminderly.* TO 'reminderly'@'localhost';
GRANT ALL PRIVILEGES ON _skeema_tmp.* TO 'reminderly'@'localhost';

FLUSH PRIVILEGES;
USE reminderly;