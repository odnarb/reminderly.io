/*

We want this layer to be tightly coupled with the DB defintion.
This is where most business logic resides as well as DB operations

Classes have: fields, field validation, and other functions for the lambdas to invoke:

    get(params,cb){}
    getById(params,cb){}
    updateById(params, cb){}
    create(params, cb){}
    removeById(params, cb){}

    In the end, we want objects that are sent via the UI, then API GW, then lambda, then here
    and be able to perform operations such as getting lists, and other atomic-level CRUD operations
    however, those operations need validation as they're going into the DB or being updated

    Also, some objects have a relation to another.. so we need to make sure operations cascade properly.
*/

// 1 -- sms
// 2 -- email
// 3 -- phone
const CONTACT_METHODS = {
  SMS: 1,
  EMAIL: 2,
  PHONE: 3
}

const ACTION_CREATE = 'create'
const ACTION_GET = 'get'
const ACTION_GETBYID = 'get_by_id'
const ACTION_UPDATEBYID = 'update_by_id'
const ACTION_REMOVEBYID = 'remove_by_id'

const DB_PROCS = {
  Company: {
    create: 'createCompany',
    remove_by_id: 'removeCompany',
    update_by_id: 'updateCompany',
    get_by_id: 'getCompany',
    get: 'getCompanies'
  },
  Packet: {
    getBatch: 'getPacketBatch'
  },
  PacketData: {
    get: 'getPacketData'
  }
}

class Reminderly {
  constructor (dbConfig) {
    const mysql = require('mysql')
    this.connection = mysql.createConnection(dbConfig)
    this.connection.connect()
    this.valid = false
  }

  getProcName (action = '') {
    const thisClass = DB_PROCS[this.constructor.name]

    if (!thisClass) {
      throw new Error('Class not recognized.')
    }

    const procName = thisClass[action]

    if (!procName) {
      const err = 'Action `' + action + '` not recognized.'
      throw err
    }
    return procName
  }

  execQuery (action, obj, cb) {
    // for the sql that's going to be executed
    const procName = this.getProcName(action)

    // in case we're dealing with a single id, the obj = { id: 1234 }
    // in case it's some pagination or something, obj looks like = { offset: 10, limit: 100, etc}
    const sqlQuery = `CALL ${procName}('${JSON.stringify(obj)}');`

    console.log('Query being executed: ', sqlQuery)

    this.connection.query(sqlQuery, function (error, res, fields) {
      // drop the connection..? makes sense during a lambda f(x)
      this._connection.destroy()
      if (error) {
        cb(error)
      } else {
        cb(null, res)
      }
    })
  }
}

module.exports.Reminderly = Reminderly

class Packet extends Reminderly {
  getBatch (packet, cb) {
    super.execQuery(ACTION_GET, search, function (err, res) {
      // console.log(res[0]);
      return cb(err, res[0])
    })
  } // end get()
}

module.exports.Packet = Packet

class PacketData extends Reminderly {
  get (opts, cb) {
    super.execQuery(ACTION_GET, opts, function (err, res) {
      return cb(err, res[0])
    })
  } // end get()
}

module.exports.PacketData = PacketData

class Company extends Reminderly {
  create (fields, cb) {
    // `name` VARCHAR(255) NOT NULL DEFAULT '',
    // `alias` VARCHAR(255) NOT NULL DEFAULT '',
    // `details` json NOT NULL,
    // `active` INT NOT NULL,

    // grab our allowed fields
    const company = {
      name: fields.name,
      alias: fields.alias,
      details: fields.details
    }

    const errors = []
    let valid = true

    if (!company.name || company.name === '' || !(typeof company.name === 'string')) {
      errors.push('name must be a string')
      valid = false
    }
    if (!company.alias || company.alias === '' || !(typeof company.alias === 'string')) {
      errors.push('alias must be a string')
      valid = false
    }
    if (!(company.details instanceof Object)) {
      errors.push('details must be an object')
      valid = false
    }
    // console.log("Details in this object: ", this);

    // //company has locations
    // this.locations = details.locations.map((loc) => {new CompanyLocation(loc)});
    // //company has customers
    // this.customers = details.customers.map((cust) => {new Customer(loc)});
    // //company has campaigns
    // this.campaigns = details.campaigns.map((campaign) => {new Campaign(campaign)});

    if (valid) {
      super.execQuery(ACTION_CREATE, company, function (err, res) {
        return cb(err, res)
      })
    } else {
      return cb(errors)
    }
  } // end create()

