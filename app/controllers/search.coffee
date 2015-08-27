request = require('request')
{SensorHub} = require('../../config/db').models
_ = require('lodash')


module.exports = (req, res) ->
  fields = switch req.query.msgType
    when '0' then ['timestamp', 'macAddress', 'gatewayBattery', 'rssi']
    when '2' then ['timestamp', 'macAddress', 'gatewayBattery', 'gatewayEventCode', 'rssi']
    when '4' then ['timestamp', 'macAddress', 'sensorEventStart', 'sensorEventEnd', 'rssi', 'sensorHubBattery', 'sensorHubMacAddress', 'sensorHubRssi']
    when '5' then ['timestamp', 'macAddress', 'rssi', 'numberOfSensors', 'sensorHubBattery', 'sensorHubData1', 'sensorHubData2', 'sensorHubData3', 'sensorHubMacAddress', 'sensorHubRssi', 'sensorHubType']

  queryParams =
    query   : "msgType:#{req.query.msgType}"
    keyword : "#{req.query.start} to #{req.query.end || 'midnight tomorrow'}"
    limit   : req.query.limit
    sort    : 'timestamp:asc'
    fields  : fields.join()

  if req.query.sensorHubMacAddress
    queryParams.query += " AND sensorHubMacAddress:#{req.query.sensorHubMacAddress}"

  if req.query.sensorHubType
    queryParams.query += " AND sensorHubType:#{req.query.sensorHubType}"

  if req.query.macAddress
    queryParams.query += " AND macAddress:#{req.query.macAddress}"

  if req.query.gatewayEventCode
    queryParams.query += " AND gatewayEventCode:#{req.query.gatewayEventCode.replace /\+/g, ' '}"

  if req.query.offset
    queryParams.offset = req.query.offset

  requestOptions =
    url: "http://graylog-server.homeclub.us:12900/search/universal/keyword"
    qs: queryParams
    headers:
      Authorization: 'Basic YXBpdXNlcjI6YXBpdXNlcjI='

    method: 'GET'


  if req.query.download
    requestOptions.headers.Accept = 'text/csv'
    res.attachment "raw_data_msg_type_#{req.query.msgType}.csv"
    request(requestOptions).pipe res
  else
    requestOptions.json = true
    request requestOptions, (err, incomingMessage, resp) ->
        res.json _.pluck(resp.messages, 'message')