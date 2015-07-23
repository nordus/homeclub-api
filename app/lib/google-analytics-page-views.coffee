google        = require 'googleapis'
analytics     = google.analytics 'v3'
jwtClient     = require './google-jwt-client'


module.exports = ( acctId = '5550f6f9f3b527688eea24de', cb ) ->
  analytics.data.ga.get
    auth          : jwtClient
    ids           : 'ga:105610113'
    metrics       : 'ga:pageviews'
    'start-date'  : '6daysAgo'
    'end-date'    : 'today'
    filters       : "ga:dimension1==#{acctId}"
    dimensions    : 'ga:date'
  , cb