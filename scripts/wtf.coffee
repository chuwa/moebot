# Description:
#   wtf
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#
# Author:
#   glin

phrases = [
  "Your brother",
  "Your sister",
  "Your sister's brother",
  "Your brother's sister",
  "Your mama",
  "Your sister's sister"
]

orlys = [
  'http://anongallery.org/img/3/5/o-rly-orly-owl.jpg',
  'http://i629.photobucket.com/albums/uu11/LordSlashstab/OrlyAsian.jpg',
  'http://kijopics.com/images/Anime/orly.jpg',
  'http://i670.photobucket.com/albums/vv66/Cameraman21/OrlyTaitzOwl.jpg',
  'http://www.chrisabraham.com/orly-thumb.jpg',
  'http://www.pr0gramm.com/data/images/2008/12/78394-orly-owl.jpg',
  'http://i20.photobucket.com/albums/b219/70camaro/O%20rly%20and%20Funny%20Pics/pirate-orly.jpg',
  'https://forums.playfire.com/_proxy/?url=http%3A%2F%2Fwww.netlore.ru%2Ffiles%2Fuploads%2F2007%2F05%2Forly-3.jpg&hmac=64ede448f1835a0241f64d50bcb9e3d5',
  'http://i136.photobucket.com/albums/q170/skisteve/o-rly-vader.jpg',
  'http://i136.photobucket.com/albums/q170/skisteve/O_Rly4.jpg',
  'http://i136.photobucket.com/albums/q170/skisteve/ja_rly.jpg',
  'http://i136.photobucket.com/albums/q170/skisteve/ya_rly_doom.jpg',
  'http://i136.photobucket.com/albums/q170/skisteve/hlblyorly.gif',
  'http://fc08.deviantart.net/fs8/i/2005/346/0/5/More___O_RLY____Owl__by_Goldsickle.jpg'
]

module.exports = (robot) ->
  robot.hear /your sister/i, (msg) ->
    msg.reply msg.random phrases

  robot.hear /orly/i, (msg) ->
    msg.send msg.random orlys
