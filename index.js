require('coffee-script/register');

var express         = require('express'),

    cookieParser    = require('cookie-parser'),
    session         = require('express-session'),
    passport        = require('passport'),

    app             = module.exports = express(),
    bodyParser      = require('body-parser'),
    db              = require('./config/db'),  // connect to our database

    envConfig       = require('./config/env-config'),
    MongoStore      = require('connect-mongo')(session);

var port    = process.env.PORT || 3000;
console.log('port: ', port);

require('./config/passport')(passport);  // pass passport for configuration

// read cookies (needed for auth)
// required before session.
app.use(cookieParser());

app.use(bodyParser());  // get information from html forms

app.use(session({
  secret  : 's3ss10ns3cr3t',
  store   : new MongoStore({
    url: envConfig.db
  })
}));

app.use(passport.initialize());
app.use(passport.session());  // persistent login sessions

var router = express.Router();
// load our routes and pass in our app and fully configured passport
require('./config/routes')(router, passport);
app.use(router);

if (process.env.STANDALONE) {
  var server = app.listen(port);
    
  module.exports = server;
} else {

  module.exports = app;
}