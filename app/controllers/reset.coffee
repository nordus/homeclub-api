db = require('../../config/db')
seed = require('../../config/seed-data')
createDefaultAccount = require('../../create-default-account')


module.exports = (req, res) ->
  console.log '.. wiping database'
  db.wipe ->
    ['RoomType', 'SensorHubType', 'WaterSource'].forEach (m) ->
      seed[m].create()
    createDefaultAccount()
    res.send 'Database reset!  Customer account created!  (tgl@senteri.com)'