# create/link User and CustomerAccount
module.exports = (attrs)->
  defaultAttrs =
    email     : 'tgl@senteri.com'
    password  : 'trondheim'
    name:
      first : 'Terje'
      last  : 'Gloerstad'

  attrs = attrs || defaultAttrs
  
  req =
    body  : attrs
  
  res =
    json  : console.log

  require('./app/controllers/customer-accounts').create req, res