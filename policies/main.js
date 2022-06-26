module.exports = (globals) => {
    return (req, res, next) => {
        //quick health check
        if( req.url == "/ping" ){
            return res.json({ success: true })
        }

        const routeHeader = "main() policy"

        globals.logger.debug(`${routeHeader} :: --------------------- BEGIN`)

        if( !req.session.user ) {
            req.session.user = {}
        }

        //init session vars and info
        if( req.session.isLoggedIn === undefined ) {
            req.session.isLoggedIn = false;
        }

        globals.logger.debug(`${routeHeader} :: ${req.method}, ${req.url}`);

        next();
    };
};