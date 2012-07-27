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

module.exports = (robot) ->
  robot.hear /your sister/i, (msg) ->
    msg.send msg.random phrases
