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

REPO_URL = "git@github.com:chuwa/moebot.git"
PID_FILE = "pid_file.pid"

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
