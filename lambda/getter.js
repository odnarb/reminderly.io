//reminderly - get data from packets

//TODO: create poc part to get data packets from reminderly programmable API (and DB)

console.log('Loading GETTER function...');

const db_config = {
    host     : '192.168.152.128',
    user     : 'reminderly',
    password : 'Rem!nDerly123!$',
    database : 'reminderly'
};

let r = require('../reminderly.js');

let packetData = new r.PacketData(db_config);

let opts = {
    packet_table_name: 'packet_1337_07022020_1_data'
};

packetData.get(opts, function(err, res){
    console.log("Error: ", err);
    console.log("res: ", res);
});

exports.handler = async (event) => {

    //this part merely sends some content to a queue
    let AWS = require('aws-sdk');
    AWS.config.update({region: 'us-west-2'});

    let sqs = new AWS.SQS({apiVersion: '2012-11-05'});
    let queueUrl = 'https://sqs.us-west-2.amazonaws.com/699486157734/reminderly_email_queue_1';

    let msgObj = {
        id: 123,
        packet_id: 123,
        packet_table_name: "packet_1337_07012020_1_data",
        data: { attr1: "test246" }
    };

    let message = {
        MessageBody: JSON.stringify(msgObj),
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
