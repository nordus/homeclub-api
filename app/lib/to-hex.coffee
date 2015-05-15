
module.exports = ( num ) ->
  int = parseInt num
  b   = new Buffer( 2 )
  b.writeUInt16LE int, 0

  b.toString 'hex'