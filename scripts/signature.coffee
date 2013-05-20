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

request = require 'request'
cheerio = require 'cheerio'
CronJob = require('cron').CronJob

FREQUENCY = '0 */15 * * * *' # every 15 mins
ROOM = "24958__chuwa@conf.hipchat.com" # _chuwa room

# Default Target QQ number
TargetQQ = '335482714'

class Signature
  constructor: (robot, qq=TargetQQ) ->
    @robot      = robot
    @qq         = qq
    @info       = robot.brain.data.signatures.info
    @signatures = robot.brain.data.signatures.data

  fetch: (quiet=false) ->
    # get key info from external site so i don't have to expose someone's qq password here
    # the remote info.json will be updated automatically
    request.get 'http://q.chuwa.us/info.json',
      auth:
        user: 'qq',
        pass: 'passw0rd',
        sendImmediately: true
      (error, response, body) =>
        @info = JSON.parse body unless error
        request {
            method: 'GET'
            uri: "http://user.qzone.qq.com/#{@info.qq}/infocenter"
            headers: {
              cookie: "uin=o0#{@info.qq}; skey=#{@info.skey}"
            }
          }, (error, response, body) =>
            [updated, currentSigns] = [false, []]
            $ = cheerio.load body
            $(".f_nick a[link=nameCard_#{@qq}]").each (i, el) ->
              currentSigns.unshift $(el).closest('.f_nick').siblings('.f_info').text()

            for sign in currentSigns
              if @signatures.indexOf(sign) is -1
                # new signature
                updated = true
                @signatures.unshift sign
                console.info "New Signature: #{sign}"
                @robot.messageRoom ROOM, "New Signature: #{sign}"

            @robot.messageRoom ROOM, "Nothing new." if not updated and not quiet


module.exports = (robot) ->
  robot.brain.data.signatures ||= {info: {}, data: []}

  fetchSignature = new CronJob FREQUENCY, ->
                      new Signature(robot).fetch true

  fetchSignature.start()

  robot.respond /signature$/i, (msg) ->
    new Signature(robot).fetch()

  robot.respond /signature (\d*)$/i, (msg) ->
    new Signature(robot, msg.match[1].trim()).fetch()

  robot.respond /signature clear$/i, (msg) ->
    robot.brain.data.signatures.data = []
    robot.messageRoom ROOM, "Cleared."

