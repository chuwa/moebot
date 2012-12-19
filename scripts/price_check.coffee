# Description:
#   check and watch price on amazon
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot check price <url>
#
# Author:
#   mike-lee


CHECK_INTERVAL = 5000

module.exports = (robot) ->
  robot.respond /check price http(.*?)$/i, (msg) ->
    msg.send "not ready yet"
    return
    check = (message)->
      ->
        message.send "checking ...."
    checker = setInterval(check(msg), CHECK_INTERVAL)
    msg.send "checker created #{checker}"
