# Description:
#   update your daily updates
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot daily
#   hubot report <you today updates>
#
# Author:
#   mike-li

_ = require('underscore')
_s = require('underscore.string')
Util = require "util"

robot.brain.data.daily_updates ||= {}

module.exports = (robot) ->

  robot.respond /daily$/i, (msg) ->
    msg.send Util.inspect(robot.brain.data.daily_updates, false, 4)

  robot.respond /report (.*)$/i, (msg) ->
    status = _s.trim(msg.match[1])
    if status.length == 0
      msg.send "Come dude, do something! "
    else
      today = new Date().toDateString()
      robot.brain.data.daily_updates[today] ||= {}
      robot.brain.data.daily_updates[today][msg.message.user.name] ||= {}
      robot.brain.data.daily_updates[today][msg.message.user.name] += " #{status} "
      msg.send robot.brain.data.daily_updates[today][msg.message.user.name]

