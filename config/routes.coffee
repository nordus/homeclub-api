requireDir  = require 'require-directory'
c           = requireDir module, "#{__dirname}/../app/controllers"
auth        = require('./auth')


module.exports = (router, passport) ->

  # WEB HOOKS
  router.route('/webhooks/network-hub-event')
    .post(c.webhooks.networkHubEvent)

  router.route('/webhooks/sensor-hub-event')
    .post(c.webhooks.sensorHubEvent)



  # CONSUMER
  router.route('/users/:id')
    .put(c.users.update)
    .get(c.users.show)

  router.route('/login')
    .post passport.authenticate('local'), (req, res) ->
      res.redirect req.user.defaultReturnUrl()

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
    .get(auth.requiresApiLogin, c['me'].customerAccount)



  # CARRIER ADMIN
  router.route('/me/carrier-admin')
    .get(auth.requiresRole('carrierAdmin'), c['me'].carrierAdmin)



  # HOMECLUB ADMIN
  router.use auth.requiresRole('homeClubAdmin')

  router.route('/aggregates')
    .get(c.aggregates)

  router.route('/reset')
    .get(c.reset)

  router.route('/carriers/:id')
    .get(c.carriers.show)

  router.route('/carriers')
    .get(c.carriers.index)
    .post(c.carriers.create)

  router.route('/customer-accounts/:id')
    .put(c['customer-accounts'].update)
    .get(c['customer-accounts'].show)
    .delete(c['customer-accounts'].delete)

  router.route('/customer-accounts')
    .get(c['customer-accounts'].index)

  router.route('/users')
    .get(c.users.index)

  router.route('/carrier-admins/:id')
    .get(c['carrier-admins'].show)
    .delete(c['carrier-admins'].delete)

  router.route('/carrier-admins')
    .get(c['carrier-admins'].index)

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

  router.route('/gateways/:id')
    .get(c.gateways.show)
    .post(c.gateways.create)
    .put(c.gateways.update)

  router.route('/gateways')
    .get(c.gateways.index)

  router.route('/sensor-hubs/:id')
    .get(c['sensor-hubs'].show)
    .post(c['sensor-hubs'].create)