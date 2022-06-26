module.exports = (globals) => {
  return (req, res, next) => {
    const routeHeader = "loadResLocals() policy"

    if( res.locals.user === undefined ){
      res.locals.user = {}
    }

    globals.logger.debug(`${routeHeader} :: --------------------- BEGIN`)

    res.locals.debug = ( parseInt(req.query?.debug) === 1 )

    //this is a GET method, so we're most likely going to be rendering a view that needs res.locals
    res.locals.appName = process.env.APP_NAME
    res.locals.appLogo = process.env.APP_LOGO
    res.locals.appFavicon = process.env.APP_FAVICON
    res.locals.appUrl = process.env.APP_URL

    if(res.locals.originalUrl === undefined) {
      res.locals.originalUrl = req.originalUrl
    }

    if( res.locals.error_status === undefined ){
        res.locals.error_status = ''
    }

    if(res.locals.globals === undefined) {
      res.locals.globals = globals
    }
    if(res.locals.require === undefined) {
      res.locals.require = require
    }

    if( res.locals.pageTitle === undefined ) {
      res.locals.pageTitle = ""
    }

    if( req.session.user !== undefined ){
      res.locals.user = JSON.parse( JSON.stringify( req.session.user ) )

      if(req.session.user.data === undefined){
          req.session.user.data = {}
      }

      // TODO -- make these real
      res.locals.user.event_credits = 1
      res.locals.user.judging = 1
      //END TODO

      globals.logger.debug(`${routeHeader} :: req.session.user: id:${req.session.user.id} :: email:${req.session.user.email_address}` )
      globals.logger.debug(`${routeHeader} :: Loaded user info to res.locals...`)
    }

    globals.logger.debug(`${routeHeader} :: res.locals set..`)
    globals.logger.debug(`${routeHeader} :: --------------------- END`)

    next()
  };
};