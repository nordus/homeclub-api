path = require('path')

configDirPath = path.resolve(__dirname, '..', '..', 'config')
{WaterSource} = require("#{configDirPath}/db").models


exports.index = (req, res) ->
  WaterSource.find {}, (e, waterSources) ->
    res.json waterSources