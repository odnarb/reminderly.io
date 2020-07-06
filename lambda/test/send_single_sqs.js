exports.handler = async (event) => {

    //this part merely sends some content to a queue
    let AWS = require('aws-sdk');
    AWS.config.update({region: 'us-west-2'});

    let sqs = new AWS.SQS({apiVersion: '2012-11-05'});
    let queueUrl = 'https://sqs.us-west-2.amazonaws.com/699486157734/reminderly_email_queue_1';

    let msg = {
        id: 1,
        first_name: "John",
        last_name: "Smith",
        phone_number: "(123) 123-1234"
    };

    let message = {
        MessageBody: JSON.stringify(msg),
        QueueUrl: queueUrl
    };

    try {
        await sqs.sendMessage(message).promise();
        console.log("Success, message sent");
        return { result: "Success"};
    } catch (err){
        console.log('error:',"Fail Send Message" + err);
        return context.done('error', "ERROR Put SQS");  // ERROR with message
    }
};