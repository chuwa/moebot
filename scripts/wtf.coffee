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
#   hubot when you hear <pattern> do <something hubot does> - Setup a ear dropping event
#   hubot stop ear dropping - Stop all ear dropping
#   hubot stop ear dropping on <pattern> - Remove a particular ear dropping event
#   hubot show ear dropping - Show what hubot is ear dropping on
#
# Author:
#   glin

TextMessage = require('hubot').TextMessage

phrases = [
  'http://www.di4kj.com/upfiles/201202/20120218171708343.jpg',
  'http://image.hnol.net/c/2011-03/09/08/20110309080706261-2709668.jpg',
  'http://img839.imageshack.us/img839/1924/26476972.jpg',
  'http://www.weirdasianews.com/wp-content/uploads/2009/05/grassmudhorse01.jpg',
  'http://img1.aili.com/images/201204/09/1333958912_55872500.jpg',
  'http://dida0125.myweb.hinet.net/2/p121634246916.jpg',
  'http://www2.pic.yxdown.com/2012-1/380212788251751745309150.jpg',
  'http://www.leicn.net/attachments/120429/f3405a988170e07ee92c252278d14a29.jpg',
  'http://www.kklook.info/content/uploadfile/201111/bdf6e4ea7e289aeb03fed41413a5074020111126212421.gif',
  'http://www.qqtx.org/upimg/201008/20100823062936515.gif',
  'http://www.ccjoy.com/upload/image/%E5%9B%BE2-%E7%9C%8B%E4%BD%A0%E5%A6%B9%E6%88%90%E4%B8%BA%E6%B5%81%E8%A1%8C%E8%AF%AD.jpg',
  'http://upload.univs.cn/2011/1230/1325224781138.jpg',
  'http://www.mask9.com/sites/default/files/mt0x0001/10158/image/201112/event-nimeilaile-poster-mask9.jpg',
  'http://upfile.asqql.com/2009pasdfasdfic2009s305985-ts/2011-7/2011797212666737_asqql.com.jpg',
  'http://upfile.asqql.com/2009pasdfasdfic2009s305985-ts/2011-7/2011797212691681_asqql.com.jpg',
  'http://upfile.asqql.com/2009pasdfasdfic2009s305985-ts/2011-7/2011797212618343_asqql.com.jpg',
  'http://timg.ddmap.com/cheng/userimages/normal/2011-12-13/2011-12-13-1323758476938.jpg'
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

class EarDropping
  constructor: (@robot) ->
    @cache = []
    @robot.brain.on 'loaded', =>
      if @robot.brain.data.eardropping
        @cache = @robot.brain.data.eardropping
  add: (pattern, action) ->
    task = {key: pattern, task: action}
    @cache.push task
    @robot.brain.data.eardropping = @cache
  all: -> @cache
  deleteByPattern: (pattern) ->
    @cache = @cache.filter (n) -> n.pattern == pattern
    @robot.brain.data.eardropping = @cache
  deleteAll: () ->
    @cache = []
    @robot.brain.data.eardropping = @cache

module.exports = (robot) ->
  earDropping = new EarDropping robot

  robot.hear /your sister/i, (msg) ->
    msg.reply msg.random phrases

  robot.hear /orly/i, (msg) ->
    msg.send msg.random orlys

  robot.respond /when you hear (.+?) do (.+?)$/i, (msg) ->
    key = msg.match[1]
    task = msg.match[2]
    earDropping.add(key, task)
    msg.send "I am now ear dropping for #{key}. Hehe."

  robot.respond /stop ear *dropping$/i, (msg) ->
    earDropping.deleteAll()
    msg.send 'Okay, fine. :(  I am keep my ears shut.'

  robot.respond /stop ear *dropping (for|on) (.+?)$/i, (msg) ->
    pattern = msg.match[2]
    earDropping.deleteByPattern(pattern)
    msg.send "Okay, I will ignore #{pattern}"

  robot.respond /show ear *dropping/i, (msg) ->
    response = "\n"
    for task in earDropping.all()
      response += "#{task.key} -> #{task.task}\n"
    msg.send response

  robot.hear /(.+)/i, (msg) ->
    robotHeard = msg.match[1]
    for task in earDropping.all()
      if new RegExp(task.key).test(robotHeard)
        console.log(msg.message.user)
        console.log(robot.name)
        if (msg.message.user? && robot.name != msg.message.user.name)
    #u = robot.userForName('Hubot'.toLowerCase())
    #console.log('Hubot')
          robot.receive new TextMessage(msg.message.user, "#{robot.name}: #{task.task}")
