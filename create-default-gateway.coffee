{CustomerAccount, Gateway, User} = require('./config/db').models


User.findOne email:'tgl@senteri.com', (e, user) ->
  CustomerAccount.findOne user.roles.customerAccount, (e, account) ->
    gatewayAttrs =
      _id             : '0007806773EE'
      customerAccount : account
      
    Gateway.create gatewayAttrs, (e, gateway) ->
      
      console.log e || gateway

      account.gateways.addToSet(gateway._id)
      #account.gateways.push gateway
      account.save (e) ->
        console.log e || account