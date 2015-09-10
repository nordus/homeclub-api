requireDir  = require 'require-directory'
c           = requireDir module, "#{__dirname}/../app/controllers"
auth        = require('./auth')


module.exports = (router, passport) ->

  # WEB HOOKS
  router.route('/webhooks/network-hub-event')
    .post(c.webhooks.networkHubEvent)

  router.route('/webhooks/sensor-hub-event')
    .post(c.webhooks.sensorHubEvent)

  router.route('/webhooks/sms-initiated-ack')
    .post(c.webhooks.smsInitiatedAck)

  router.route('/webhooks/sms-initiated-outcome')
    .post(c.webhooks.smsInitiatedOutcome)


  # SMS
  router.route('/sms')
    .post(c.sms)



  # CONSUMER
  router.route('/login')
    .post passport.authenticate('local'), (req, res) ->
      res.redirect req.user.defaultReturnUrl()

  router.all '/me/*', auth.setUserFromAuthToken

  # ensure req.isAuthenticated for all routes below
  router.use auth.requiresApiLogin

  router.route('/hc2')
    .post(c.hc2)


  router.route('/fieldhistograms')
    .get(c.fieldhistograms)

  router.route('/users/:id')
    .put(c.users.update)
    .get(c.users.show)

  router.route('/logout')
    .post (req, res) ->
      req.logout()
      res.end()
      
  router.route('/search')
    .get(c.search)

  router.route('/sensor-hubs/:id')
    .put(c['sensor-hubs'].update)

  router.route('/sensor-hubs')
    .get(c['sensor-hubs'].index)

  router.route('/room-types')
    .get(c['room-types'].index)

  router.route('/water-sources')
    .get(c['water-sources'].index)

  router.route('/latest/sensor-hub-events')
    .get(c['latest'].sensorHubEvents)

  router.route('/me/customer-account')
    .get(c['me'].customerAccount)

  router.route('/customer-accounts/:id')
    .put(c['customer-accounts'].update)

  router.route('/gateways/:id')
    .get(c.gateways.show)



  # CARRIER ADMIN
  router.route('/me/carrier-admin')
    .get(auth.requiresRole('carrierAdmin'), c['me'].carrierAdmin)



  # BOTH (CARRIER ADMIN and HOMECLUB ADMIN)
  router.route('/users')
    .get(c.users.index)

  router.route( '/google-analytics/page-views' )
    .get( c['google-analytics'].pageViews )

  router.route( '/google-analytics/usage-report' )
    .get( c['google-analytics'].usageReport )

  router.route('/histograms/:carrier?')
    .get(c.histograms)

  router.route('/aggregates')
    .get(c.aggregates)

  router.route('/carrier-admins')
    .get(c['carrier-admins'].index)
    .post(c['carrier-admins'].create)

  router.route('/carrier-admins/:id')
    .get(c['carrier-admins'].show)
    .delete(c['carrier-admins'].delete)

  router.route('/customer-accounts')
    .get(c['customer-accounts'].index)

  router.route('/customer-accounts/:id')
    .get(c['customer-accounts'].show)
    .delete(c['customer-accounts'].delete)

  router.route('/gateways/:id')
    .post(c.gateways.create)
    .put(c.gateways.update)
    .delete(c.gateways.delete)

  router.route('/stats')
    .get(c.stats)



  # HOMECLUB ADMIN
  router.use auth.requiresRole('homeClubAdmin')

  router.route('/users/:id')
    .delete(c.users.delete)

  router.route('/test-data/backup')
    .post(c['test-data'].backupToGoogleDrive)

  router.route('/test-data/check-for-backup')
    .post(c['test-data'].checkForBackup)

  router.route('/test-data/delete-from-graylog')
    .post(c['test-data'].deleteFromGraylog)

  router.route('/reset')
    .get(c.reset)

  router.route('/carriers/:id')
    .get(c.carriers.show)

  router.route('/carriers')
    .get(c.carriers.index)
    .post(c.carriers.create)

  router.route('/outbound-sms')
    .get(c['outbound-sms'].index)

  router.route('/hc1')
    .post(c.hc1)

  router.route('/outbound-commands')
    .get(c['outbound-commands'].index)

  router.route('/home-club-admins/:id')
    .get(c['home-club-admins'].show)
    .delete(c['home-club-admins'].delete)

  router.route('/home-club-admins')
    .get(c['home-club-admins'].index)

  router.route('/import-google-doc/preview')
    .post(c['import-google-doc'].preview)

  router.route('/import-google-doc')
    .post(c['import-google-doc'].create)

  router.route('/me/home-club-admin')
    .get(c['me'].homeClubAdmin)

  router.route('/gateways')
    .get(c.gateways.index)

  router.route('/sensor-hubs/:id')
    .get(c['sensor-hubs'].show)
    .post(c['sensor-hubs'].create)

#  router.route( '/google-analytics/page-views' )
#    .get( c['google-analytics'].pageViews )