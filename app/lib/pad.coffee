
module.exports = ( num, length = 2 ) ->

  str = String( num )

  return str  if str.length is length

  zeros = new Array( length + 1 ).join( '0' )

  return ( zeros + str ).slice( -1 * length )