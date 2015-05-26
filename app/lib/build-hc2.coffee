
pad           = require './pad'
reverseBytes  = require './reverse-bytes'
toHex         = require './to-hex'

toCelcius = (f) ->
  Math.floor (f - 32) * 5 / 9


module.exports = (opts) ->

  prefix    = 'HC2'

  formatted =
    sequenceNumber      : toHex opts.sequenceNumber || 1
    networkHubMAC       : reverseBytes opts.networkHubMAC
    action              : pad opts.action
    sensorHubMAC        : reverseBytes opts.sensorHubMAC
    # does not apply if we are sending via SMS
    nbrOfBytes          : '10'
    temperatureMax      : toHex toCelcius( opts.temperatureMax )
    temperatureMin      : toHex toCelcius( opts.temperatureMin )
    lightMax            : toHex opts.lightMax
    lightMin            : toHex opts.lightMin
    humidityMax         : toHex opts.humidityMax
    humidityMin         : toHex opts.humidityMin
    # 1 byte
    movementSensitivity : toHex opts.movementSensitivity, 1
    wakeupInterval      : 'FF'
    reportingInterval   : 'FF'
    resetFlag           : '00'


  return [
    prefix
    formatted.sequenceNumber
    formatted.networkHubMAC
    formatted.action
    formatted.sensorHubMAC
    formatted.nbrOfBytes
    formatted.temperatureMax
    formatted.temperatureMin
    formatted.lightMax
    formatted.lightMin
    formatted.humidityMax
    formatted.humidityMin
    formatted.movementSensitivity
    formatted.wakeupInterval
    formatted.reportingInterval
    formatted.resetFlag
  ].join('').toUpperCase()