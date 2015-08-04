async     = require 'async'
pageViews = require '../lib/google-analytics-page-views'


ensureArray = (item) ->
  if Array.isArray(item) then item else [item]


formatResponse = ( resp, acctId ) ->
  pageviewChartData   = []
  screenviewChartData = []
  if resp != null && resp.rows
    for nestedRow in resp.rows
      [match, year, month, day] = nestedRow[0].split /(\d{4})(\d{2})(\d{2})/
      month--
      epoch = Date.UTC( year, month, day )

      pageviewChartData.push    x:epoch, y:parseInt(nestedRow[1])
      screenviewChartData.push  x:epoch, y:parseInt(nestedRow[2])
  [
    data: pageviewChartData
    name: 'pageviews'
    color: '#7bc5d3'
  ,
    data: screenviewChartData
    name: 'screenviews'
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
