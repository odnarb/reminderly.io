module.exports = (opts) => {

    let module = {};

    const winston = require('winston');

    module.models = require('../models')(opts.sequelize)

    module.logger = winston.createLogger({
      format: winston.format.combine(
        winston.format.timestamp({
          format: 'YYYY-MM-DD HH:mm:ss',
        }),
        winston.format.printf((info) => {
            let msg = `[${info.timestamp}]`;
            if( info.label ){
                msg += ` [${info.label}] `;
            }
            if( info.label ){
                msg += ` [${info.label}] `;
            }
            if( info.level ){
                msg += ` [${info.level}] `;
            }

            msg += `- ${info.message}`;

            if( info[Symbol.for("splat")] && info[Symbol.for("splat")].length > 0 ){
                const util = require('util');
                let numSplats = info[Symbol.for("splat")].length;
                for(let i=0; i < numSplats; i++){
                    msg += " : " + util.inspect( info[Symbol.for("splat")][i] );
                }
            }
            return msg;
        })
      ),
      transports: [
        new winston.transports.Console({ level: opts.loglevel })
      ]
    });

    //14 days
    module.COOKIE_MAX_AGE = 14 * 24 * 60 * 60 * 1000;

    //1 hr
    module.COOKIE_MIN_AGE = 60 * 60 * 1000;

    module.DEFAULT_USER_TYPE = 1;

    module.salt_rounds = 10;

    module.USER_TYPES = {
       USER: 1,
       SUPPORT: 2,
       ADMIN: 3
    }

    module.NOTIFICATION_TYPES = {
       registration: 1,
       billing: 2,
       forgot_password: 3,
       judge_invite: 4
    }

    module.NOTIFICATION_STATUS = {
        PENDING: 1,
        SENT: 2,
        ERROR: 3
    }

    module.NOTIFICATION_METHODS = {
        sms: 1,
        fb_messenger: 2,
        whatsapp: 3,
        email: 4,
        instagram: 5,
        twitter: 6
    }

    module.REGISTRATION_STATUS = {
        PENDING: 1,
        VERIFIED: 2,
        PAID: 3,
        EXPIRED: 4,
        ERROR: 5,
    }

    //init the db object
    module.db = {};

    module.allowedMethods = ['GET', 'PUT', 'POST', 'DELETE', 'HEAD', 'OPTIONS'];

    module.errorPages = {
        '400': '400',
        '401': '401',
        '403': '403',
        '500': '500',
        '502': '502',
        '503': '503'
    };

    return module;
};