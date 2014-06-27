# # HomeClub API

 - ensures no app talks directly to the database
 - provides JSON data which is consumed by web and mobile apps
 - hooks into the homeclub-auth module, which determines read/write
   permissions (based on who is making the request)
 - by default, this module does not expose an HTTP interface.  it is
   simple mounted by other web/mobile application servers, which use it
   internally. this provides an extra layer of security, as the
   outside world cannot access our data directly.