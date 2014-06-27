{WaterSource} = require('./config/db').models

waterSourceNames = ["AC unit", "Aquarium", "Clothes Washer", "Dishwasher", "Humidifier", "Pool and Fountain", "Radiator", "Refrigerator", "Sink", "Sump Pump", "Toilet", "Tub & shower", "Water Heater", "Water Pipe (water supply line)"]

for waterSourceName in waterSourceNames
  WaterSource.create name:waterSourceName, (e, waterSourceDoc) ->
    console.log e || waterSourceDoc