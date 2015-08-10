google        = require 'googleapis'
analytics     = google.analytics 'v3'
jwtClient     = require './google-jwt-client'


module.exports = ( acctId, startDate = '6daysAgo', cb ) ->
  analytics.data.ga.get
    auth          : jwtClient
    ids           : 'ga:105610113'
    metrics       : 'ga:pageviews,ga:screenviews'
    'start-date'  : startDate
    'end-date'    : 'today'
    filters       : "ga:dimension1==#{acctId}"
    dimensions    : 'ga:date'
  , cb