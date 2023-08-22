// main route

const express = require('express')
const { logger } = require('../lib/logger')
const router = express.Router()

module.exports = ({ models }) => {
  return router

    .get('/company/:id', async (req, res, next) => {
      try {
        const company = await models.Company.findByPk(parseInt(req.params.id))

        return res.json({ res: (company) ? 'success' : 'fail', obj: company })
      } catch (err) {
        logger.error(`Could not get company: ${err.stack}`)
        return next(err)
      }
    })

    .post('/company', async (req, res, next) => {
      try {
        const obj = {
          name: 'TestCompany',
          alias: 'TestCompany-1234 [Some other name..]',
          details: { custom: 'value1' },
          active: 1
        }
        const company = await models.Company.create(obj)

        return res.json({ res: company })
      } catch (err) {
        logger.error(`Could not create company: ${err.stack}`)
        return next(err)
      }
    })

    .get('/customer/:id', async (req, res, next) => {
      try {
        const customer = await models.Customer.findByPk(parseInt(req.params.id))

        return res.json({ res: (customer) ? 'success' : 'fail', obj: customer })
      } catch (err) {
        logger.error(`Could not get customer: ${err.stack}`)
        return next(err)
      }
    })

    .post('/customer/:id', async (req, res, next) => {
      try {
        const customer = await models.Customer.create(req.body.customer)

        return res.json({ res: (customer) ? 'success' : 'fail', obj: customer })
      } catch (err) {
        logger.error(`Could not create customer: ${err.stack}`)
        return next(err)
      }
    })

    .get('/campaign/:id', async (req, res, next) => {
      try {
        const campaign = await models.Campaign.findByPk(parseInt(req.params.id))

        return res.json({ res: (campaign) ? 'success' : 'fail', obj: campaign })
      } catch (err) {
        logger.error(`Could not get campaign: ${err.stack}`)
        return next(err)
      }
    })

    .put('/campaign/:id', async (req, res, next) => {
      try {
        const campaign = await models.Campaign.update(req.body.campaign, { where: { id: req.params.id } })

        return res.json({ res: (campaign) ? 'success' : 'fail', obj: campaign })
      } catch (err) {
        logger.error(`Could not update campaign: ${err.stack}`)
        return next(err)
      }
    })

    .post('/campaign/:id', async (req, res, next) => {
      try {
        const campaign = await models.Campaign.create(req.body.campaign)

        return res.json({ res: (campaign) ? 'success' : 'fail', obj: campaign })
      } catch (err) {
        logger.error(`Could not create campaign: ${err.stack}`)
        return next(err)
      }
    })
}
