/*
 1 - sms,2 - email, 3 - phone
*/
CREATE TABLE `contact_methods` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL,
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;