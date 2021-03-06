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
#   hubot daily -- show daily reports
#   hubot report <you today updates> -- clear your today daily report
#
# Author:
#   mike-li

_ = require('underscore')
_s = require('underscore.string')
Util = require "util"

nice_print = (data) ->
  Util.inspect(data, false, 4)

module.exports = (robot) ->
  robot.brain.data.daily_updates ||= {}

  robot.respond /daily(.*)?$/i, (msg) ->
    if _s.trim(msg.match[1]) == "all"
      msg.send nice_print(robot.brain.data.daily_updates)
    else
      today = new Date().toDateString()
      robot.brain.data.daily_updates[today] ||= {}
      msg.send "--------- #{today} ---------\n #{Util.inspect(robot.brain.data.daily_updates[today], false, 4)}"

  robot.respond /clear report$/i, (msg) ->
    today = new Date().toDateString()
    robot.brain.data.daily_updates[today] ||= {}
    robot.brain.data.daily_updates[today][msg.message.user.name] = []
    msg.send "You've done nothing today.."

  robot.respond /report(.*)$/i, (msg) ->
    status = _s.trim(msg.match[1])
    if status.length == 0
      msg.send "Come dude, do something! "
    else
      today = new Date().toDateString()
      robot.brain.data.daily_updates[today] ||= {}
      robot.brain.data.daily_updates[today][msg.message.user.name] ||= []
      robot.brain.data.daily_updates[today][msg.message.user.name].push status
      msg.send robot.brain.data.daily_updates[today][msg.message.user.name].join(";")

