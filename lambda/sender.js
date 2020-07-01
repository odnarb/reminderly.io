console.log('Loading function...');

const db_config = {
    host     : '192.168.32.130',
    user     : 'reminderly',
    password : 'Rem!nDerly123!$',
    database : 'reminderly'
};

const twilioCFG = {
    accountKey: 'account_key_here',
    secretKey: 'secret_key_here'
};

const emailCFG = {
    accountSid: 'ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    authToken: 'your_auth_token'
};

let r = require('./reminderly.js');
let senderCB = function(err, status){
    console.log("Error: ", err);
    console.log("Status: ", status);
    contacts++;
    if(contacts == 3){
        console.log('calling phone.db_close()...');
        phone.db_close();
    }
};

exports.handler = async (event) => {
    // console.log('Received event:', JSON.stringify(event, null, 2));
    event.Records.forEach((msg) => {
        console.log('SQS message: %j', msg);

        //choose HOW to send the message
        switch(msg.contact_method) {
            case r.CONTACT_METHODS.SMS:
                let sms = new r.SMS(twilioCFG);
                sms.send(msg, senderCB);
                break;
            case r.CONTACT_METHODS.EMAIL:
                let email = new r.Email(emailCFG);
                email.send(msg, senderCB);
                break;
            case r.CONTACT_METHODS.PHONE:
                let phone = new r.PhoneCall(twilioCFG);
                phone.send(msg, senderCB);
                break;
            default:
                console.log("No sender qualified for msg: ", msg);
        };
    });
    return `Successfully processed ${event.Records.length} messages.`;
};
