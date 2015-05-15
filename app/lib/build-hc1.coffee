
pad           = require './pad'
reverseBytes  = require './reverse-bytes'
toHex         = require './to-hex'


module.exports = (opts) ->

  prefix    = 'HC1'

  nbrOfBytesByAction =
    '0': '00'
    '1': '00'
    '2': '00'
    '3': '06'
    '4': '06'
    '5': '00'
    '6': '01'

  payload = switch opts.action
    when 6 then opts.payload
    else reverseBytes( opts.payload )

  formatted =
    sequenceNumber  : toHex opts.sequenceNumber || 1
    networkHubMAC   : reverseBytes opts.networkHubMAC
    action          : pad opts.action
    payload         : payload
    nbrOfBytes      : nbrOfBytesByAction[ opts.action ]

  return [
    prefix
    formatted.sequenceNumber
    formatted.networkHubMAC
    formatted.action
    formatted.nbrOfBytes
    formatted.payload
  ].join ''