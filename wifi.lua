local checkbt = require "bootcheck"
local utils = require "utils"

local state = checkbt.getState()
if checkbt.getState() >= 3 then
    print("starting bootconfig")
    dofile("bootconf.lua")
    checkbt.saveState(0)
    return false
end

checkbt.saveState(state+1)
tmr.alarm(5, 5000, 0, function()
   checkbt.saveState(0)
end)

local maxLeft = 10
local left = maxLeft
local checkIPTimer = 4
local function checkIP()
  left = left-1
  if left==maxLeft-1 then
    tmr.alarm(checkIPTimer, 2000, 1, checkIP )
  end
  local ip = wifi.sta.getip()
  if ip ~= nil 
  then 
      print("IP:"..ip) 
      tmr.stop(checkIPTimer)
  else 
      print("No IP yet")  
      if left==0 then tmr.stop(checkIPTimer) end
  end  
  
end


if file.open("wificonfig.txt", "r") ~= nil then
    local ap = utils.trim(file.readline())
    local pass = utils.trim(file.readline())
    file.close()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(ap, pass)
    checkIP()
    return true
else
    print("no wificonfig.txt, starting bootconfig")
    dofile("bootconf.lua")
    return false
end
