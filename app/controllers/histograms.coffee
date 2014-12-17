async   = require('async')
request = require('request')
db      = require('../../config/db')
{CustomerAccount} = db.models


buildRequestOptions = (sensorHubMacAddress, start, interval) -> {
url: 'http://gateway.homeclub.us:12900/search/universal/keyword/histogram'
json: true
headers:
  Authorization: 'Basic YXBpdXNlcjphcGl1c2Vy'
method: 'GET'
qs:
  query: "sensorHubMacAddress:#{sensorHubMacAddress}"
  interval: interval
  keyword: "#{start} to midnight tomorrow"
}

formatResponse = (resp, sensorHubMacAddress) ->
  formattedChartData = []
  if resp.results
    formattedChartData = for k,v of resp.results
      x:parseInt(k), y:v
  hasAllDataPoints = formattedChartData.length >= 12
  color = if hasAllDataPoints then '#53b2da' else '#f2dede'
  [
    data: formattedChartData
    name: sensorHubMacAddress
    color: color
  ]


module.exports = (req, res) ->
  start                 = req.query.start or '12 hours ago'
  interval              = req.query.interval or 'hour'

  params = switch req.params.carrier
    when undefined then {}
    else carrier: db.Types.ObjectId(req.params.carrier)

  CustomerAccount.find(params).populate('gateways').exec (err, accounts) ->

    allSensorHubMacAddresses  = []
    nameBySensorHubMacAddress = {}

    accounts.forEach (account) ->
      g = account.gateways[0]
      # return if account has no gateways assigned
      return unless g
      customerName = "#{account.name.first} #{account.name.last}"
      # name contains network hub ID, firstName lastName, customer ID as a
      # pipe ('|') delimited string
      # i.e. '000780677246|John Doe|53a8ad2ed7babc9210c6c7ce'
      name = [
        g._id
        customerName
        account._id
      ].join '|'
      g.sensorHubs.forEach (sensorHubMacAddress) ->
        # sensorHubs on the same gateway have the same name
        nameBySensorHubMacAddress[sensorHubMacAddress] = name
        allSensorHubMacAddresses.push sensorHubMacAddress


    out = {}

    async.each allSensorHubMacAddresses, (sensorHubMacAddress, done) ->

      name = nameBySensorHubMacAddress[sensorHubMacAddress]

      unless out[name]
        out[name] = {}

      requestOptions = buildRequestOptions(sensorHubMacAddress, start, interval)

      request requestOptions, (err, incomingMessage, resp) ->
        formattedResponse = formatResponse(resp, sensorHubMacAddress)
        out[name][sensorHubMacAddress] = formattedResponse
        done()
    , (err) ->
      res.json out