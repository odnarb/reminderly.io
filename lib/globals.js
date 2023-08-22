const fs = require('fs/promises')

const fileExists = async path => !!(await fs.stat(path).catch(e => false))

module.exports.fileExists = fileExists

const PROJECT_NAME = 'reminderly'

const APP_FOLDERS = {
  tempDir: `/var/${PROJECT_NAME}/temp`,
  baseDataDir: `/var/${PROJECT_NAME}/data`,
  septicTankDir: `/var/${PROJECT_NAME}/septic_tank`,
  usersDir: `/var/${PROJECT_NAME}/users`
}

module.exports.APP_FOLDERS = APP_FOLDERS

const CSV_TEMPLATE_FILE_NAME = 'bulk-upload-template.csv'

module.exports.CSV_TEMPLATE_FILE_NAME = CSV_TEMPLATE_FILE_NAME

const CSV_TEMPLATE = 'entryName,entryDescription,entryCategory,entryYear,entryMake,entryModel,entryLicensePlate,entryCarClub,ownerFirstName,ownerLastName,ownerEmailAddress,ownerPhoneNumber'

module.exports.CSV_TEMPLATE = CSV_TEMPLATE

// event_type_id to fields map
const CSV_MATCHING_FIELDS_MAP = {
  CARSHOW: {
    entryName: { required: true },
    entryDescription: { required: false },
    entryCategory: { required: true },
    entryYear: { required: true },
    entryMake: { required: true },
    entryModel: { required: true },
    entryLicensePlate: { required: false },
    entryCarClub: { required: false },
    ownerFirstName: { required: false },
    ownerLastName: { required: false },
    ownerEmailAddress: { required: true },
    ownerPhoneNumber: { required: false }
  }
}

module.exports.CSV_MATCHING_FIELDS_MAP = CSV_MATCHING_FIELDS_MAP

const IMPORT_FILE_TYPES = ['csv', 'xls', 'xlsx']

module.exports.IMPORT_FILE_TYPES = IMPORT_FILE_TYPES

async function makeAppDirs () {
  for (const prop in APP_FOLDERS) {
    const folder = APP_FOLDERS[prop]
    if (!await fileExists(folder)) {
      await fs.mkdir(folder)
    }
  }
}

module.exports.makeAppDirs = makeAppDirs

module.exports.APP_INFO = {
  APP_NAME: process.env.APP_NAME,
  APP_URL: process.env.APP_URL,
  APP_LOGO: process.env.APP_LOGO
}

// 14 days
module.exports.COOKIE_MAX_AGE = 14 * 24 * 60 * 60 * 1000

// 1 hr
module.exports.COOKIE_MIN_AGE = 60 * 60 * 1000

module.exports.DEFAULT_USER_TYPE = 1

// maybe this is a trial period..
module.exports.DAYS_LEFT_TO_PAY = 7
module.exports.SUBSCRIPTION_PERIOD = 30

module.exports.SALT_ROUNDS = 10

module.exports.USER_TYPES = {
  USER: 1,
  SUPPORT: 2,
  ADMIN: 3
}

module.exports.USER_TYPE_IDS = {
  1: 'User',
  2: 'Support',
  3: 'Admin'
}

module.exports.PERMISSIONS_TYPES = { isAtLeastHeadJudge: 'isAtLeastHeadJudge' }

module.exports.BULK_IMPORT_STATUS = {
  uploaded: 1,
  staged: 2,
  completed: 3
}

module.exports.NOTIFICATION_TYPES = {
  registration: 1,
  billing: 2,
  forgot_password: 3
}

module.exports.NOTIFICATION_STATUS = {
  PENDING: 1,
  SENT: 2,
  ERROR: 3
}

module.exports.NOTIFICATION_METHODS = {
  sms: 1,
  fb_messenger: 2,
  whatsapp: 3,
  email: 4,
  instagram: 5,
  twitter: 6
}

module.exports.REGISTRATION_STATUS = {
  PENDING: 1,
  VERIFIED: 2,
  PAID: 3,
  EXPIRED: 4,
  ERROR: 5
}

module.exports.errorPages = {
  404: '404',
  400: '400',
  401: '401',
  403: '403',
  500: '500',
  502: '502',
  503: '503'
}

module.exports.STATES = [
  { id: 'AL', text: 'Alabama' },
  { id: 'AK', text: 'Alaska' },
  { id: 'AZ', text: 'Arizona' },
  { id: 'AR', text: 'Arkansas' },
  { id: 'CA', text: 'California' },
  { id: 'CO', text: 'Colorado' },
  { id: 'CT', text: 'Connecticut' },
  { id: 'DE', text: 'Delaware' },
  { id: 'DC', text: 'District Of Columbia' },
  { id: 'FL', text: 'Florida' },
  { id: 'GA', text: 'Georgia' },
  { id: 'HI', text: 'Hawaii' },
  { id: 'ID', text: 'Idaho' },
  { id: 'IL', text: 'Illinois' },
  { id: 'IN', text: 'Indiana' },
  { id: 'IA', text: 'Iowa' },
  { id: 'KS', text: 'Kansas' },
  { id: 'KY', text: 'Kentucky' },
  { id: 'LA', text: 'Louisiana' },
  { id: 'ME', text: 'Maine' },
  { id: 'MD', text: 'Maryland' },
  { id: 'MA', text: 'Massachusetts' },
  { id: 'MI', text: 'Michigan' },
  { id: 'MN', text: 'Minnesota' },
  { id: 'MS', text: 'Mississippi' },
  { id: 'MO', text: 'Missouri' },
  { id: 'MT', text: 'Montana' },
  { id: 'NE', text: 'Nebraska' },
  { id: 'NV', text: 'Nevada' },
  { id: 'NH', text: 'New Hampshire' },
  { id: 'NJ', text: 'New Jersey' },
  { id: 'NM', text: 'New Mexico' },
  { id: 'NY', text: 'New York' },
  { id: 'NC', text: 'North Carolina' },
  { id: 'ND', text: 'North Dakota' },
  { id: 'OH', text: 'Ohio' },
  { id: 'OK', text: 'Oklahoma' },
  { id: 'OR', text: 'Oregon' },
  { id: 'PA', text: 'Pennsylvania' },
  { id: 'RI', text: 'Rhode Island' },
  { id: 'SC', text: 'South Carolina' },
  { id: 'SD', text: 'South Dakota' },
  { id: 'TN', text: 'Tennessee' },
  { id: 'TX', text: 'Texas' },
  { id: 'UT', text: 'Utah' },
  { id: 'VT', text: 'Vermont' },
  { id: 'VA', text: 'Virginia' },
  { id: 'WA', text: 'Washington' },
  { id: 'WV', text: 'West Virginia' },
  { id: 'WI', text: 'Wisconsin' },
  { id: 'WY', text: 'Wyoming' }
]
