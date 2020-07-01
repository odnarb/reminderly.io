console.log('Loading GETTER function...');

const db_config = {
    host     : '192.168.32.130',
    user     : 'reminderly',
    password : 'Rem!nDerly123!$',
    database : 'reminderly'
};

let r = require('../reminderly.js');
let getterCB = function(err, status){
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
    let packet_id = event.packet_id;
        console.log('PACKET ID TO PROCESS: %j', packet_id);

    //get data for packet_id
    return `Successfully processed packet messages.`;
};
