request = require('request')
path = require('path')

libDirPath = path.resolve(__dirname, '..', 'lib')
createChartData = require("#{libDirPath}/create-chart-data")
{SensorHub} = require('../../config/db').models
_ = require('lodash')

getSensorHubs = (sensorHubIds) ->
  SensorHub.where('_id').in(sensorHubIds).populate('roomType').exec()

module.exports = (req, res) ->
        
  queryParams =
    query   : "msgType:#{req.query.msgType}"
    keyword : "#{req.query.start} to midnight tomorrow"
    limit   : req.query.limit
    sort    : 'timestamp:asc'

  if req.query.sensorHubType
    queryParams.query += " AND sensorHubType:#{req.query.sensorHubType}"

  if req.query.macAddress
    queryParams.query += " AND macAddress:#{req.query.macAddress}"
    
  requestOptions =
    url: "http://gateway.homeclub.us:12900/search/universal/keyword"
    qs: queryParams
    json: true
    headers:
      Authorization: 'Basic YXBpdXNlcjpQYXNzdzByZCE='
      
    method: 'GET'

  request requestOptions, (err, incomingMessage, resp) ->
    if req.query.highchartFormat
      getSensorHubs(req.query.sensorHubMacAddresses).then (sensorHubs) ->
        roomNamesBySensorHubMacAddress = {}
        sensorHubs.forEach (sensorHub) ->
          @[sensorHub._id] = sensorHub.roomType?.name
        , roomNamesBySensorHubMacAddress
    
        chartData = createChartData resp.messages, roomNamesBySensorHubMacAddress
        res.json chartData

    else if req.query.filtered
      filtered = _.map resp.messages, (item) ->
        m = item.message
        {
          timestamp           : m.timestamp
          numberOfSensors     : m.numberOfSensors
          rssi                : m.rssi
          sensorHubBattery    : m.sensorHubBattery
          sensorHubData1      : m.sensorHubData1
          sensorHubData2      : m.sensorHubData2
          sensorHubData3      : m.sensorHubData3
          sensorHubMacAddress : m.sensorHubMacAddress
          sensorHubRssi       : m.sensorHubRssi
          sensorHubType       : m.sensorHubType
          macAddress          : m.macAddress
          sensorEventStart    : m.sensorEventStart
          sensorEventEnd      : m.sensorEventEnd
          gatewayBattery      : m.gatewayBattery
          gatewayEventCode    : m.gatewayEventCode
        }

      res.json filtered

    else
      res.json resp.messages