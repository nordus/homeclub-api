google        = require 'googleapis'
analytics     = google.analytics 'v3'
jwtClient     = require './google-jwt-client'


module.exports = ( opts, cb ) ->

  if opts.acctId
    filter  = "ga:dimension1==#{opts.acctId}"

  if opts.carrierId
    filter  = "ga:dimension2==#{opts.carrierId}"

  startDate = opts.startDate || '6daysAgo'

  analytics.data.ga.get
    auth          : jwtClient
    ids           : 'ga:105610113'
    metrics       : 'ga:pageviews,ga:screenviews'
    'start-date'  : startDate
    'end-date'    : 'today'
    filters       : filter
    dimensions    : 'ga:date'
  , cb