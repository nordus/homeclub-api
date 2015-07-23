google          = require 'googleapis'
key             = require './google-service-account-key.json'


module.exports  = new google.auth.JWT(  key.client_email,
                                        null,
                                        key.private_key,
                                        'https://www.googleapis.com/auth/analytics',
                                        'daniel.johnson@senteri.com' )