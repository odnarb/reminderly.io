const { logger } = require('../lib/logger')

const { loginPageRequest, adminPageRequest } = require('../lib/utils')

const { createUserAnalytic } = require('../core/analytics')

module.exports = ({ UserAnalytics }) => {
  return async (req, res, next) => {
    try {
      if (adminPageRequest(req.url) || loginPageRequest(req.url) || req.session.user.id === 0) {
        return next()
      }

      const newAnalyticsObj = {
        user_id: req.session.user.id,
        method: req.method,
        url: req.originalUrl,
        full_url: req.protocol + '://' + req.get('Host') + req.originalUrl,
        referrer: req.get('Referrer') || 'none',
        user_agent: req.get('User-Agent') || 'not detected',
        ip_address: req.get('X-Forwarded-For') || req.connection.remoteAddress,
        status_code: res.statusCode
      }
      await createUserAnalytic({ UserAnalytics, newAnalyticsObj })

      return next()
    } catch (err) {
      logger.error(`Could not create user analytic object. ${err.stack}`)
      return next(err)
    }
  }
}
