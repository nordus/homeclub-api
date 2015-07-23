async     = require 'async'
pageViews = require '../lib/google-analytics-page-views'


ensureArray = (item) ->
  if Array.isArray(item) then item else [item]


formatResponse = ( resp, acctId ) ->
  formattedChartData = []
  if resp != null && resp.rows
    formattedChartData = for nestedRow in resp.rows
      [match, year, month, day] = nestedRow[0].split /(\d{4})(\d{2})(\d{2})/
      unless month is 0
        month -= 1
      date  = new Date( year, month, day )
      epoch = date.getTime()
      x:epoch, y:parseInt(nestedRow[1])
  [
    data: formattedChartData
    name: acctId
    color: '#53b2da'
  ]


exports.pageViews = ( req, res ) ->

  accountIds  = ensureArray( req.query.accountIds )
  out         = {}

  async.each accountIds, ( acctId, done ) ->
    pageViews acctId, ( err, resp ) ->
      return done( err )  if err
      out[acctId] = formatResponse( resp, acctId )
      done()
  , ( err ) ->
    res.json err or out