// main route

let express = require('express')
let router = express.Router()

const models = require('../models')

module.exports = (globals) => {
    return router

    .get('/company/:id', async (req, res, next) => {
        let routeHeader = "GET /api/company/:id"

        try {
            const db_res = await globals.models.Company.findByPk(parseInt(req.params.id))

            return res.json({ res: (db_res)? "success": "fail", obj: db_res })
        } catch(err) {
            globals.logger.error(`${routeHeader} :: CAUGHT ERROR`)
            return next(err)
        }
    })

    .post('/company', async (req, res, next) => {
        let routeHeader = "POST /api/company"

        try {
            let obj = {
                name: 'TestCompany',
                alias: 'TestCompany-1234 [Some other name..]',
                details: { custom: "value1" },
                active: 1
            }
            const db_res = await globals.models.Company.create(obj)

            return res.json({ res: db_res })
        } catch(err) {
            globals.logger.error(`${routeHeader} :: CAUGHT ERROR`)
            return next(err)
        }
    })

    .get('/customer/:id', async (req, res, next) => {
        let routeHeader = "GET /api/customer/:id"

        try {
            const db_res = await globals.models.Customer.findByPk(parseInt(req.params.id))

            return res.json({ res: (db_res)? "success": "fail", obj: db_res })
        } catch(err) {
            globals.logger.error(`${routeHeader} :: CAUGHT ERROR`)
            return next(err)
        }
    })

    .post('/customer/:id', async (req, res, next) => {
        let routeHeader = "POST /api/customer"

        try {
            const db_res = await globals.models.Customer.create(req.body.customer)

            return res.json({ res: (db_res)? "success": "fail", obj: db_res })
        } catch(err) {
            globals.logger.error(`${routeHeader} :: CAUGHT ERROR`)
            return next(err)
        }
    })

    .get('/campaign/:id', async (req, res, next) => {
        let routeHeader = "GET /api/campaign/:id"

        try {
            const db_res = await globals.models.Campaign.findByPk(parseInt(req.params.id))

            return res.json({ res: (db_res)? "success": "fail", obj: db_res })
        } catch(err) {
            globals.logger.error(`${routeHeader} :: CAUGHT ERROR`)
            return next(err)
        }
    })

    .put('/campaign/:id', async (req, res, next) => {
        let routeHeader = "PUT /api/campaign"

        try {
            const db_res = await globals.models.Campaign.update(req.body.campaign, { where: { id: req.params.id } })

            return res.json({ res: (db_res)? "success": "fail", obj: db_res })
        } catch(err) {
            globals.logger.error(`${routeHeader} :: CAUGHT ERROR`)
            return next(err)
        }
    })

    .post('/campaign/:id', async (req, res, next) => {
        let routeHeader = "POST /api/campaign"

        try {
            const db_res = await globals.models.Campaign.create(req.body.campaign)

            return res.json({ res: (db_res)? "success": "fail", obj: db_res })
        } catch(err) {
            globals.logger.error(`${routeHeader} :: CAUGHT ERROR`)
            return next(err)
        }
    })

}

