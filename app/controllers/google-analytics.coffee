async             = require 'async'
pageViews         = require '../lib/google-analytics-page-views'
_                 = require 'lodash'
db                = require('../../config/db')
{CustomerAccount} = db.models
_                 = require('lodash')


ensureArray = (item) ->
  if Array.isArray(item) then item else [item]


formatResponse = ( resp, acctId ) ->
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
    name: 'page views'
    color: '#53b2da'
  ,
    data: screenviewChartData
    name: 'screen views'
    color: '#ff8000'
  ]


exports.pageViews = ( req, res ) ->

  accountIds  = ensureArray( req.query.accountIds )
  out         = {}

  async.each accountIds, ( acctId, done ) ->
    pageViews acctId, undefined, ( err, resp ) ->
      return done( err )  if err
      out[acctId] = formatResponse( resp, acctId )
      done()
  , ( err ) ->
    res.json err or out


setAccountIdsAndStartDates = ( req, res, next ) ->
  if req.query.carrier && req.user.roles.carrierAdmin
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

    pageViews acctId, startDate, ( err, resp ) ->
      return done( err )  if err

      if rows = resp?.rows
        # add acctId to the front of each array
        row.unshift( acctId )  for row in rows
        out = out.concat rows
        done()

  , ( err ) ->
    res.csv out

exports.usageReport = [setAccountIdsAndStartDates, generateCsv]