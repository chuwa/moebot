# Description:
#   search amazon ratings
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot amazon <query>
#
# Author:
#   mike-lee

cheerio = require('cheerio')

api = (query)->
  "http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=#{query}"

module.exports = (robot) ->
  robot.respond /amazon (.+)$/i, (msg) ->
    msg.send 'let me check it out....'
    msg.http(api(msg.match[1]))
      .get() (err,res,body) ->
        $ = cheerio.load body
        message = ""
        for result in $("#atfResults > div,#btfResults > div")
          message += "#{$(result).find('.newaps a span').text()} -- (#{$(result).find(".asinReviewsSummary>a").attr('alt')})\n"
          message += "#{$(result).find('.newaps a').attr('href')}\n\n"
        msg.send message
