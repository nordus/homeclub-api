
module.exports = ( num, numBytes = 2 ) ->
  int = parseInt num
  b   = new Buffer( numBytes )

  if numBytes is 2
    b.writeUInt16LE int, 0

  if numBytes is 1
    b.writeUInt8 int, 0

  b.toString 'hex'