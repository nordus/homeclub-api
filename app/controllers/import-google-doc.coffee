async   = require('async')
https   = require('follow-redirects').https
db      = require('../../config/db')
{CustomerAccount, User}  = db.models

getSpreadsheet = (spreadsheetKey, cb) ->
  googleScriptUrl = "https://script.google.com/macros/s/AKfycbx3jmVRO3gvAhRg_kNu1VJQoAojez3Yqr8oP2fsff3ah2XVMj4/exec?spreadsheetKey=#{spreadsheetKey}"

  https.get googleScriptUrl, (response) ->
    body = ''
    response.on 'data', (data) -> body += data
    response.on 'end', ->
      accounts = JSON.parse body
      cb(accounts)


exports.preview = (req, res) ->
  spreadsheetKey = req.body.url.match(/key=([a-z|A-Z|0-9]*)/).pop()

  getSpreadsheet spreadsheetKey, (accounts) ->
    emails = accounts.map (account) ->
      account.email

    User.find
      email:
        $in: emails
    , 'email'
    , (err, duplicateUsers) ->
        if duplicateUsers.length
          duplicateEmails = duplicateUsers.map (user) -> user.email
          duplicateAccounts = accounts.filter (account) ->
            account.email in duplicateEmails
          res.json
            duplicateAccounts: duplicateAccounts
        else
          res.json
            accounts: accounts


exports.create = (req, res) ->
  async.parallel
    users: (cb) ->
      User.create req.body.accounts, cb
    customerAccounts: (cb) ->
      CustomerAccount.create req.body.accounts, cb
  , (e, r) ->
    r.users.forEach (user, idx) ->
      user.link 'customerAccount', r.customerAccounts[idx]

    res.json 200