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

const ACTION_CREATE = "create";
const ACTION_GET = "get";
const ACTION_GETBYID = "get_by_id";
const ACTION_UPDATEBYID = "update_by_id";
const ACTION_REMOVEBYID = "remove_by_id";

const DB_PROCS = {
    "Company": {
        "create": "createCompany",
        "remove_by_id": "removeCompany"
    }
}

class Reminderly {

    constructor(db_config) {
        let mysql = require('mysql');
        this.connection = mysql.createConnection(db_config);
        this.connection.connect();
        this.valid = false;
    }

    getProcName(action="") {
        let thisClass = DB_PROCS[this.constructor.name];

        if(!thisClass) {
            throw "Class not recognized.";
        }

        let procName = thisClass[action];

        if(!procName) {
            let err = "Action `"+action+"` not recognized.";
            throw err;
        }
        return procName;
    }

    execQuery(action, obj, cb){

        //for the sql that's going to be executed
        let procName = this.getProcName(action);

        //in case we're dealing with a single id, the obj = { id: 1234 }
        //in case it's some pagination or something, obj looks like = { offset: 10, limit: 100, etc}
        let sqlQuery = `CALL ${procName}('${JSON.stringify(obj)}');`;

        console.log("Query being executed: ", sqlQuery);

        this.connection.query(sqlQuery, function (error, res, fields) {
            //drop the connection..? makes sense during a lambda f(x)
            this._connection.destroy();
            if(error) {
                cb(error);
            } else {
                cb(null,res);
            }
        });
    }
}

class Company extends Reminderly {
    constructor(db_config) {
        // Chain constructor with super
        super(db_config);
    }

    create(fields, cb) {
        // `name` VARCHAR(255) NOT NULL DEFAULT '',
        // `alias` VARCHAR(255) NOT NULL DEFAULT '',
        // `details` json NOT NULL,
        // `active` INT NOT NULL,

        //grab our allowed fields
        let company = {
            name: fields.name,
            alias: fields.alias,
            details: fields.details
        };

        let errors = [];
        let valid = true;

        if( !company.name || company.name === "" || !(typeof company.name === "string") ) {
            errors.push("name must be a string");
            valid = false;
        }
        if( !company.alias || company.alias === "" || !(typeof company.alias === "string") ) {
            errors.push("alias must be a string");
            valid = false;
        }
        if( !(company.details instanceof Object) ) {
            errors.push("details must be an object");
            valid = false;
        }
        // console.log("Details in this object: ", this);

        // //company has locations
        // this.locations = details.locations.map((loc) => {new CompanyLocation(loc)});
        // //company has customers
        // this.customers = details.customers.map((cust) => {new Customer(loc)});
        // //company has campaigns
        // this.campaigns = details.campaigns.map((campaign) => {new Campaign(campaign)});

        if( valid ) {
            super.execQuery(ACTION_CREATE, company, function(err,res){
                return cb(err,res);
            });
        } else {
            return cb(errors);
        }
    } //end create()

    remove(obj, cb){
        if( obj.id == undefined || obj.id < 0 ) {
            return cb("Object id is undefined");
        }

        super.execQuery(ACTION_REMOVEBYID, obj, function(err,res){
            return cb(err,res);
        });
    } //end remove()
}


class CompanyLocation {
    constructor(){
        // `company_id` INT NOT NULL,
        // `name` VARCHAR(80) NOT NULL DEFAULT '',
        // `address_1` VARCHAR(80) NOT NULL DEFAULT '',
        // `address_2` VARCHAR(80) NOT NULL DEFAULT '',
        // `city` VARCHAR(80) NOT NULL DEFAULT '',
        // `state` VARCHAR(80) NOT NULL DEFAULT '',
        // `zip` VARCHAR(20) NOT NULL DEFAULT '',
        // `timezone` VARCHAR(80) NOT NULL DEFAULT '',

        //grab our allowed fields
        let { company_id, name, address_1, address_2, city, state, zip, timezone } = fields;

        if( !company_id || !(company_id instanceof Number) ) {
            throw "company_id must be a number";
        }
        if( !name || name === "" || !(name instanceof String) ) {
            throw "name must be a string";
        }
        if( !address_1 || address_1 === "" || !(address_1 instanceof String) ) {
            throw "address_1 must be a string";
        }
        if( !address_2 || address_2 === "" || !(address_2 instanceof String) ) {
            throw "address_2 must be a string";
        }
        if( !city || city === "" || !(city instanceof String) ) {
            throw "city must be a string";
        }
        if( !state || state === "" || !(state instanceof String) ) {
            throw "state must be a string";
        }
        if( !zip || zip === "" || !(zip instanceof Number) ) {
            throw "zip must be a number";
        }
        if( !timezone || timezone === "" || !(timezone instanceof String) ) {
            throw "timezone must be a string";
        }

        this.company_id = company_id;
        this.name = name;
        this.address_1 = address_1;
        this.address_2 = address_2;
        this.city = city;
        this.state = state;
        this.zip = zip;
        this.timezone = timezone;
    }
}

