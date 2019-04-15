let r = require('./reminderly.js');

let db_config = {
    host     : '192.168.32.130',
    user     : 'reminderly',
    password : 'Rem!nDerly123!$',
    database : 'reminderly'
};

let twilioCFG = {
    accountKey: 'account_key_here',
    secretKey: 'secret_key_here'
};

let emailCFG = {
    accountSid: 'ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    authToken: 'your_auth_token'
};

//get data from DB
let contacts = 0;
let sms = new r.ReminderlySMS(db_config, twilioCFG);
sms.send(function(err, status){
    // if(err) console.error(err);
    // else console.log(err)
    console.log("Error: ", err);
    console.log("Status: ", status);

    if(contacts == 3){
        console.log('calling sms.db_close()...');
        sms.db_close();
    }
});

let email = new r.ReminderlyEmail(db_config, emailCFG);
email.send(function(err, status){
    // if(err) console.error(err);
    // else console.log(err)
    console.log("Error: ", err);
    console.log("Status: ", status);
    contacts++;
    if(contacts == 3){
        console.log('calling email.db_close()...');
        email.db_close();
    }

});

let phone = new r.ReminderlyPhoneCall(db_config, twilioCFG);
phone.send(function(err, status){
    // if(err) console.error(err);
    // else console.log(err)
    console.log("Error: ", err);
    console.log("Status: ", status);
    contacts++;
    if(contacts == 3){
        console.log('calling phone.db_close()...');
        phone.db_close();
    }
});