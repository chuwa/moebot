# Description:
#   talk to version one
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot v1 tasks
#   hubot v1 taskid todo 2
#   hubot v1 taskid complete
#
# Author:
#   mike-li

xml2js = require('xml2js')
_ = require('underscore')
_s = require('underscore.string')
cheerio = require('cheerio')
https = require('https')
Util = require "util"

username = process.env.VERSION1_USERNAME
password = process.env.VERSION1_PASSWORD

getAttr = (asset, attrName) =>
  name = _.select asset.Attribute, (att)->
    att['@']?.name == attrName
  name[0]?['#']

getRelation = (asset, relationName) =>
  name = _.select asset.Relation, (att)->
    att['@']?.name == relationName
  name[0].Asset

v1_options = {
  hostname: "www14.v1host.com"
  port: 443
  auth: "#{username}:#{password}"
  path: '/'
  method: 'GET'
}

class Task
  constructor:(asset)->
    @asset = asset
    @name = getAttr(@asset, 'Name')
    @number = getAttr(@asset, 'Number')
    @id = @asset['@']['id']
    try
      @status_id = getRelation(@asset, 'Status')['@']['idref']
    catch error
      @status_id = "! not know"
    finally
      # do nothing
    @status = @getStatus(@status_id)
    try
      owners = getRelation(@asset, 'Owners')
      if owners['length'] > 0
        ids = _.map owners,(owner)->
          MEMBERS[owner['@']['idref']]
        @member = ids.join(',')
      else
        @member = MEMBERS[owners['@']['idref']]
    catch error
      @member_id = null
    @team = getAttr(@asset, "Team.Name")
    @sprint = getAttr(@asset, "Timebox.Name")
    @scope = getAttr(@asset, "Scope.Name")
    @todo = getAttr(@asset, "ToDo") || '-'
    @estimate = getAttr(@asset, "DetailEstimate") || '-'
    @description = getAttr(@asset, "Description")?.replace(/(<([^>]+)>)/ig,"").replace('&nbsp','') || ''
    @href = "https://www14.v1host.com#{@asset['@']['href']}"

  getStatus: (status_id) =>
    map = {
      "TaskStatus:123": "In Progress"
      "TaskStatus:125": "Complete"
      "TaskStatus:37514": "Ready for Test"
      "TaskStatus:37513": "Not Started"
    }
    map[status_id]

  # update task hours
  @updateHours: (taskid,hours,callback)->
    body = """
      <Asset>
        <Attribute name="ToDo" act="set">#{hours}</Attribute>
      </Asset>
    """
    @post(taskid,body,callback)


  # make task complete
  @complete: (taskid,callback)->
    body = """
        <Asset>
          <Relation name="Status" act="set">
            <Asset href="/acxiom1/VersionOne/rest-1.v1/Data/TaskStatus/125" idref="TaskStatus:125"/>
          </Relation>
        </Asset>
    """
    @post(taskid,body,callback)

  # make the post request
  @post: (taskid,body,callback)->
    ops = _.extend(v1_options, { path:"/acxiom1/VersionOne/rest-1.v1/Data/Task/81079", method: 'POST' })
    req = https.request ops, (response)->
      result = ""
      response.on 'data', (chunk)->
        result += chunk
      response.on 'end',()->
        callback(result)
    req.write(_s.trim(body))
    req.end()

  @all: (callback)->
    https.get "https://#{username}:#{password}@www14.v1host.com/acxiom1/VersionOne/rest-1.v1/Data/Task", (res)->
      result = ""
      # append data to result
      res.on "data", (data)->
        result += data.toString()
      # yeah! got the result
      res.on "end", (data) ->
        parser = new xml2js.Parser()
        parser.parseString result, (err, result)->
         tasks =  _.map result.Asset,(t)->
           new Task(t)
         callback(tasks)

  toString: =>
    str = ""
    str += "  #{@number} #{@name}\n"
    str += "-> #{@member}" + "\n"
    str += "-> #{@status}" + "\n"
    str += "-> ESTI: " + @estimate + "\n"
    str += "-> TODO: " + @todo + "\n"
    str += "-> DESC: #{@description}"  + "\n"
    str


MEMBERS = {}
# cache memebers first
https.get "https://#{username}:#{password}@www14.v1host.com/acxiom1/VersionOne/rest-1.v1/Data/Member", (res)->
  result = ""
  # append data to result
  res.on "data", (data)->
    result += data.toString()
  # yeah! got the result
  res.on "end", (data) ->
    parser = new xml2js.Parser()
    parser.parseString result, (err, result)->
      for mem in result.Asset
        MEMBERS[mem['@'].id] = getAttr(mem,"Name")

module.exports = (robot) ->
  robot.brain.data.v1_setting ||= { sprint: 12 }

  robot.respond /v1 members$/i, (msg) ->
    msg.send Util.inspect(MEMBERS, false, 4)

  robot.respond /v1 task (.*)$/i, (msg) ->
    taskid = _s.trim(msg.match[1])
    msg.send "TODO return task info"

  robot.respond /v1 complete (.*)$/i, (msg) ->
    taskid = _s.trim(msg.match[1])
    msg.send "TODO call Task.complete('sdfsdf')"

  robot.respond /v1 set(.*)?$/i, (msg) ->
    setting = _s.trim(msg.match[1])
    settingArray = setting.split('=')
    robot.brain.data.v1_setting[settingArray[0]] = settingArray[1]
    msg.send Util.inspect(robot.brain.data.v1_setting, false, 4)

  robot.respond /v1 config$/i, (msg) ->
    msg.send Util.inspect(robot.brain.data.v1_setting, false, 4)

  # search movie
  robot.respond /v1 tasks(.*)?$/i, (msg) ->
    if not robot.brain.data.v1_setting['sprint']
      msg.send "please set 'sprint' before check tasks."
      return
    resource = "Task"
    owner = _s.trim(msg.match[1])
    Task.all (tasks)->
      for t in tasks
        continue unless t.status in ["In Progress", "Not Started"]
        continue unless t.team in ["Rapidus Front End Team"]
        continue unless t.sprint in ["MVP 1.0 Sprint #{robot.brain.data.v1_setting['sprint']}"]
        if owner.length > 0
          continue unless _s.include(t.member,owner)
        msg.send t.toString()

