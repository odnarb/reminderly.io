const winston = require('winston')

const LOG_LEVEL = (process.env.NODE_ENV === 'production') ? 'info' : 'debug'

// examples of log output at different levels..
// logger.silly("127.0.0.1 - there's no place like home");
// logger.debug( "127.0.0.1 - there's no place like home");
// logger.verbose( "127.0.0.1 - there's no place like home");
// logger.info( "127.0.0.1 - there's no place like home");
// logger.warn( "127.0.0.1 - there's no place like home");
// logger.error("127.0.0.1 - there's no place like home", { test: 123, blah: () => { return "test"} });

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp({
      format: 'YYYY-MM-DD HH:mm:ss'
    }),
    winston.format.printf((info) => {
      let msg = `[${info.timestamp}]`
      if (info.label) {
        msg += ` [${info.label}] `
      }
      if (info.label) {
        msg += ` [${info.label}] `
      }
      if (info.level) {
        msg += ` [${info.level}] `
      }

      msg += `- ${info.message}`

      if (info[Symbol.for('splat')] && info[Symbol.for('splat')].length > 0) {
        const util = require('util')
        const numSplats = info[Symbol.for('splat')].length
        for (let i = 0; i < numSplats; i++) {
          msg += ' : ' + util.inspect(info[Symbol.for('splat')][i])
        }
      }
      return msg
    })
  ),
  transports: [
    new winston.transports.Console({ level: LOG_LEVEL })
  ]
})

module.exports.logger = logger
