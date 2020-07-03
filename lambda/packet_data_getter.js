//reminderly - get data from packets

console.log('Loading GETTER function...');

process.env.queue_url = 'https://sqs.us-west-2.amazonaws.com/699486157734/reminderly_email_queue_1'
process.env.packet_table_name = 'packet_1337_07022020_1_data';
process.env.db_host = 'localhost';
process.env.db_user = 'reminderly';
process.env.db_password = 'Rem!nDerly123!$';;
process.env.db_name = 'reminderly';
process.env.packet_size_limit = 1000;
process.env.sqs_batch_limit = 10;

//this part merely sends some content to a queue
let AWS = require('aws-sdk');
AWS.config.update({region: 'us-west-2'});

let sqs = new AWS.SQS({apiVersion: '2012-11-05'});


let sendSQS = function(batch){
    let message = {
        MessageBody: JSON.stringify(batch),
        QueueUrl: process.env.queue_url
    };

    try {
        await sqs.sendMessageBatch(message).promise();
        console.log("Success, message batch sent");
        return { result: "Success"};
    } catch (err){
        console.log('error:',"Fail Send Message" + err);
        return context.done('error', "ERROR Put SQS");  // ERROR with message
    }
};

exports.handler = async (event) => {

    let r = require('../reminderly.js');

    let packetData = new r.PacketData({
        host     : process.env.db_host,
        user     : process.env.db_user,
        password : process.env.db_password,
        database : process.env.db_name
    });

    let opts = {
        packet_table_name: process.env.packet_table_name,
        limit: packet_size_limit
    };

    packetData.get(opts, function(err, msgs){
        if(err){
            console.log("Error: ", err);
        } else {
            //console.log("res: ", res);
            //sendMessageBatch can send up to 10 per loop

            //loop and create a new array for batching
            let batch = [];
            for(let i=msgs.length; i > 0; i--){
                let msg = msgs.pop();
                batch.push(msg);

                if( i < msgs.length && i%process.env.sqs_batch_limit == 0 ){
                    sendSQS(batch);
                    batch = [];
                }
            }
        }
    });
};
