httpd = require "httpd"

local SSID = "ESP8266-Config"

local function getFile(ff) 
    if file.open(ff, "r") ~= nil then
        res = file.read()
        file.close()
        return res
    else
        return nil
    end
end

local requestTable = {
    ["/"] = function(req) 
        res = getFile("index.html")
        if res==nil then return "File error", 500 end
        return res, 200        
        end,
    ["/set"] = function(req) 
        print("ap:"..req.parameters.ap.."; password:"..req.parameters.pass)
        file.open("wificonfig.txt", "w+")
        file.writeline(req.parameters.ap)
        file.writeline(req.parameters.pass)
        file.close()
        tmr.alarm (1, 5000, 0, function()
          if srv ~= nil then srv:close() end
          node.restart()
          end )
        return "Saved. Device will restart in 5 sec.", 200 
        end,
}

print("Bootconfig mode. Connect to AP "..SSID)

httpd.setHandlerTable( requestTable )

-- Configure the ESP as an ap
wifi.setmode (wifi.SOFTAP)
wifi.ap.config{ ssid=SSID }

-- Create the httpd server
if srv ~= nil then
    srv:close()
    print "Closing existing server"
end
srv = net.createServer (net.TCP, 30)


-- Server listening on port 80, call connect function if a request is received
srv:listen (80, httpd.connect)
