async             = require 'async'
pageViews         = require '../lib/google-analytics-page-views'
_                 = require 'lodash'
db                = require('../../config/db')
{CustomerAccount} = db.models
_                 = require('lodash')


ensureArray = (item) ->
  if Array.isArray(item) then item else [item]


formatResponse = ( resp ) ->
  pageviewChartData   = []
  screenviewChartData = []
  if resp != null && resp.rows
    for nestedRow in resp.rows
      [match, year, month, day] = nestedRow[0].split /(\d{4})(\d{2})(\d{2})/
      month--
      epoch = Date.UTC( year, month, day, 12 )

      pageviewChartData.push    x:epoch, y:parseInt(nestedRow[1])
      screenviewChartData.push  x:epoch, y:parseInt(nestedRow[2])
  [
    data: pageviewChartData
    name: 'web views'
    color: '#53b2da'
  ,
    data: screenviewChartData
    name: 'mobile views'
    color: '#ff8000'
  ]


exports.pageViews = ( req, res ) ->

  if req.query.carrier
    opts  =
      carrierId : req.query.carrier

    pageViews opts, ( err, resp ) ->
      res.json err or formatResponse( resp )

  if req.query.accountIds
    accountIds  = ensureArray( req.query.accountIds )
    out         = {}

    async.each accountIds, ( acctId, done ) ->
      opts =
        acctId  : acctId

      pageViews opts, ( err, resp ) ->
        return done( err )  if err
        out[acctId] = formatResponse( resp )
        done()
    , ( err ) ->
      res.json err or out

  else if req.user.roles.homeClubAdmin
    pageViews {}, ( err, resp ) ->
      res.json err or formatResponse( resp )


setAccountIdsAndStartDates = ( req, res, next ) ->
  if req.query.carrier
    CustomerAccount.where( carrier: req.query.carrier, shipDate: $ne:null ).select( 'shipDate' ).lean().exec ( e, accts ) ->
      accountIds  = _.pluck accts, '_id'
      startDates  = accts.map ( acct ) -> acct.shipDate.toISOString().split( 'T' )[0]
      req.accountIdsAndStartDates = _.zip accountIds, startDates
      next()

  else
    accountIds  = ensureArray( req.query.accountIds )
    startDates  = ensureArray( req.query.startDates )
    req.accountIdsAndStartDates = _.zip accountIds, startDates
    next()

generateCsv = ( req, res, next ) ->
  out         = [
                  ['Account ID', 'Date', 'Page Views', 'Screen Views']
                ]

  async.each req.accountIdsAndStartDates, ( accountIdAndStartDate, done ) ->

    [acctId, startDate] = accountIdAndStartDate

    opts =
      acctId    : acctId
      startDate : startDate

    pageViews opts, ( err, resp ) ->
      return done( err )  if err

      if rows = resp?.rows
        # add acctId to the front of each array
        row.unshift( acctId )  for row in rows
        out = out.concat rows
        done()

  , ( err ) ->
    res.attachment "web_and_mobile_usage.csv"
    res.csv out

exports.usageReport = [setAccountIdsAndStartDates, generateCsv]