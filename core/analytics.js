async function createUserAnalytic ({ UserAnalytics, newAnalyticsObj }) {
  return UserAnalytics.create(newAnalyticsObj)
}
module.exports.createUserAnalytic = createUserAnalytic
