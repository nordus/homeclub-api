path = require('path')

configDirPath = path.resolve(__dirname, '..', '..', 'config')
{RoomType} = require("#{configDirPath}/db").models


exports.index = (req, res) ->
  RoomType.find {}, (e, roomTypes) ->
    res.json roomTypes