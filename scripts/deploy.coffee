# Description:
#   let hubot update it self
#   deploy itself to server
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot update
#
# Author:
#   mike-lee

sys = require('sys')
exec = require('child_process').exec

PID_FILE = "pid_file.pid"

DEPLOY_DIR = {
  "rapidus": "/home/mike/apps/rapidus",
  "moebot" : "git@github.com:chuwa/moebot.git"
}

module.exports = (robot) ->
  # update self
  # 1.git pull repo
  # 2.kill self(relax man, I have bluepill :-))
  robot.respond /update$/i, (msg) ->
    child = exec "git pull origin master",(error, stdout, stderr) ->
      msg.send "update my blood...."
      msg.send stdout
      msg.send "reborn....."
      exec "kill `cat #{PID_FILE}`", (error, stdout, stderr) ->
        msg.send error
        msg.send stdout
        msg.send stderr

  robot.respond /war (.*)$/i, (msg) ->
    dir = DEPLOY_DIR[msg.match[1]]
    child = exec "cd #{dir} && git pull origin master",(error, stdout, stderr) ->
      msg.send "update source codes...."
      msg.send stdout
      msg.send "restart....."
      exec "cd #{dir} && rvm use jruby && bundle exec rake assets:precompile && rake war", { env:process.env }, (error, stdout, stderr) ->
        msg.send error
        msg.send stdout
        msg.send stderr