class Campaign {
    constructor(){

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


        //grab our allowed fields
        let { company_id, name, description, data } = fields;

        if( !company_id || !(company_id instanceof Number) ) {
            throw "company_id must be a number";
        }
        if( !name || name === "" || !(name instanceof String) ) {
            throw "name must be a string";
        }
        if( !description || description === "" || !(description instanceof String) ) {
            throw "description must be a string";
        }
        if( !(data instanceof Object) ) {
            throw "data must be an object";
        }
        this.company_id = company_id;
        this.name = name;
        this.description = description;
        this.data = data;
    }
}

class Customer {
    constructor(){
        // `name` VARCHAR(255) NOT NULL DEFAULT '',
        // `company_id` INT NOT NULL,
        // `details` json NOT NULL,
        // `active` INT NOT NULL,
        // FOREIGN KEY (`company_id`) REFERENCES company (`id`),

        //grab our allowed fields
        let { company_id, name, details } = fields;

        if( !company_id || !(company_id instanceof Number) ) {
            throw "company_id must be a number";
        }
        if( !name || name === "" || !(name instanceof String) ) {
            throw "name must be a string";
        }
        if( !(details instanceof Object) ) {
            throw "details must be an object";
        }
        this.company_id = company_id;
        this.name = name;
        this.details = details;
    }
}

class User {
    constructor(){}
    //user has passwords
    //user has roles
}
class Role {
    constructor(){}
    //role has policies
}
class Policy {
    constructor(){}
}
class CompanyLoadMap{
    constructor(){}
}
class DataPacket{
    constructor(){}
}

//semi-constant data
class MessageFunctions {
    constructor(){}
}

//semi-constant data
class ContactMethods {
    constructor(){}
}

//semi-constant data
class ContactStatus {
    constructor(){}
}

//semi-constant data
class ContactMethodProviders {
    constructor(){}
}

//semi-constant data
class DataIngestSource {
    constructor(){}
}

//semi-constant data
class DataIngestStage {
    constructor(){}
}

class Message {
    constructor(db_config, cfg) {
        this.cfg = cfg;
        let mysql = require('mysql');
        this.connection = mysql.createConnection(db_config);
        this.connection.connect();
    }

    send(){}

    get_connection(){ return this.connection };

    db_close(){
        console.log("Closing db connection..");
        this.connection.end();
    }
}

// Creating a new class from the parent
class SMS extends Message {
    constructor(db_config, cfg) {
        // Chain constructor with super
        super(db_config, cfg);
    }

    send(cb){
        let connection = this.get_connection();
        let sqlQuery = "CALL GetMessagesReady('sms');";
        connection.query(sqlQuery, function (error, msgs, fields) {
            if(error) cb(error);
            else if( msgs.length == 0) {
                cb(null,'nothing to process..');
            } else {
                msgs.forEach(function(msg){
                    console.log("sending sms: ", msg);
                    // console.log(this.constructor.name + ": ", msg);
                    // twilioClient = require('twilio')(this.cfg.accountSid, this.cfg.authToken);
                    // twilioClient.messages
                    //   .create(msg)
                    //   .then(message => console.log(message.sid));
                    // }
                });

                let tx_guid = msgs[0].tx_guid;
                let sqlQuery = "CALL SetMessagesProcessed('"+tx_guid+"');";
                connection.query(sqlQuery, function (error, msgs, fields) {
                    if(error) cb(error);
                    else cb(null,'success!: sms');
                });
            }
         });

    }
} //end SMS()

class PhoneCall extends Message {
    constructor(db_config, cfg) {
        // Chain constructor with super
        super(db_config, cfg);
    }

    send(cb){
        let connection = this.get_connection();
        let sqlQuery = "CALL GetMessagesReady('call');";
        connection.query(sqlQuery, function (error, msgs, fields) {
            if(error) cb(error);
            else if( msgs.length == 0){
                cb(null,'nothing to process..');
            } else {
                msgs.forEach(function(msg){
                    console.log("sending call: ", msg);
                    // //use twilio phone
                    //twilioClient = require('twilio')(this.cfg.accountSid, this.cfg.authToken);
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
                });

                let tx_guid = msgs[0].tx_guid;
                let sqlQuery = "CALL SetMessagesProcessed('"+tx_guid+"');";
                connection.query(sqlQuery, function (error, msgs, fields) {
                    if(error) cb(error);
                    else cb(null,'success!: call');
                });
            } //endif
        });
    }
} //end PhoneCall()

class Email extends Message {
    constructor(db_config, cfg) {
        // Chain constructor with super
        super(db_config, cfg);
    }

    send(cb){
        let connection = this.get_connection();
        let sqlQuery = "CALL GetMessagesReady('email');";
        connection.query(sqlQuery, function (error, msgs, fields) {
            if(error) cb(error);
            else if( msgs.length == 0){
                cb(null,'nothing to process..');
            } else {
                msgs.forEach(function(msg){
                    console.log("Email: ", msg);
                });

                let tx_guid = msgs[0].tx_guid;
                let sqlQuery = "CALL SetMessagesProcessed('"+tx_guid+"');";
                connection.query(sqlQuery, function (error, msgs, fields) {
                    if(error) cb(error);
                    else cb(null,'success!: email');
                });
            }
        });
        //use aws ses
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
} //end Email

module.exports = {
    Company: Company,
    SMS: SMS,
    Email: Email,
    PhoneCall: PhoneCall
}
