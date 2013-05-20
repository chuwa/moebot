# Description:
#   Poll "Someone"'s qq signature automatically and notify related people..
#
# Commands:
#   hubot signature - Display it now
#   hubot signature <the qq number> - Display the signature of the specified user, added me as a contact first :)
#   hubot signature clear - Clear the signature history
#
# Author:
#   samsonw

Util = require "util"
request = require 'request'
cheerio = require('cheerio')
CronJob = require('cron').CronJob

FREQUENCY = '0 */15 * * * *' # every 15 mins
ROOM = "24958__chuwa@conf.hipchat.com" # _chuwa room

# interested QQ number
QQ = '335482714'

class Signature
  constructor: (robot, qq=QQ) ->
    @robot = robot
    @qq = qq

  fetch: (quiet=false) ->
    signatures = @robot.brain.data.signatures
    request {
        method: 'GET'
        uri: 'http://user.qzone.qq.com/791839118/infocenter'
        headers: {
          cookie: 'uin=o0791839118; skey=@CfbHYjHSC'
          # 'user-agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_3 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) CriOS/26.0.1410.53 Mobile/10B329 Safari/8536.25'
        }
      }, (error, response, body) =>
        [updated, currentSigns] = [false, []]
        $ = cheerio.load body
        $(".f_nick a[link=nameCard_#{@qq}]").each (i, el) ->
          currentSigns.unshift $(el).closest('.f_nick').siblings('.f_info').text()

        for sign in currentSigns
          if signatures.indexOf(sign) is -1
            # new signature
            updated = true
            signatures.unshift sign
            @robot.messageRoom ROOM, "New Signature: #{sign}"

        @robot.messageRoom ROOM, "Nothing new." if not updated and not quiet

module.exports = (robot) ->
  robot.brain.data.signatures ||= []

  fetchSignature = new CronJob FREQUENCY, ->
                      new Signature(robot).fetch true

  fetchSignature.start()

  robot.respond /signature$/i, (msg) ->
    new Signature(robot).fetch()

  robot.respond /signature (\d*)$/i, (msg) ->
    new Signature(robot, msg.match[1].trim()).fetch()

  robot.respond /signature clear$/i, (msg) ->
    robot.brain.data.signatures = []
    robot.messageRoom ROOM, "Cleared."