  remove (fields, cb) {
    if (fields.id === undefined || fields.id < 0) {
      return cb('Object id is undefined')
    }

    // maybe paranoid.. but just safer to re-create the object with a single field..
    const obj = {
      id: fields.id
    }

    super.execQuery(ACTION_REMOVEBYID, obj, function (err, res) {
      return cb(err, res)
    })
  } // end remove()

  getById (fields, cb) {
    if (fields.id === undefined || fields.id < 0) {
      return cb('Object id is undefined')
    }

    // maybe paranoid.. but just safer to re-create the object with a single field..
    const obj = {
      id: fields.id
    }

    super.execQuery(ACTION_GET, obj, function (err, res) {
      return cb(err, res)
    })
  } // end getById()

  get (search, cb) {
    super.execQuery(ACTION_GET, search, function (err, res) {
      // console.log(res[0]);
      return cb(err, res[0])
    })
  } // end get()

  update (fields, cb) {
    const errors = []
    const valid = true

    // build this out.. need to allow/disallow stuff

    if (valid) {
      super.execQuery(ACTION_UPDATEBYID, company, function (err, res) {
        return cb(err, res)
      })
    } else {
      return cb(errors)
    }
  } // end update()
}

module.exports.Company = Company

class Campaign {
  constructor () {
    // a campaign should define a data source..?
    // a campaign should have contact methods
    // a campaign should have messages defined
    // a campaign should have a schedule of contact windows.. or now..
    // a campaign should define if confirm, cancel, reschedule options available
    //   a campaign should define locations affected (timezone)
    //   campaign has data packets?

    // `company_id` INT NOT NULL,
    // `name` VARCHAR(80) NOT NULL DEFAULT '',
    // `description` VARCHAR(255) NOT NULL DEFAULT '',
    // `data` json NOT NULL,
    // FOREIGN KEY (`company_id`) REFERENCES company (`id`),

    // grab our allowed fields
    const { company_id, name, description, data } = fields

    if (!company_id || !(company_id instanceof Number)) {
      throw new Error('company_id must be a number')
    }
    if (!name || name === '' || !(name instanceof String)) {
      throw 'name must be a string'
    }
    if (!description || description === '' || !(description instanceof String)) {
      throw 'description must be a string'
    }
    if (!(data instanceof Object)) {
      throw 'data must be an object'
    }
    this.company_id = company_id
    this.name = name
    this.description = description
    this.data = data
  }
}

module.exports.Campaign = Campaign

class DataPacket {}

module.exports.DataPacket = DataPacket

// semi-constant data
class MessageFunctions {}

module.exports.MessageFunctions = MessageFunctions

// semi-constant data
class ContactMethods {}

module.exports.ContactMethods = ContactMethods

// semi-constant data
class ContactStatus {}

module.exports.ContactStatus = ContactStatus

// semi-constant data
class ContactMethodProviders {}

module.exports.ContactMethodProviders = ContactMethodProviders

// semi-constant data
class DataIngestSource {}

module.exports.DataIngestSource = DataIngestSource

// semi-constant data
class DataIngestStage {}

module.exports.DataIngestStage = DataIngestStage

class Message {
  constructor (db_config, cfg) {
    this.cfg = cfg
  }

  get () {}

  get_connection () {
    const mysql = require('mysql')
    this.connection = mysql.createConnection(db_config)
    this.connection.connect()
    return this.connection
  };

  send () {}

  db_close () {
    console.log('Closing db connection..')
    this.connection.end()
  }
}

module.exports.Message = Message

// Creating a new class from the parent
class SMS extends Message {
  constructor (db_config, cfg) {
    // Chain constructor with super
    super(db_config, cfg)
  }

  get (cb) {
    const connection = this.get_connection()
    const sqlQuery = "CALL GetMessagesReady('sms');"
    connection.query(sqlQuery, function (error, msgs, fields) {
      if (error) return cb(error)
      return cb(null, msgs)
    })
  }

