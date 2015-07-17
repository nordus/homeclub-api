
google        = require 'googleapis'
oauth2Client  = require './google-oauth2-client'

drive = google.drive
  auth    : oauth2Client
  version : 'v2'


module.exports  = drive