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
  "Your brother's sister"
]

olys = [
  'http://anongallery.org/img/3/5/o-rly-orly-owl.jpg'
]

module.exports = (robot) ->
  robot.hear /your sister/i, (msg) ->
    msg.send msg.random phrases

  robot.hear /orly/i, (msg) ->
    msg.send msg.random orlys
