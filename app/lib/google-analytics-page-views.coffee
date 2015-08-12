google        = require 'googleapis'
analytics     = google.analytics 'v3'
jwtClient     = require './google-jwt-client'


module.exports = ( opts, cb ) ->

  startDate = opts.startDate || '6daysAgo'

  q =
    auth          : jwtClient
    ids           : 'ga:105610113'
    metrics       : 'ga:pageviews,ga:screenviews'
    'start-date'  : startDate
    'end-date'    : 'today'
    dimensions    : 'ga:date'

  if opts.acctId
    q.filters  = "ga:dimension1==#{opts.acctId}"

  if opts.carrierId
    q.filters  = "ga:dimension2==#{opts.carrierId}"

  analytics.data.ga.get q, cb