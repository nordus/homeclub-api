_ = require('lodash')


module.exports = (messages, roomNamesBySensorHubMacAddress) ->
  groupedMessages = _.groupBy(messages, (instance) ->
    instance.message.sensorHubMacAddress
  )

  delete groupedMessages['000000000000']

  sensorHubData = {}
  Object.keys(groupedMessages).forEach (sensorHubMacAddress) ->
    sensorHubData[sensorHubMacAddress] =
      light: []
      temp: []
      humidity: []

    groupedMessages[sensorHubMacAddress].forEach (ele, idx) ->
      isComfortDirector = String(ele.message.sensorHubType) is "2"
      o = sensorHubData[sensorHubMacAddress]
      ms = Date.UTC.apply null, ele.message.timestamp.split(/\D/)
      
      # celcius to fahrenheit         
      o["temp"].push [
        ms
        ((ele.message.sensorHubData1 * 9) / 5) + 32
      ]
      if isComfortDirector
        o["light"].push [
          ms
          ele.message.sensorHubData2
        ]
        o["humidity"].push [
          ms
          ele.message.sensorHubData3
        ]

  chartData =
    temp:
      series: []

    light:
      series: []

    humidity:
      series: []

  chartColors =
    temp: [
      "#d9534f"
      "#ebccd1"
      "#a94442"
    ]
    light: [
      "#f0ad4e"
      "#faebcc"
      "#8a6d3b"
    ]
    humidity: [
      "#5bc0de"
      "#bce8f1"
      "#31708F"
    ]

  sensorHubMacAddresses = Object.keys(sensorHubData)
  sensorHubMacAddresses.forEach (sensorHubMacAddress, sensorHubMacAddressIdx) ->
    sensorTypes = Object.keys(sensorHubData[sensorHubMacAddress])
    sensorTypes.forEach (sensorType) ->
      seriesData =
        color: chartColors[sensorType][sensorHubMacAddressIdx]
        data: sensorHubData[sensorHubMacAddress][sensorType]
        name: roomNamesBySensorHubMacAddress[sensorHubMacAddress]

      chartData[sensorType].series.push seriesData

  chartData