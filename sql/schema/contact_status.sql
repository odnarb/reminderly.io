/*
this is for the status of the message in the system, before it goes out
0 - not sent
1 - in queue
2 - sent
3 - error
*/
CREATE TABLE `contact_status` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL,
    `contact_status` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;