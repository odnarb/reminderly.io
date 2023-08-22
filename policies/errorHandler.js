const { logger } = require('../lib/logger')

const { errorPages } = require('../lib/globals')

module.exports = () => {
  return (error, req, res, next) => {
    try {
      res.locals.appName = process.env.APP_NAME
      res.locals.appLogo = process.env.APP_LOGO
      res.locals.appFavicon = process.env.APP_FAVICON
      res.locals.appUrl = process.env.APP_URL

      if (res.headersSent === true) {
        logger.error(`HEADERS ALREADY SENT: method:${req.method}, url:${req.url}`, error)
      }

      if (error) {
        // if we got here and the status code is still 200, change it to an error
        if (res.statusCode === 200) {
          logger.error('Hit error handler, but statusCode === 200.')
          res.statusCode = 500
        }

        if (req.xhr) {
          logger.debug(`(XHR) Caught ERROR: ${error.stack}`)
          return res.status(res.statusCode).json({ status: 'error', err_msg: 'Server Error' })
        }

        const errorId = error.status || res.statusCode
        let errPage = errorPages[errorId]

        if (errPage === undefined) {
          errPage = 'generalError'
        }
        const errPageStr = 'errors/' + errPage + '.ejs'

        // for the error handler, we need to set the variable in res.locals
        return res.status(error.status || res.statusCode).render(errPageStr, {
          layout: 'error_layout',
          pageTitle: `${res.statusCode} Error`,
          error_status: res.statusCode
        })
      }
    } catch (err) {
      logger.error(`Caught Error in error handler: ${err.stack}`)
      return res.status(500).json({ status: '500 Internal Server Error' })
    }
  }
}
