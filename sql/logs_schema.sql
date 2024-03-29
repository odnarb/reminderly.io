-- log_company table
CREATE TABLE `log_company` (
    `id` INT AUTO_INCREMENT,
    `company_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_id`) REFERENCES company (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_company_location table
CREATE TABLE `log_company_location` (
    `id` INT AUTO_INCREMENT,
    `company_location_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_location_id`) REFERENCES company_location (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_customer table
CREATE TABLE `log_customer` (
    `id` INT AUTO_INCREMENT,
    `customer_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`customer_id`) REFERENCES customer (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_company_campaigns table
CREATE TABLE `log_company_campaigns` (
    `id` INT AUTO_INCREMENT,
    `company_campaign_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_campaign_id`) REFERENCES company_campaigns (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_contact_method_providers table
CREATE TABLE `log_contact_method_providers` (
    `id` INT AUTO_INCREMENT,
    `contact_method_provider_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`contact_method_provider_id`) REFERENCES contact_method_providers (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_data_ingest_source table
CREATE TABLE `log_data_ingest_source` (
    `id` INT AUTO_INCREMENT,
    `data_ingest_source_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_ingest_source_id`) REFERENCES data_ingest_source (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_data_ingest_stage table
CREATE TABLE `log_data_ingest_stage` (
    `id` INT AUTO_INCREMENT,
    `data_ingest_stage_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`data_ingest_stage_id`) REFERENCES data_ingest_stage (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_company_load_map table
CREATE TABLE `log_company_load_map` (
    `id` INT AUTO_INCREMENT,
    `company_load_map_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_load_map_id`) REFERENCES company_load_map (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_packet_table_tracking table
CREATE TABLE `log_history_table_tracking` (
    `id` INT AUTO_INCREMENT,
    `packet_table_tracking_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`packet_table_tracking_id`) REFERENCES packet_table_tracking (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;



-- log_sms_unsubscribe table
CREATE TABLE `log_sms_unsubscribe` (
    `id` INT AUTO_INCREMENT,
    `sms_unsubscribe_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`sms_unsubscribe_id`) REFERENCES sms_unsubscribe (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


/*
Not slated for MVP

-- what if a user deletes themselves??? (foreign key issue?)
-- log_users table
CREATE TABLE `log_users` (
    `id` INT AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_users_passwords table
CREATE TABLE `log_users_passwords` (
    `id` INT AUTO_INCREMENT,
    `users_passwords_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`users_passwords_id`) REFERENCES users_passwords (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_roles table
CREATE TABLE `log_roles` (
    `id` INT AUTO_INCREMENT,
    `role_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`role_id`) REFERENCES roles (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_policies table
CREATE TABLE `log_policies` (
    `id` INT AUTO_INCREMENT,
    `policy_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`policy_id`) REFERENCES policies (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_roles_policies table
CREATE TABLE `log_roles_policies` (
    `id` INT AUTO_INCREMENT,
    `roles_policies_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`roles_policies_id`) REFERENCES roles_policies (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_users_roles table
CREATE TABLE `log_users_roles` (
    `id` INT AUTO_INCREMENT,
    `users_roles_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`users_roles_id`) REFERENCES roles_policies (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_ui_groups table
CREATE TABLE `log_ui_groups` (
    `id` INT AUTO_INCREMENT,
    `ui_groups_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`ui_groups_id`) REFERENCES ui_groups (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_roles_ui_groups table
CREATE TABLE `log_roles_ui_groups` (
    `id` INT AUTO_INCREMENT,
    `roles_ui_groups_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`roles_ui_groups_id`) REFERENCES roles_ui_groups (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_users_ui_groups table
CREATE TABLE `log_users_ui_groups` (
    `id` INT AUTO_INCREMENT,
    `users_ui_groups_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`users_ui_groups_id`) REFERENCES users_ui_groups (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_groups table
CREATE TABLE `log_groups` (
    `id` INT AUTO_INCREMENT,
    `group_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`group_id`) REFERENCES groups (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_company_apps table
CREATE TABLE `log_company_apps` (
    `id` INT AUTO_INCREMENT,
    `company_apps_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_apps_id`) REFERENCES company_apps (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_company_group table
CREATE TABLE `log_company_group` (
    `id` INT AUTO_INCREMENT,
    `company_group_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_group_id`) REFERENCES company_group (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_email_unsubscribe table
CREATE TABLE `log_email_unsubscribe` (
    `id` INT AUTO_INCREMENT,
    `email_unsubscribe_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`email_unsubscribe_id`) REFERENCES email_unsubscribe (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_phone_unsubscribe table
CREATE TABLE `log_phone_unsubscribe` (
    `id` INT AUTO_INCREMENT,
    `phone_unsubscribe_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`phone_unsubscribe_id`) REFERENCES phone_unsubscribe (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_company_api table
CREATE TABLE `log_company_api` (
    `id` INT AUTO_INCREMENT,
    `company_api_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_api_id`) REFERENCES company_api (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_company_apps_restriction table
CREATE TABLE `log_company_apps_restriction` (
    `id` INT AUTO_INCREMENT,
    `company_apps_restriction_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`company_apps_restriction_id`) REFERENCES company_apps_restriction (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_contact_blocks table
CREATE TABLE `log_contact_blocks` (
    `id` INT AUTO_INCREMENT,
    `contact_blocks_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`contact_blocks_id`) REFERENCES contact_blocks (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_i18n_strings table
CREATE TABLE `log_i18n_strings` (
    `id` INT AUTO_INCREMENT,
    `i18n_string_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`i18n_string_id`) REFERENCES i18n_string (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_products table
CREATE TABLE `log_products` (
    `id` INT AUTO_INCREMENT,
    `product_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`product_id`) REFERENCES products (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_email_queue table
CREATE TABLE `log_email_queue` (
    `id` INT AUTO_INCREMENT,
    `email_queue_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`email_queue_id`) REFERENCES email_queue (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;


-- log_phone_queue table
CREATE TABLE `log_phone_queue` (
    `id` INT AUTO_INCREMENT,
    `phone_queue_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `details` json NOT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT NOW(),
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (`phone_queue_id`) REFERENCES phone_queue (`id`),
    FOREIGN KEY (`user_id`) REFERENCES users (`id`),
    PRIMARY KEY (`id`)
)  ENGINE=MyISAM;