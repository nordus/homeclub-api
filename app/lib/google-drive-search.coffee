
drive       = require './google-drive'
# reference to 'HomeClub pre-ship data' folder
rootFolder  =
  id  : '0B030Blr-Pk9bflhfZ0VsREduaUtPOG9JZEFnVFZXcEV6M2JfRVNZZTFQbU1QNTczTGVrTUE'


module.exports = ( macAddress, cb ) ->
  unless cb
    cb = ( err, resp ) -> console.log err||resp
  drive.children.list
    folderId  : rootFolder.id
    q         : "title='#{macAddress}' and trashed = false"
  , cb