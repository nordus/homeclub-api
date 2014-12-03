request = require('request')
path = require('path')

libDirPath = path.resolve(__dirname, '..', 'lib')
createChartData = require("#{libDirPath}/create-chart-data")
{SensorHub} = require('../../config/db').models
_ = require('lodash')
json2csv = require('json2csv')

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

  if req.query.offset
    queryParams.offset = req.query.offset

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

    else if req.query.filtered or req.query.download
      fields = switch req.query.msgType
        when '2' then ['timestamp', 'macAddress', 'gatewayBattery', 'gatewayEventCode', 'rssi']
        when '4' then ['timestamp', 'macAddress', 'sensorEventStart', 'sensorEventEnd', 'rssi', 'sensorHubBattery', 'sensorHubMacAddress', 'sensorHubRssi']
        when '5' then ['timestamp', 'macAddress', 'rssi', 'numberOfSensors', 'sensorHubBattery', 'sensorHubData1', 'sensorHubData2', 'sensorHubData3', 'sensorHubMacAddress', 'sensorHubRssi', 'sensorHubType']

      filtered = _.map resp.messages, (item) ->
        out = {}
        fields.forEach (field) ->
          out[field] = item.message[field]
        out

      if req.query.download
        json2csv
          data    : filtered
          fields  : fields
        , (err, csv) ->
          res.attachment "raw_data_msg_type_#{req.query.msgType}.csv"
          res.send csv
      else
        res.json filtered

    else
      res.json resp.messages