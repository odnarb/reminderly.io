console.log('Loading function');

exports.handler = async (event) => {
    // console.log('Received event:', JSON.stringify(event, null, 2));
    event.Records.forEach((msg) => {
        console.log('SQS message: %j', msg);
    });
    return `Successfully processed ${event.Records.length} messages.`;
};