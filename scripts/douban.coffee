# Description:
#   check ratings from douban by given item
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot movie <movie>
#   hubot music <music>
#   hubot book <book>
#
# Author:
#   mike-li

xml2js = require('xml2js')
_ = require('underscore')
cheerio = require('cheerio')

api = (kind,query)->
  "http://api.douban.com/#{kind}/subjects?q=#{query}"

human_body = (xml,msg)->
  parser = new xml2js.Parser()
  parser.parseString xml, (err, result)->
    message = ""
    unless result.entry
      message += ':-( ... find nothing...'
    else
      message += "find #{result.entry.length} results : \n"
      for entry in result.entry
        pubdate = _.select entry['db:attribute'],(attr)->
          attr['@']?.name == 'pubdate'
        link = _.select entry['link'],(attr)->
          attr['@']?.rel == 'alternate'
        message += "#{entry.title}(#{pubdate[0]?['#']} #{entry.author?.name}) ------- #{entry['gd:rating']['@']?.average}  \n"
        message += "#{link[0]['@']?.href}\n\n"
    msg.send message

module.exports = (robot) ->
  # search movie
  robot.respond /movie (.+)$/i, (msg) ->
    msg.http(api('movie',msg.match[1]))
      .get() (err,res,body) ->
        msg.send 'let me check it out....'
        human_body(body,msg)
  # serach music
  robot.respond /music (.+)$/i, (msg) ->
    msg.http(api('music',msg.match[1]))
      .get() (err,res,body) ->
        msg.send 'let me check it out....'
        human_body(body,msg)
  # search book
  robot.respond /book (.+)$/i, (msg) ->
    msg.http(api('book',msg.match[1]))
      .get() (err,res,body) ->
        msg.send 'let me check it out....'
        human_body(body,msg)

  # listen the movie or books that you hear about douban
  robot.hear /(.*douban\.com\/subject.*)/i,(msg) ->
    msg.http(msg.match[1])
      .get() (err,res,body) ->
        $ = cheerio.load body
        # scrap infos
        title = $("#wrapper h1 span").text()
        image = $("#mainpic img")[0].attribs.src
        point = $("strong.rating_num").text()
        descript = $("#link-report").text()
        msg.send title
        msg.send image
        msg.send "Average:#{point}"
        msg.send descript
