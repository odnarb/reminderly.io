const r = require('./reminderly.js')

const db_config = {
  host: '192.168.32.130',
  user: 'reminderly',
  password: 'Rem!nDerly123!$',
  database: 'reminderly'
}

const twilioCFG = {
  accountKey: 'account_key_here',
  secretKey: 'secret_key_here'
}

const emailCFG = {
  accountSid: 'ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  authToken: 'your_auth_token'
}

// we should create a CloudWatch Event (cron) to poll the db every x mins
// then grab msgs from db, and put into a queue
// then create another lambda for polling from queue and send using whatever scheme necessary

// get data from DB
let contacts = 0
const sms = new r.SMS(db_config, twilioCFG)
sms.send(function (err, status) {
  // if(err) console.error(err);
  // else console.log(err)
  console.log('Error: ', err)
  console.log('Status: ', status)

  if (contacts == 3) {
    console.log('calling sms.db_close()...')
    sms.db_close()
  }
})

const email = new r.Email(db_config, emailCFG)
email.send(function (err, status) {
  // if(err) console.error(err);
  // else console.log(err)
  console.log('Error: ', err)
  console.log('Status: ', status)
  contacts++
  if (contacts == 3) {
    console.log('calling email.db_close()...')
    email.db_close()
  }
})

const phone = new r.PhoneCall(db_config, twilioCFG)
phone.send(function (err, status) {
  // if(err) console.error(err);
  // else console.log(err)
  console.log('Error: ', err)
  console.log('Status: ', status)
  contacts++
  if (contacts == 3) {
    console.log('calling phone.db_close()...')
    phone.db_close()
  }
})
