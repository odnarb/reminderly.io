/*
when building a message, one can apply functions to a message such as:
   {data.appointment_date|date|MM-DD-YYYY HH:MM A} - format date string
   {data.first_name|name} - capitalize the first letter, this is a proper name
   {data.last_name|name} - capitalize the first letter, this is a proper name
   {data.phone_number|phone} - try to format into a phone number
*/
CREATE TABLE `message_functions` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL DEFAULT '',
    `description` VARCHAR(255) NOT NULL DEFAULT '',
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    PRIMARY KEY (`id`)
)  ENGINE=INNODB;