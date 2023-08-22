const { logger } = require('../lib/logger')

const { isAtLeastHeadJudge } = require('../lib/general')

module.exports = (render) => {
  return async function (view, options, callback) {
    try {
      // bind security booleans
      // options.isAtLeastHeadJudge = isAtLeastHeadJudge

      options.debug = (parseInt(this.req.query?.debug) === 1)

      // this is a GET method, so we're most likely going to be rendering a view that needs options
      options.appName = process.env.APP_NAME
      options.appLogo = process.env.APP_LOGO
      options.appFavicon = process.env.APP_FAVICON
      options.appUrl = process.env.APP_URL

      if (options.originalUrl === undefined) {
        options.originalUrl = this.req.originalUrl
      }

      if (options.error_status === undefined) {
        options.errorStatus = ''
      }

      if (options.pageTitle === undefined) {
        options.pageTitle = ''
      }

      if (this.req.session) {
        if (this.req.session.user !== undefined) {
          options.user = JSON.parse(JSON.stringify(this.req.session.user))

          if (this.req.session.user.data === undefined) {
            this.req.session.user.data = {}
          }
        }
      }

      logger.debug('renderOverride() --------------[[[[[ END render override ]]]]]]-----------------')
      render.apply(this, arguments)
    } catch (err) {
      logger.error(err.stack)
      return callback(err)
    }
  }
}
