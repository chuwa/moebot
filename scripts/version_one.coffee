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


class Task
  constructor:(asset)->
    @asset = asset
    @name = getAttr(@asset, 'Name')
    try
      @status_id = getRelation(@asset, 'Status')['@']['idref']
    catch error
      @status_id = "! not know"
    finally
      # do nothing
    @status = @getStatus(@status_id)
    try
      @member_id = getRelation(@asset, 'Owners')['@']['idref']
    catch error
      @member_id = null
    @member = MEMBERS[@member_id]
    @team = getAttr(@asset, "Team.Name")
    @sprint = getAttr(@asset, "Timebox.Name")
    @scope = getAttr(@asset, "Scope.Name")
    @todo = getAttr(@asset, "Todo")
    @description = getAttr(@asset, "Description")
    @href = "https://www14.v1host.com#{@asset['@']['href']}"

  getStatus: (status_id) =>
    map = {
      "TaskStatus:123": "In Progress"
      "TaskStatus:125": "Complete"
      "TaskStatus:37514": "Ready for Test"
      "TaskStatus:37513": "Not Started"
    }
    map[status_id]

  toString: =>
    str = ""
    str += " #{@name}\n"
    str += "--> #{@member}" + "\n"
    str += "--> #{@status}" + "\n"
    str += "TODO: " + @todo + "\n"
    str += @description  + "\n"
    str

v1_options = {
  hostname: "www14.v1host.com"
  port: 443
  auth: "#{username}:#{password}"
  path: '/'
  method: 'GET'
}

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
  # search movie
  robot.respond /v1 tasks(.*)?$/i, (msg) ->
    resource = "Task"
    result = ""
    owner = _s.trim(msg.match[1])
    https.get "https://#{username}:#{password}@www14.v1host.com/acxiom1/VersionOne/rest-1.v1/Data/#{resource}", (res)->
      # append data to result
      res.on "data", (data)->
        result += data.toString()
      # yeah! got the result
      res.on "end", (data) ->
        parser = new xml2js.Parser()
        parser.parseString result, (err, result)->
          for task in result.Asset
            t = new Task(task)
            continue unless t.status in ["In Progress", "Not Started"]
            continue unless t.team in ["Rapidus Front End Team"]
            continue unless t.sprint in ["MVP 1.0 Sprint 12"]
            if owner.length > 0
              continue unless (t.member == owner)
            msg.send t.toString()

