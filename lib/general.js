const { promisify } = require('util')

function isAtLeastHeadJudge ({ user, eventId }) {
  return (
    user.eventAccess[eventId]?.headJudge ||
        user.eventAccess[eventId]?.coOwner ||
        user.eventAccess[eventId]?.owner ||
        user.permissions.isSupport ||
        user.permissions.isAdmin
  )
}

module.exports.isAtLeastHeadJudge = isAtLeastHeadJudge

// HACK: Promsify the session methods
async function regenerateSession (req) {
  await promisify(req.session.regenerate.bind(req.session))()
}

module.exports.regenerateSession = regenerateSession

async function saveSession (req) {
  await promisify(req.session.save.bind(req.session))()
}

module.exports.saveSession = saveSession

// END HACK
