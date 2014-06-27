db              = require('./db')
RoomType        = db.models.RoomType
SensorHubType   = db.models.SensorHubType
WaterSource     = db.models.WaterSource


roomTypes = [
  "bedroom",
  "other",
  "downstairs",
  "hallway",
  "den",
  "living room",
  "master bedroom",
  "kids room",
  "laundry room",
  "upstairs",
  "family room",
  "kitchen",
  "dining room",
  "entryway",
  "office",
  "basement"
  "bathroom"
]
exports.RoomType =
  create: ->
    for roomType in roomTypes
      RoomType.create name:roomType, (err, roomType) ->
        console.log "roomType (#{roomType.name}) created!"


sensorHubTypes = [
  _id:1, friendlyName:'Water Protector'
,
  _id:2, friendlyName:'Comfort Director'
,
  _id:3, friendlyName:'Home Defender'
]
exports.SensorHubType =
  create: ->
    for sensorHubType in sensorHubTypes
      SensorHubType.create sensorHubType, (err, sensorHubType) ->
        console.log "sensor hub type (#{sensorHubType.friendlyName}) created!"


waterSourceNames = ["AC unit", "Aquarium", "Clothes Washer", "Dishwasher", "Humidifier", "Pool and Fountain", "Radiator", "Refrigerator", "Sink", "Sump Pump", "Toilet", "Tub & shower", "Water Heater", "Water Pipe (water supply line)"]
exports.WaterSource =
  create: ->
    for waterSourceName in waterSourceNames
      WaterSource.create name:waterSourceName, (e, waterSourceDoc) ->
        console.log e || waterSourceDoc