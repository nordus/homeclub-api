
backup  = require '../lib/google-drive-backup-graylog'
search  = require '../lib/google-drive-search'
request = require 'request'



ensureArray = ( item ) ->
  if Array.isArray( item ) then item else [item]


exports.backupToGoogleDrive = ( req, res ) ->

  backup req.body.macAddresses, ( err ) ->
    return res.sendStatus( 500 )  if err
    res.sendStatus 200


exports.checkForBackup = ( req, res ) ->

  search req.body.macAddresses, ( err, resp ) ->
    return res.sendStatus 500  if err

    if resp.items.length
      res.json resp.items[0]
    else
      res.sendStatus 404


exports.deleteFromGraylog = ( req, res ) ->

  url = "http://10.0.0.43:9200/graylog_0/message/_query?q=macAddress:#{req.body.macAddress}"

  request.del( url ).pipe res