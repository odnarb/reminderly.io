const { logger } = require('../lib/logger')

const {
  allowPassThruRequest,
  loginPageRequest
} = require('../lib/utils')

module.exports = () => {
  return (req, res, next) => {
    const routeHeader = 'main() policy'

    logger.debug(`${routeHeader} :: --------------------- BEGIN`)

    if (!req.session.user) {
      req.session.user = { id: 0, permissions: {} }
    }

    // init session vars and info
    if (!req.session.isLoggedIn) {
      req.session.isLoggedIn = false
    }

    logger.debug(`${routeHeader} :: ${req.method}, ${req.url}`)

    logger.debug(`${routeHeader} :: req.originalUrl: ${req.originalUrl}`)

    // skip all the other middleware checks and allow pass-thru
    if (allowPassThruRequest(req.url)) {
      logger.debug(`${routeHeader} :: allowPassThruRequest TRUE`)
      return next()
    }

    // skip all the other middleware checks and allow to goto login pages
    if (loginPageRequest(req.url)) {
      logger.debug(`${routeHeader} :: loginPageRequest TRUE`)
      return next()
    }

    if (req.session.needsNewpassword === true) {
      logger.debug(`${routeHeader} :: needsNewpassword TRUE`)
      // grab the query params and pass to the redirect
      let queryStr = Object.keys(req.query).map(key => `${key}=${req.query[key]}`).join('&')
      if (queryStr !== '') {
        queryStr = '?' + queryStr
      }
      return res.redirect(`/users/newpassword${queryStr}`)
    }

    if (loginPageRequest(req.url) === false && req.session.isLoggedIn === false) {
      // grab the query params and pass to the redirect
      let queryStr = Object.keys(req.query).map(key => `${key}=${req.query[key]}`).join('&')
      if (queryStr !== '') {
        queryStr = '?' + queryStr
      }
      logger.debug(`${routeHeader} ::  REDIRECTING TO LOGIN PAGE (with queryStr?): ${queryStr}`)

      // save redirect
      req.session.redirectUri = req.url

      return res.redirect(`/users/login${queryStr}`)
    }

    if (loginPageRequest(req.url) === false && req.session.isLoggedIn === true) {
      logger.debug('main policy :: ALLOW APP PAGES')
      return next()
    }

    logger.debug(`${routeHeader} :: USER IS LOGGING IN`)
    return next()
  }
}
