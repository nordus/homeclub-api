request = require('request')
querystring = require('querystring')
async = require 'async'


buildRequestOptions = (sensorHubMacAddress, msgType = 5, start = '30 days ago') ->
  queryParams =
    query   : "sensorHubMacAddress:#{sensorHubMacAddress} AND msgType:#{msgType}"
    keyword : "#{start} to midnight tomorrow"
    limit   : 1
    sort    : 'timestamp:desc'

  queryStr = querystring.stringify(queryParams)

  requestOptions =
    url: "http://graylog-server.homeclub.us:12900/search/universal/keyword?#{queryStr}"
    json: true
    headers:
      Authorization: 'Basic YXBpdXNlcjphcGl1c2Vy'
      
    method: 'GET'

  return requestOptions


exports.sensorHubEvents = (req, res) ->

  requestOptionsArr = req.query.sensorHubMacAddresses.map (sensorHub) -> buildRequestOptions sensorHub._id

  responses = []
  out = {}
  async.each req.query.sensorHubMacAddresses, (sensorHubMacAddress, done) ->
    requestOptions = buildRequestOptions(sensorHubMacAddress)
    request requestOptions, (err, incomingMessage, resp) ->
      responses.push resp
      done()
  , (err) ->
    responses.forEach (response) ->
      if m = response.messages?[0].message
        tempInFahrenheit = ((m.sensorHubData1 * 9) / 5) + 32
        eventData = {rssi:m.rssi, timestamp:m.timestamp,sensorHubData1:tempInFahrenheit,sensorHubRssi:m.sensorHubRssi, sensorHubBattery:m.sensorHubBattery}
        if m.sensorHubType is 2
          eventData.sensorHubData2 = m.sensorHubData2
          eventData.sensorHubData3 = m.sensorHubData3
          eventData.sensorHubBattery = m.sensorHubBattery
        @[m.sensorHubMacAddress] = eventData
    , out

    res.json out