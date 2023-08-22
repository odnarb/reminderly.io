console.log('Loading function...')

exports.handler = async (event) => {
  const AWS = require('aws-sdk')
  AWS.config.update({ region: 'us-west-1' })
  const sqs = new AWS.SQS()

  console.log(sqs)

  console.log('Received event:', JSON.stringify(event, null, 2))

  // batch send allows to send to a single queue url
  /*
    let emailQueue = "https://sqs.us-west-1.amazonaws.com/699486157734/email";
    let smsQueue = "https://sqs.us-west-1.amazonaws.com/699486157734/sms";
    let phoneQueue = "https://sqs.us-west-1.amazonaws.com/699486157734/phone";
    let generalQueue = "https://sqs.us-west-1.amazonaws.com/699486157734/general";
*/

  // get data from DB
  const messages = {
    QueueUrl: event.queue_url,
    Entries: [{
      Id: 'ffdfdsafdsf8-fdsfdsfds-1', // make up some uuid value
      MessageBody: JSON.stringify({
        phone_number: '(123) 123-1234',
        body: 'This is a test phone call',
        contact_method: 'phone'
      })
    },
    {
      Id: 'ffdfdsafdsf8-fdsfdsfds-2', // make up some uuid value
      MessageBody: JSON.stringify({
        phone_number: '(123) 123-1234',
        body: 'This is a test sms',
        contact_method: 'sms'
      })
    },
    {
      Id: 'ffdfdsafdsf8-fdsfdsfds-3', // make up some uuid value
      MessageBody: JSON.stringify({
        email_address: 'john.doe@gmail.com',
        body: 'This is a test',
        contact_method: 'email'
      })
    },
    {
      Id: 'ffdfdsafdsf8-fdsfdsfds-4', // make up some uuid value
      MessageBody: JSON.stringify({
        email_address: 'john.doe@gmail.com',
        body: 'This is a general account alert',
        contact_method: 'general'
      })
    }]
  }
  console.log('Sending msgs..')
  console.log('messaging: ', messages)

  sqs.sendMessageBatch(messages, function (err, data) {
    if (err) {
      console.log('ERROR OCCURRED: ', err, err.stack) // an error occurred
    } else {
      console.log('Done sending message: ', data)
    }
    // return `Successfully processed ${messages.length} messages.`;
  })
}

/*
console.log('Loading function...');

exports.handler = async (event) => {
    var AWS = require('aws-sdk');
    AWS.config.update({region: 'us-west-1'});
    var sqs = new AWS.SQS();

    console.log("Sending messages..");

   // Flood SQS Queue
    for (let i=0; i < 10; i++) {
        await sqs.sendMessageBatch({
            Entries: flooder(),
            QueueUrl: event.queue_url
        }).promise()
    }
    return 'done'
}

const flooder = () => {
  let entries = []

  for (let i=0; i<10; i++) {
      entries.push({
        Id: 'id'+parseInt(Math.random()*1000000),
        MessageBody: 'value'+Math.random()
      })
  }
  return entries
};
*/
