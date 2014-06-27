async       = require 'async'
mongoose    = require 'mongoose'
envConfig   = require './env-config'
requireDir  = require 'require-directory'


# load mongoose models
requireDir module, "#{__dirname}/../app/models"

db = mongoose.connect(envConfig.db)

db.wipe = (cb) ->
  async.parallel (m.remove.bind m for _, m of db.models), cb


module.exports = db