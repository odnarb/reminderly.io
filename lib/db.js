const { Sequelize } = require('sequelize')

function initDb () {
  const db = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
    host: process.env.DB_HOST,
    dialect: 'mysql',
    pool: {
      max: 10,
      min: 1,
      acquire: 30000,
      idle: 10000
    }
  })
  const models = require('../models/init-models')(db)

  return { models, db }
}

module.exports.initDb = initDb

async function rawSelect ({ db, sqlStr, singleResult }) {
  const res = await db.query(sqlStr, { type: db.QueryTypes.SELECT })
  if (singleResult && res && res.length === 1) {
    return res[0]
  } else if (singleResult && !res) {
    return false
  }
  return res
}

module.exports.rawSelect = rawSelect
