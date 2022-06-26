// require('newrelic');

/*
*
* Server for app dashboard
*
*/

//get the args starting at position 2 (node app.js --port 3000)
const args = require('minimist')(process.argv.slice(2));

//load env vars from .env file
require('dotenv').config();

//get the log level, depending on what's passed
const level = { loglevel: process.env.LOG_LEVEL || 'debug' };


//////////////////////////////////////////////////////////////////
// MYSQL CONFIG
//////////////////////////////////////////////////////////////////

const { Sequelize, Model, DataTypes } = require('sequelize');
const sequelize = new Sequelize( process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
  host: process.env.DB_HOST,
  dialect: 'mysql',
  pool: {
    max: 10,
    min: 1,
    acquire: 30000,
    idle: 10000
  }
});


const
    globals = require('./lib/globals.js')({ level: level, sequelize: sequelize }),
    express = require('express'),
    moment = require('moment'),
    session = require('express-session'),
    bodyParser = require('body-parser'),
    cookieParser = require('cookie-parser'),
    csrf = require('csurf'),
    events = require('events'),
    favicon = require('serve-favicon'),
    path = require('path'),
    uuid = require('uuid'),
    expressLayouts = require('express-ejs-layouts');

const app = express();
const router = express.Router();

const session_secret = process.env.SESSION_SECRET

//setup redis
const redis = require('redis');
const redisStore = require('connect-redis')(session);
const redisClient = redis.createClient();

redisClient.on('error', (err) => {
    console.log('Redis error: ', err);
});

//////////////////////////////////////////////////////////////////
// EXPRESS SETUP
//////////////////////////////////////////////////////////////////
//Setup router configuration

////////////////////////////////////////////
////    EXPRESS MIDDLEWARE & OPTIONS    ////
////////////////////////////////////////////

//create the logger for routes
app.set('logger', globals.logger);

//disable powered by header
app.set('x-powered-by', false);

// set the view engine to ejs
app.use(expressLayouts);
app.set('view engine', 'ejs');
app.set('layout', './layout.ejs');

//where are the static assets?
    //I've tested this and if an asset exists, the file is served directly
    // without any policies being applied, but if it does not, the asset request
    // flows next through the policy chain and routes
app.use(express.static( path.join(__dirname, "public" )));

//set the favicon
app.use(favicon(path.join(__dirname, 'public', process.env.APP_FAVICON )))

// Ensures that the content-type for SNS messages
app.use(function(req, res, next) {
    if (req.get("x-amz-sns-message-type")) {
      req.headers["content-type"] = "application/json"; //IMPORTANT, otherwise content-type is text for topic confirmation reponse, and body is empty
    }
    next();
});

//Don't need to do parsing just yet..
app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies

const redis_config = {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    client: redisClient
    // ttl: process.env.REDIS_TTL
};

app.use(cookieParser());
// //csrf options
const csrfMiddleware = csrf({
    cookie: true
});
app.use(csrfMiddleware);

//setup session
app.use(session({
    genid: (req) => {
        return uuid.v4();
    },
    //always use a secure secret, not something committed to the repo
    secret: `${session_secret}`,

    //i.e. "sess_foobar" is the cookie name
    name: `_${process.env.APP_NAME.toLowerCase()}`,

    //probably a good thing to set to true for PROD
    resave: false,

    //probably leave to true
    saveUninitialized: true,
    cookie: {
        secure: false, // this should be set to true for SSL
              // m *  s * ms
        maxAge:  5 * 60 * 1000
    },
    store: new redisStore(redis_config)
}));

//apply our router function to ALL methods defined in router
const mainPolicy = require('./policies/main.js')(globals);
app.use(mainPolicy);

const loadResLocalsPolicy = require('./policies/loadResLocals.js')(globals);
app.use(loadResLocalsPolicy);

//set some local variables to boot, so routes and views can access
app.use( (req,res,next) => {
    res.locals.appName = process.env.APP_NAME;
    res.locals.url = req.url;
    res.locals._csrf = req.csrfToken();

    if( res.locals.error_status == undefined ){
        res.locals.error_status = ''
    }
    if( res.locals.user === undefined ){
        res.locals.user = {}
    }
    if( req.session.isLoggedIn ){
        res.locals.user = req.session.user;
    }
    if( req.session.user_context && req.session.user_context.id > 0 ){
        res.locals.user_context = req.session.user_context;
    } else {
        res.locals.user_context = undefined;
    }
    next();
});

////////////////////////////////////////////////////////
// APP ROUTER
////////////////////////////////////////////////////////

const routeMain = require('./routes/main.js')(globals);
app.use('/', routeMain);

// const user = require('./routes/user.js')(globals);
// app.use('/user', user);

// const companies = require('./routes/companies.js')(globals);
// app.use('/companies', companies);

// const campaigns = require('./routes/campaigns.js')(globals);
// app.use('/campaigns', campaigns);


//handle 404's
app.use( (req, res, next) => {
    globals.logger.info("ERROR 404 :: requested url: " + req.url );

    if( req.xhr ) {
        return res.json({ status_code: res.status, status: "error", err_msg: "Not found" });
    } else {
        const error_layout = (req.session.user && req.session.user.id > 0)? 'layout' : 'login_layout'

        //for the error handler, we need to set the variable in res.locals
        return res.render('errors/404.ejs', {
            pageTitle: `Not Found`,
            error_status: 404,
            layout: error_layout
        });
    } //end if(req.xhr)
});


//error handler
const errorHandler = require('./policies/errorHandler.js')(globals);
app.use(errorHandler);

//apply the router
app.use(router);

//////////////////////////////////////////////////////////////////
// START EXPRESS SERVER
//////////////////////////////////////////////////////////////////

(async () => {
    const port = args.port || 3000;
    try {
        // Start Server
        app.listen(port);
        globals.logger.info(`${process.env.APP_NAME} Server is LIVE on port ${port}`);
    } catch (err) {
        console.error("FATAL ERROR");
        globals.logger.error(`${process.env.APP_NAME}:${port} :: FATAL ERROR :: `, err);
        process.exit(-1)
    }
})();