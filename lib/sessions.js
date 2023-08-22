const uuid = require('uuid')
const session = require('express-session')

const logger = require('./logger')

const sessionSecret = 'as7890dfg980bvcxb8v9c0-890sdaf9sdf890zx890-00230430-2392390490854890890ds9as908u0ftgdf'

function sessions (app) {
  let sessionStore
  if (process.env.LOCAL === 'true') {
    const NeDbStore = require('nedb-session-store')(session)
    sessionStore = new NeDbStore({ filename: 'local-session-store.db' })
  } else {
  // setup redis
    const redis = require('redis')
    const RedisStore = require('connect-redis')(session)
    const redisClient = redis.createClient(process.env.REDIS_PORT, process.env.REDIS_HOST)

    sessionStore = new RedisStore({
      host: process.env.REDIS_HOST,
      port: process.env.REDIS_PORT,
      client: redisClient
    // ttl: process.env.REDIS_TTL
    })

    redisClient.on('error', (err) => {
      logger.error('Redis error: ', err)
      logger.error('Terminating process...')
      process.exit(-1)
    })
  }

  // setup session
  app.use(session({
    genid: (req) => {
      return uuid.v4()
    },
    // always use a secure secret, not something committed to the repo
    secret: `${sessionSecret}`,

    // i.e. "sess_foobar" is the cookie name
    name: `_${process.env.APP_NAME.toLowerCase()}`,

    // probably a good thing to set to true for PROD
    resave: false,

    // reset the countdown for maxAge
    rolling: true,

    // probably leave to true
    saveUninitialized: true,
    cookie: {
      secure: false, // this should be set to true for SSL
      // d * h * m * s * ms
      maxAge: 7 * 24 * 60 * 60 * 1000
    },
    store: sessionStore
  }))
}

module.exports = sessions
