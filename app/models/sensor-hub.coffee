mongoose = require('mongoose')


sensorHubSchema = new mongoose.Schema

  _id         : String  # bluetooth MAC address
  batteryPct  : Number
  name        : String
  rssi        : Number

  waterSource:
    ref   : 'WaterSource'
    type  : mongoose.Schema.Types.ObjectId
  
  roomType:
    ref   : 'RoomType'
    type  : mongoose.Schema.Types.ObjectId
    
  sensorHubType:
    ref   : 'SensorHubType'
    type  : Number

mongoose.model 'SensorHub', sensorHubSchema