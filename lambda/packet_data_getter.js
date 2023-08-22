process.env.email_queue_url = 'https://sqs.us-west-2.amazonaws.com/699486157734/reminderly_email_queue_1'
process.env.phone_queue_url = 'https://sqs.us-west-2.amazonaws.com/699486157734/reminderly_phone_queue_1'
process.env.sms_queue_url = 'https://sqs.us-west-2.amazonaws.com/699486157734/reminderly_sms_queue_1'
process.env.packet_table_name = 'packet_1337_07022020_1_data'
process.env.db_host = 'reminderly.c3tweep3ixcv.us-west-2.rds.amazonaws.com'
process.env.db_user = 'reminderly'
process.env.db_password = 'Rem!nDerly123!$'
process.env.db_name = 'reminderly'
process.env.packet_size_limit = 1000
process.env.sqs_batch_limit = 10

const mysql = require('mysql')

// this part merely sends some content to a queue
const AWS = require('aws-sdk')
AWS.config.update({ region: 'us-west-2' })

const sqs = new AWS.SQS({ apiVersion: '2012-11-05' })

// reminderly - get data from packets
const get_connection = function () {
  return mysql.createConnection({
    host: process.env.db_host,
    user: process.env.db_user,
    password: process.env.db_password,
    database: process.env.db_name
  })
}

// assume no pagination needed
let need_to_paginate = false
let num_pages = 1

// async DOES NOT WORK with mysql for some reason... UGH
exports.handler = (event, context, callback) => {
  console.log('---Loading GETTER function...')

  const param = {
    packet_table_name: process.env.packet_table_name
  }
  const query = "CALL getPacketData('" + JSON.stringify(param) + "');"

  console.log('---query to be executed: ', query)

  const connection = get_connection()

  console.log('---EXEC QUERY')

  connection.query(query, function (error, results, fields) {
    if (error) {
      console.log('---DB ERROR!')
      connection.destroy()
      return callback(error)
    }
    console.log('---got DB results: ', results)

    const total_row_count = results[0][0].total_row_count
    const msgs = results[1]

    // TODO: complete pagination logic
    if (msgs.count < total_row_count) {
      need_to_paginate = true
      num_pages = Match.ceil(total_row_count / packet_size_limit)
    }

    let batchesComplete = 0
    const totalBatches = Math.ceil(msgs.length / process.env.sqs_batch_limit)

    // loop and create a new array for batching
    let batch = []
    let i = 1
    while (msgs.length > 0) {
      // console.log("---Process msg for batch");
      const msg = msgs.pop()

      // format for sqs.sendMessageBatch()
      const sqsMsg = {
        Id: msg.id + '',
        MessageBody: JSON.stringify(msg)
      }

      // add to the batch
      batch.push(sqsMsg)

      if ((i % process.env.sqs_batch_limit == 0) || msgs.length == 0) {
        console.log('---batch size: ', batch.length)
        const message = {
          QueueUrl: process.env.queue_url,
          Entries: batch
        }

        console.log('---BEFORE SQS SEND')
        sqs.sendMessageBatch(message, function () {
          console.log('---AFTER SQS SEND')

          batchesComplete++

          console.log('---batchesComplete: ' + batchesComplete + ' :: totalBatches: ' + totalBatches)
          if (batchesComplete == totalBatches) {
            connection.end(function () {
              return callback(null, 'batches complete')
            })
          }
        })
        // reset
        batch = []
      } // endif

      // continue the loop
      i++
    } // end while()
  }) // end connection.query()
}
