request = require('request')
querystring = require('querystring')
async = require 'async'


buildRequestOptions = (sensorHubMacAddress, msgType = 5, start = '30 days ago') ->
  queryParams =
    query   : "sensorHubMacAddress:#{sensorHubMacAddress} AND msgType:#{msgType}"
    keyword : "#{start} to midnight tomorrow"
    limit   : 1
    sort    : 'timestamp:desc'
    fields  : 'rssi, sensorEventStart, sensorEventEnd, sensorHubBattery, sensorHubData1, sensorHubData2, sensorHubData3, sensorHubMacAddress, sensorHubRssi, sensorHubType, timestamp'

  queryStr = querystring.stringify(queryParams)

  requestOptions =
    url: "http://graylog-server.homeclub.us:12900/search/universal/keyword?#{queryStr}"
    json: true
    headers:
      Authorization: 'Basic YXBpdXNlcjI6YXBpdXNlcjI='
      
    method: 'GET'

  return requestOptions


exports.sensorHubEvents = (req, res) ->

#  requestOptionsArr = req.query.sensorHubMacAddresses.map (sensorHub) -> buildRequestOptions sensorHub._id

  responses     = []
  latestAlerts  = {}
  out           = {}
  start         = '12 hours ago'

  if req.query.start
    # replace angular generated '+' characters w/ spaces
    start = req.query.start.replace /\+/g, ' '

  async.each req.query.sensorHubMacAddresses, (sensorHubMacAddress, done) ->

    options =
      readings  : buildRequestOptions( sensorHubMacAddress )
      alerts    : buildRequestOptions( sensorHubMacAddress, 4, start )

    callbacks =
      readings  : ( cb ) -> ( err, incomingMessage, resp ) -> responses.push resp; cb()
      alerts    : ( cb ) -> ( err, incomingMessage, resp ) -> latestAlerts[sensorHubMacAddress] = resp.messages[0]?.message; cb()

    async.each Object.keys( options ), ( readingsOrAlerts, cb ) ->
      request options[ readingsOrAlerts ], callbacks[ readingsOrAlerts ]( cb )
    , ( err ) -> done()

  , (err) ->
    responses.forEach (response) ->
#      if m = response.messages[0]?.message
      if eventData = response.messages[0]?.message
        tempInFahrenheit = ((eventData.sensorHubData1 * 9) / 5) + 32
#        eventData = {rssi:m.rssi, timestamp:m.timestamp,sensorHubData1:tempInFahrenheit,sensorHubRssi:m.sensorHubRssi, sensorHubBattery:m.sensorHubBattery, sensorHubType:m.sensorHubType}
        eventData.latestAlert     = latestAlerts[eventData.sensorHubMacAddress]
        eventData.sensorHubData1  = tempInFahrenheit
#        if m.sensorHubType is 2
#          eventData.sensorHubData2 = m.sensorHubData2
#          eventData.sensorHubData3 = m.sensorHubData3
        @[eventData.sensorHubMacAddress] = eventData
    , out

    res.json out