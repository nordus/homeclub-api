
fs            = require 'fs'
googleAuth    = require 'google-auth-library'
auth          = new googleAuth()


clientSecret  = fs.readFileSync "#{__dirname}/google-client-secret.json"
credentials   = JSON.parse( clientSecret ).installed
{ client_id, client_secret }  = credentials
redirectUrl   = credentials.redirect_uris[0]
oauth2Client  = new auth.OAuth2( client_id, client_secret, redirectUrl )

oauth2Client.credentials  = require './google-token.json'


module.exports  = oauth2Client