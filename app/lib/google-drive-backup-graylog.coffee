
async   = require 'async'
drive   = require './google-drive'
fs      = require 'fs'
request = require 'request'
search  = require './google-drive-search'

# reference to 'HomeClub pre-ship data' folder
rootFolder  =
  id  : '0B030Blr-Pk9bflhfZ0VsREduaUtPOG9JZEFnVFZXcEV6M2JfRVNZZTFQbU1QNTczTGVrTUE'

fieldsByMsgType =
  '0' : ['timestamp', 'macAddress', 'gatewayBattery', 'rssi']
  '2' : ['timestamp', 'macAddress', 'gatewayBattery', 'gatewayEventCode', 'rssi']
  '4' : ['timestamp', 'macAddress', 'sensorEventStart', 'sensorEventEnd', 'rssi', 'sensorHubBattery', 'sensorHubMacAddress', 'sensorHubRssi']
  '5' : ['timestamp', 'macAddress', 'rssi', 'numberOfSensors', 'sensorHubBattery', 'sensorHubData1', 'sensorHubData2', 'sensorHubData3', 'sensorHubMacAddress', 'sensorHubRssi', 'sensorHubType']


buildRequestOptions = ( macAddress, msgType ) ->
  queryParams =
    query   : "macAddress:#{macAddress} AND msgType:#{msgType}"
    keyword : '5 years ago to midnight tomorrow'
    sort    : 'timestamp:asc'
    fields  : fieldsByMsgType[msgType].join ','

  return {
    method: 'GET'
    url: 'http://graylog-server.homeclub.us:12900/search/universal/keyword'
    qs: queryParams
    headers:
      Accept: 'text/csv'
      Authorization: 'Basic YXBpdXNlcjI6YXBpdXNlcjI='
  }


backup = ( macAddress, parentFolder ) ->
  msgTypes = Object.keys( fieldsByMsgType )

  async.each msgTypes, ( msgType, done ) ->

    requestOptions = buildRequestOptions( macAddress, msgType )

    drive.files.insert
      resource:
        mimeType  : 'application/vnd.google-apps.spreadsheet'
        title     : "msg_type_#{msgType}"
        parents   : [parentFolder]
      media:
        body      : request( requestOptions )
        mimeType  : 'text/csv'
    , ( err = null, resp ) ->
        done( err )


ensureArray = ( item ) ->
  if Array.isArray( item ) then item else [item]


module.exports = ( macAddresses, cb ) ->

  macAddresses = ensureArray( macAddresses )

  async.each macAddresses, ( macAddress, done ) ->

    search macAddress, ( err, resp ) ->

      parentFolderExists = resp.items.length

      if parentFolderExists
        existingParentFolder = id:resp.items[0].id
        backup( macAddress, existingParentFolder )
        done()
      else
        # create parent folder
        drive.files.insert
          resource:
            mimeType  : 'application/vnd.google-apps.folder'
            title     : macAddress
            parents   : [rootFolder]
        , ( err, resp ) ->
          newlyCreatedParentFolder = id:resp.id
          backup( macAddress, newlyCreatedParentFolder )
          done()
  , cb