
module.exports = ( str ) ->

  return ''  if str is undefined

  out   = ''
  match = str.match /\w{2}/g

  unless match is null
    out = match.reverse().join ''

  out