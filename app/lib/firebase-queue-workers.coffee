
Firebase  = require 'firebase'
Queue     = require 'firebase-queue'
ref       = new Firebase 'https://homeclub-q.firebaseio.com'
queueRef  = ref.child 'queue'


new Queue queueRef, ( data, progress, resolve, reject ) ->

  {macAddress, msgType, rssi, updateTime}                 = data
  networkHubAlert   = msgType is 2
  sensorHubAlert    = msgType is 4
  sensorHubReading  = msgType is 5
  {gatewayBattery:battery, gatewayEventCode:powerSource}  = data  if networkHubAlert
  {sensorEventEnd, sensorEventStart}                      = data  if sensorHubAlert
  {sensorHubType}                                         = data  if sensorHubReading
  {sensorHubBattery, sensorHubMacAddress, sensorHubRssi}  = data  if sensorHubAlert or sensorHubReading

  latestRef         = ref.child macAddress


  if networkHubAlert and powerSource in [1,2]
    latestRef.child( 'latestPowerStatus' ).set {battery, powerSource, updateTime}


  if sensorHubAlert
    sensorHubAlertRef = latestRef.child "sensorHubs/#{sensorHubMacAddress}/latestAlert"
    sensorHubAlertRef.update {sensorEventEnd, sensorEventStart, sensorHubBattery, sensorHubRssi, updateTime}


  if sensorHubReading
    sensorHubRef =  latestRef.child "sensorHubs/#{sensorHubMacAddress}/"
    reading  = {sensorHubBattery, sensorHubRssi, sensorHubType, updateTime}
    ['sensorHubData1', 'sensorHubData2', 'sensorHubData3'].forEach ( k ) ->
      unless data[k] is undefined
        reading[ k ] = data[k]

    sensorHubRef.update reading


  resolve data