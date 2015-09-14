require('coffee-script/register');

var express         = require('express'),

    csv             = require('express-csv'),

    cookieParser    = require('cookie-parser'),
    session         = require('express-session'),
    passport        = require('passport'),

    app             = express(),
    bodyParser      = require('body-parser'),
    db              = require('./config/db'),  // connect to our database

    envConfig       = require('./config/env-config'),
    MongoStore      = require('connect-mongo')(session),
    port            = process.env.PORT || 3000,

    expressJwt      = require('express-jwt');


function gracefulExit() {
  db.connection.close( function() {
    console.log( '.. DATABASE CONNECTION CLOSED' );
    process.exit( 0 );
  })
}

process.on( 'SIGINT', gracefulExit ).on( 'SIGTERM', gracefulExit );

require('./config/passport')(passport);  // pass passport for configuration

// read cookies (needed for auth)
// required before session.
app.use(cookieParser());

app.use(bodyParser());  // get information from html forms

var allowCrossDomain = function(req, res, next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  next();
};
app.use(allowCrossDomain);

app.use(session({
  secret            : 's3ss10ns3cr3t',
  resave            : false,
  saveUninitialized : true,
  store             : new MongoStore({
    //url: envConfig.db
    mongooseConnection: db.connection
  })
}));

app.use(passport.initialize());
app.use(passport.session());  // persistent login sessions

app.use(expressJwt({
  secret          : 's3ss10ns3cr3t',
  getToken        : function( req ) {
    if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer') {
      return req.headers.authorization.split(' ')[1];
    } else if (req.query && req.query.token) {
      return req.query.token;
    }
    return null;
  }
}).unless({
  path            : ['/login', /\/webhooks.*/, /\/me.*/, /\/sms/],
  useOriginalUrl  : false
}));

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