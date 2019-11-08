class Company {
    constructor(){}
    //company has locations
    //company has customers
    //company has campaigns

}

class CompanyLocation {
    constructor(){}
    //a location has address information
    //a location has timezone information
}

class Campaign {
    constructor(){}
    //campaign has data packets\

    //a campaign should define a data source..?
    //a campaign should have contact methods
    //a campaign should have messages defined
    //a campaign should have a schedule of contact windows.. or now..
    //a campaign should define if confirm, cancel, reschedule options available
    //a campaign should define locations affected (timezone)
}
class Customer {
    constructor(){}
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
    SMS: SMS,
    Email: Email,
    PhoneCall: PhoneCall
}
