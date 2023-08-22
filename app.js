/*
* Server for dashboard app
*/

// get the args starting at position 2 (node app.js --port 3000)
const args = require('minimist')(process.argv.slice(2))

// load env vars from .env file
require('dotenv').config()

const express = require('express')
const bodyParser = require('body-parser')
const cookieParser = require('cookie-parser')
const favicon = require('serve-favicon')
const path = require('path')
const compression = require('compression')
const expressLayouts = require('express-ejs-layouts')

// TODO: get helmet and cors working
// const cors = require('cors')
// const helmet = require('helmet')

const { logger } = require('./lib/logger')
const { initDb } = require('./lib/db')

// get db and models instances
const sql = initDb()

const {
  APP_FOLDERS,
  makeAppDirs
} = require('./lib/globals')

const app = express()
const router = express.Router()

/// ///////////////////////////////////////////////////////////////
// EXPRESS SETUP
/// ///////////////////////////////////////////////////////////////

// sessions
const sessions = require('./lib/sessions')
sessions(app)

/// /////////////////////////////////////////
/// /    EXPRESS MIDDLEWARE & OPTIONS    ////
/// /////////////////////////////////////////

// enable gzip compression
app.use(compression())

// disable powered by header
app.disable('x-powered-by')

// nth proxy hop to treat as real request origin
app.set('trust proxy', 1)

// set the view engine to ejs
app.use(expressLayouts)
app.set('view engine', 'ejs')
app.set('layout', './layout.ejs')

// where are the static assets?
// I've tested this and if an asset exists, the file is served directly
// without any policies being applied, but if it does not, the asset request
// flows next through the policy chain and routes
// but if I set fallthrough: false, it'll handle ALL requests first as a static asset first, and attempt to find /public/users/login as a static asset
app.use(express.static('public'))
app.use(express.static(APP_FOLDERS.baseDataDir))

// set the favicon
app.use(favicon(path.join(__dirname, 'public', process.env.APP_FAVICON)))

// Ensures that the content-type for SNS messages
app.use(function (req, res, next) {
  if (req.get('x-amz-sns-message-type')) {
    req.headers['content-type'] = 'application/json' // IMPORTANT, otherwise content-type is text for topic confirmation reponse, and body is empty
  }
  next()
})

app.use(bodyParser.json({ limit: '25mb' })) // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })) // support encoded bodies

app.use(cookieParser())

// apply our router function to ALL methods defined in router
const mainPolicy = require('./policies/main')()
app.use(mainPolicy)

const analyticsPolicy = require('./policies/analytics')({ UserAnalytics: sql.models.UserAnalytics })
app.use(analyticsPolicy)

/// /////////////////////////////////////////////////////
// APP ROUTER
/// /////////////////////////////////////////////////////

const routeApi = require('./routes/api.js')({ models: sql.models })
app.use('/api', routeApi)

// const user = require('./routes/user.js')(globals);
// app.use('/user', user)

// const companies = require('./routes/companies.js')(globals);
// app.use('/companies', companies)

// const campaigns = require('./routes/campaigns.js')(globals);
// app.use('/campaigns', campaigns)

// handle 404's
app.use((req, res, next) => {
  res.statusCode = 404
  return next(`404 NOT FOUND :: url: ${req.method} ${req.url}`)
})

// error handler
const errorHandler = require('./policies/errorHandler')()
app.use(errorHandler)

// Override the render function to set local variables, final access/permissions, etc
express.response.render = require('./policies/renderOverride')(express.response.render)

// apply the router
app.use(router)

/// ///////////////////////////////////////////////////////////////
// START EXPRESS SERVER
/// ///////////////////////////////////////////////////////////////

async function mainApp () {
  // setup data, temp, and septic paths:
  try {
    await makeAppDirs()
  } catch (err) {
    console.log(err.stack)
    process.exit(-1)
  }

  // Start Server
  const port = args.port || 3000

  app.listen(port)
  logger.info(`${process.env.APP_NAME} Server is LIVE on port ${port}`)
}
mainApp()
