{CustomerAccount, Gateway, User, RoomType, SensorHub, SensorHubType} = require('./config/db').models


RoomType.find({}).where('name').in(['bathroom', 'laundry room', 'living room']).exec (e, roomTypes) ->
  roomTypeIds = {}
  
  roomTypes.forEach (roomType) ->
    @[roomType.name] = roomType._id
  , roomTypeIds
  
  sensorHubs = [
    _id:'000780682747', sensorHubType:2, roomType: roomTypeIds['living room']
  ,
    _id:'000780793439', sensorHubType:1, roomType: roomTypeIds['bathroom']
  ,
    _id:'0007807925C0', sensorHubType:1, roomType: roomTypeIds['laundry room']
  ]
  
  SensorHubType.findOne friendlyName:'Comfort Director', (e, comfortDirector) ->
    SensorHubType.findOne friendlyName:'Water Protector', (e, waterProtector) ->
  
      sensorHubs.forEach (sensorHubAttrs) ->
        sensorHubAttrs.sensorHubType = switch sensorHubAttrs.sensorHubType
          when 1 then waterProtector._id
          when 2 then comfortDirector._id
        SensorHub.create sensorHubAttrs, (e, sensorHub) ->
          console.log e || sensorHub

  User.findOne email:'tgl@senteri.com', (e, user) ->
    CustomerAccount.findOne user.roles.customerAccount, (e, account) ->
      Gateway.findOne _id:account.gateways[0], (e, gateway) ->
        sensorHubs.forEach (sensorHubAttrs) ->
          gateway.sensorHubs.addToSet sensorHubAttrs._id
        gateway.save (e) ->
          console.log e || gateway