// main route

let express = require('express')
let router = express.Router()

const models = require('../models')

module.exports = (globals) => {
    return router

    .get('/company/:id', async (req, res, next) => {
        let routeHeader = "GET /company"

        try {
            const db_res = await globals.models.Company.findByPk(parseInt(req.params.id))

            return res.json({ res: (db_res)? "success": "fail", obj: db_res })
        } catch(err) {
            globals.logger.error(`${routeHeader} :: CAUGHT ERROR`)
            return next(err)
        }
    })

    .post('/company', async (req, res, next) => {
        let routeHeader = "POST /company"

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
        let routeHeader = "GET /"

        try {
            const db_res = await globals.models.Customer.findByPk(parseInt(req.params.id))

            return res.json({ res: (db_res)? "success": "fail", obj: db_res })
        } catch(err) {
            globals.logger.error(`${routeHeader} :: CAUGHT ERROR`)
            return next(err)
        }
    })

    .post('/customer', async (req, res, next) => {
        let routeHeader = "POST /customer"

        try {
            let obj = {
                name: 'Dr. Phillips',
                company_id: 1,
                details: { custom: "value1" },
                active: 1
            }
            const db_res = await globals.models.Customer.create(obj)

            return res.json({ res: db_res })
        } catch(err) {
            globals.logger.error(`${routeHeader} :: CAUGHT ERROR`)
            return next(err)
        }
    })
}