  send (msgs, cb) {
    const connection = this.get_connection()

    msgs.forEach(function (msg) {
      console.log('sending sms: ', msg)
      console.log(this.constructor.name + ': ', msg)
      // twilioClient = require('twilio')(this.cfg.accountSid, this.cfg.authToken);
      // twilioClient.messages
      //   .create(msg)
      //   .then(message =>
      //         console.log(message.sid)
      //     );
      // }

      console.log('Sending message: ', msg)

      const sqlQuery = "CALL SetMessagesProcessed('" + msg.tx_guid; +"');"
      connection.query(sqlQuery, function (error, msg, fields) {
        if (error) cb(error)
        else cb(null, msg)
      })
    })
  }
} // end SMS()

module.exports.SMS = SMS

class PhoneCall extends Message {
  get () {
    const connection = this.get_connection()
    const sqlQuery = "CALL GetMessagesReady('call');"
    connection.query(sqlQuery, function (error, msgs, fields) {
      if (error) return cb(error)
      return cb(null, msgs)
    })
  }

  send (msgs, cb) {
    const connection = this.get_connection()

    msgs.forEach(function (msg) {
      console.log('sending call: ', msg)
      // //use twilio phone
      // twilioClient = require('twilio')(this.cfg.accountSid, this.cfg.authToken);
      // twilioClient.calls
      //   .create({
      //      url: 'http://demo.twilio.com/docs/voice.xml',

      //     <Response>
      //     <script/>
      //     <Say voice="alice">Thanks for trying our documentation. Enjoy!</Say>
      //     <Play>http://demo.twilio.com/docs/classic.mp3</Play>
      //     </Response>

      //      to: msg.to,
      //      from: msg.from
      //    })
      //   .then(call => console.log(call.sid));
      console.log('Sending message: ', msg)

      const sqlQuery = "CALL SetMessagesProcessed('" + msg.tx_guid + "');"
      connection.query(sqlQuery, function (error, msg, fields) {
        if (error) cb(error)
        else cb(null, msg)
      })
    })
  }
} // end PhoneCall()

module.exports.PhoneCall = PhoneCall

class Email extends Message {
  get () {
    const connection = this.get_connection()
    const sqlQuery = "CALL GetMessagesReady('email');"
    connection.query(sqlQuery, function (error, msgs, fields) {
      if (error) return cb(error)
      return cb(null, msgs)
    })
  }

  send (msgs, cb) {
    const connection = this.get_connection()

    msgs.forEach(function (msg) {
      console.log('Email: ', msg)

      const sqlQuery = "CALL SetMessagesProcessed('" + msg.tx_guid + "');"
      connection.query(sqlQuery, function (error, msg, fields) {
        if (error) cb(error)
        else cb(null, msg)
      })
    })

    // use aws ses
    // let AWS = require('aws-sdk');
    // AWS set accessKey & secret: this.cfg.accessKey and this.cfg.secret
    // AWS.config.update({region: 'us-west-2'});
    // let ses = new AWS.SES();

    // // Create sendEmail params
    // let params = {
    //   Destination: { /* required */
    //     ToAddresses: msg.email_address.split(";") //make the string of email address into an array for multiple recipients
    //   },
    //   Message: { /* required */
    //     Body: { /* required */
    //       Html: {
    //        Charset: "UTF-8",
    //        Data: msg.html_body
    //       },
    //       Text: {
    //        Charset: "UTF-8",
    //        Data: msg.text_body
    //       }
    //      },
    //      Subject: {
    //       Charset: 'UTF-8',
    //       Data: msg.subject
    //      }
    //     },
    //   Source: msg.from, /* required */
    //   ReplyToAddresses: [
    //      msg.reply_to
    //   ]
    // };

    // // Create the promise and SES service object
    // let sendPromise = new AWS.SES({apiVersion: '2010-12-01'}).sendEmail(params).promise();

    // // Handle promise's fulfilled/rejected states
    // sendPromise.then(
    //   function(data) {
    //     console.log(data.MessageId);
    //   }).catch(
    //     function(err) {
    //     console.error(err, err.stack);
    //   });
  }
} // end Email

module.exports.Email = Email
