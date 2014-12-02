async   = require('async')
request = require('request')
{SensorHub} = require('../../config/db').models
_ = require('lodash')


buildRequestOptions = (field, start, msgType) -> {
url: 'http://gateway.homeclub.us:12900/search/universal/keyword/stats'
json: true
headers:
  Authorization: 'Basic YXBpdXNlcjpQYXNzdzByZCE='
method: 'GET'
qs:
  field: field
  query: "msgType:#{msgType}"
  keyword: "#{start} to midnight tomorrow"
}

makeSingleRequest = (requestOptions, cb) ->
  request requestOptions, (err, incomingMessage, resp) ->
    cb(null, resp)


module.exports = (req, res) ->
  start                 = req.query.start
  msgType               = req.query.msgType or 5

  requestOptionsArr = []

  fields = req.query.fields

  fields.forEach (field) ->
    requestOptionsArr.push buildRequestOptions(field, start, msgType)

  async.map requestOptionsArr, makeSingleRequest, (err, responses) ->
    out = {}
    fields.forEach (field, n) ->
      filtered = _.omit responses[n], 'built_query'
      out[field] = filtered
    res.json out