exports.handler = (event, context, callback) => {
  // this part merely sends some content to a queue
  const AWS = require('aws-sdk')
  AWS.config.update({ region: 'us-west-2' })

  const sqs = new AWS.SQS({ apiVersion: '2012-11-05' })

  const msg = {
    id: 1,
    first_name: 'John',
    last_name: 'Smith',
    phone_number: '(123) 123-1234'
  }

  const sqsMsgArr = [
    {
      Id: '1',
      MessageBody: JSON.stringify(msg)
    },
    {
      Id: '2',
      MessageBody: JSON.stringify(msg)
    },
    {
      Id: '3',
      MessageBody: JSON.stringify(msg)
    },
    {
      Id: '4',
      MessageBody: JSON.stringify(msg)
    },
    {
      Id: '5',
      MessageBody: JSON.stringify(msg)
    }
  ]

  const sqsBatch = {
    QueueUrl: 'https://sqs.us-west-2.amazonaws.com/699486157734/reminderly_email_queue_1',
    Entries: sqsMsgArr
  }

  try {
    sqs.sendMessageBatch(sqsBatch, function () {
      console.log('Success, message sent')
      callback(null, { result: 'Success' })
    })
  } catch (err) {
    console.log('error:', 'Fail Send Message' + err)
    callback({ result: 'ERROR Put SQS' }) // ERROR with message
  }
}
