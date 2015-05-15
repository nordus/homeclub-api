
reverseBytes = require './reverse-bytes'

toCelcius = (f) ->
  (f - 32) * 5 / 9

zeroOrGreater = (n) ->
  if n >= 0 then n else 0


toHex = (num, bytes = 2) ->
  if isNaN( num )
    return '0000'
  else
    int = parseInt( num )
    b = new Buffer( bytes )
    if bytes == 1
      b.writeUInt8 int, 0
      # reversing to match examples
      # TODO: [DRJ] ensure this is correct
      b.toString('hex').split('').reverse().join ''
    else
      b.writeUInt16LE int, 0
      b.toString 'hex'

module.exports = (sensorHub, networkHub) ->

  out             = {}
  pendingCommands = sensorHub.latestOutboundCommand.params

  customThresholdOrDefault = (attr) ->
    pendingCommands[attr] or 'FF'


  for sensorType in ['humidity', 'light', 'temperature']
    for minOrMax in ['Min', 'Max']

      k       = "#{sensorType}#{minOrMax}"
      v       = pendingCommands[k]

      if v

        if sensorType is 'temperature'
          v = toCelcius( v )
          v = zeroOrGreater( v )

        v = toHex( v )

      out[k]  = v or 'FFFF'

  stringPieces = [
    'HC2'
    toHex( 1 )      # Sequence Number from Gateway
    reverseBytes( networkHub._id )
    toHex( 2, 1 )   # Action.  2nd value is # of bytes.
    reverseBytes( sensorHub._id )
    toHex( 1 )      # Payload Size.  does not apply if we are sending via SMS.
    toHex( out.temperatureMax )
    toHex( out.temperatureMin )
    toHex( out.lightMax )
    toHex( out.lightMin )
    toHex( out.humidityMax )
    toHex( out.humidityMin )
    customThresholdOrDefault( 'movementSensitivity' ) # '1F'
    customThresholdOrDefault( 'wakeupInterval' )      # '40'
    customThresholdOrDefault( 'reportingInterval' )   # '0A'
    '00'            # resetFlag
  ]


  stringPieces.join ''