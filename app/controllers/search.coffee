request = require('request')
querystring = require('querystring')
path = require('path')

libDirPath = path.resolve(__dirname, '..', 'lib')
createChartData = require("#{libDirPath}/create-chart-data")
{SensorHub} = require('../../config/db').models

getSensorHubs = (sensorHubIds) ->
  SensorHub.where('_id').in(sensorHubIds).populate('roomType').exec()

module.exports = (req, res) ->
        
  queryParams =
    query   : "macAddress:#{req.query.macAddress} AND msgType:#{req.query.msgType}"
    keyword : "#{req.query.start} to midnight tomorrow"
    limit   : req.query.limit
    sort    : 'timestamp:asc'

  if req.query.sensorHubType
    queryParams.query += " AND sensorHubType:#{req.query.sensorHubType}"

  queryStr = querystring.stringify(queryParams)
    
  requestOptions =
    url: "http://gateway.homeclub.us:12900/search/universal/keyword?#{queryStr}"
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
    else
      res.json resp.messages