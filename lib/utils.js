const path = require('path')
const fs = require('fs/promises')
const mailer = require('nodemailer')
const aws = require('aws-sdk')
const xlsx = require('xlsx')

const { logger } = require('./logger')

const { fileExists, APP_FOLDERS } = require('./globals')

function loginPageRequest (url) {
  return (
    url.includes('/users/check-email-unique') ||
    url.includes('/users/confirm') ||
    url.includes('/users/signup') ||
    url.includes('/users/logout') ||
    url.includes('/users/newpassword') ||
    url.includes('/users/forgotpassword') ||
    url.includes('/users/login')
  )
}

module.exports.loginPageRequest = loginPageRequest

function adminPageRequest (url) { return url.includes('/admin/') }

module.exports.adminPageRequest = adminPageRequest

function allowPassThruRequest (url) {
  return (
    url.includes('/email/delivery') ||
    url.includes('/email/bounce') ||
    url.includes('/email/complaint') ||
    url.includes('/email/unsubscribe')
  )
}

module.exports.allowPassThruRequest = allowPassThruRequest

function escapeHtml (rawStr) {
  if (rawStr === '') return rawStr
  return rawStr
    .replace(/'/g, '&#39;')
    .replace(/"/g, '&#34;')
    .replace(/`/g, '&#96;')
}

module.exports.escapeHtml = escapeHtml

function decodeHtml (codedStr) {
  if (codedStr === '') return codedStr
  return codedStr
    .replace(/&#39;/g, "'")
    .replace(/&#34;/g, '"')
    .replace(/&#96;/g, '`')
}

module.exports.decodeHtml = decodeHtml

function stringifyOrEmpty (i) {
  if (i === '') return ''
  let newStr = JSON.stringify(i)
  newStr = newStr.replace(/'/g, "''")
  return newStr
}

module.exports.stringifyOrEmpty = stringifyOrEmpty

async function sendEmail (email) {
  try {
    if (process.env.NODE_ENV === 'DEVELOPMENT') {
      aws.config.loadFromPath(process.cwd() + '/aws_config-dev.json')
    } else {
      aws.config.loadFromPath(process.cwd() + '/aws_config.json')
    }

    const transporter = mailer.createTransport({
      SES: new aws.SES({
        apiVersion: '2010-12-01'
      })
    })
    await transporter.sendMail(email)
  } catch (err) {
    logger.error(`sendEmail() :: Error while sending email:"${email}". ${err.stack}`)
    throw new Error('Could not send email')
  }
}

module.exports.sendEmail = sendEmail

async function getUserFilePath (file, userId) {
  const newDir = APP_FOLDERS.usersDir + '/' + userId
  const newFilePath = newDir + '/' + file
  const dirExists = await fileExists(newDir)
  if (!dirExists) {
    await fs.mkdir(newDir)
  }
  return newFilePath
}

module.exports.getUserFilePath = getUserFilePath

async function septicTankFile (filePath) {
  try {
    const correctedFilePath = path.resolve(filePath)
    const fileName = filePath.split('/').pop()

    const septicTankFilePath = `${APP_FOLDERS.septicTankDir}/${fileName}`
    const correctedSepticTankFilePath = path.resolve(septicTankFilePath)
    return fs.rename(correctedFilePath, correctedSepticTankFilePath)
  } catch (err) {
    throw new Error(`Could not move file to septic tank: ${filePath}. ${err.stack}`)
  }
}

module.exports.septicTankFile = septicTankFile

async function moveFile (fromFile, toFile) {
  try {
    logger.debug('moveFile(): FROM, TO: ', fromFile, toFile)
    return fs.rename(fromFile, toFile)
  } catch (err) {
    console.error(`moveFile() :: Error moving file from "${fromFile}" to "${toFile}".`, err.stack)
    throw new Error(`moveFile() :: Error moving file from "${fromFile}" to "${toFile}"`)
  }
}

module.exports.moveFile = moveFile

async function extractXls ({ eventId, fromFile, toFile }) {
  try {
    // TODO:Make this better. It does not read from a stream nor use a writestream
    const workBook = xlsx.readFile(fromFile)
    xlsx.writeFile(workBook, toFile, { bookType: 'csv' })
    return true
  } catch (err) {
    logger.error(`Could not convert xls/xlsx to csv for eventId:${eventId}.`, err.stack)
    throw new Error(`Could not convert xls/xlsx to csv for eventId:${eventId}.`)
  }
}

module.exports.extractXls = extractXls
