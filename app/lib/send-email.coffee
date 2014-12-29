email = require('emailjs/email')

server = email.server.connect
  user: 'tgl@nordustech.com'
  password: '7FesvdnRxOBqSRtg-zBtGA'
  host: 'smtp.mandrillapp.com'
  ssl: true

module.exports = (options, cb) ->
  {recipientEmail, subject, body} = options
  # send the message and get a callback with an error or details of the message that was sent
  server.send
    text: body
    from: 'HomeClub Alert <alert@homeclub.us>'
    to: recipientEmail
    subject: subject || ''
  , cb