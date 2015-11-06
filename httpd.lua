-- Simple NodeMCU web server (done is a not so nodeie fashion :-)
--
-- Written by Scott Beasley 2015
-- Open and free to change and use. Enjoy.
--
-- positron: code is based on http://letsmakerobots.com/blog/jscottb/nodemcu-esp8266-simple-httpd-web-server-example

local utils = require("utils")

local requestTable = {}

local function setHandlerTable(tt) 
    requestTable = tt
end


-- Build and return a table of the http request data
local function parseHttpRequest (req)
   local res = {}
   res.headers = {}
   local first = nil
   local key, v, strt_ndx, end_ndx

   local trim = utils.trim
   local decode = utils.decodeUrl
   local split = utils.split

   for str in string.gmatch (req, "([^\n]+)") do
      -- First line in the method and path
      if (first == nil) then
         first = 1
         str = decode(str)
         parts = split(str, " ")
         res.method = trim( parts[1] )
         assert( res.method:upper() == "GET", "Only GET Requests supported")
         req = trim(parts[2])
         res.request = req
         res.httpVer = trim(parts[3])
         start_ndx = string.find( req, "\?")
         if start_ndx ~= nil then
            res.path = string.sub(req, 0, start_ndx-1)
            qq = string.sub(req, start_ndx+1 )
            parts = split(qq, "\&")
            res.parameters = {}
            for i,q in pairs(parts) do
                kv = split(q,"=")
                --print("have q "..q..", split into '"..kv[1].."' and '"..kv[2].."'")
                k = trim( kv[1] )
                v = trim( kv[2] )
                res.parameters[k] = v
            end
         else
            res.path=req
         end
         
      else -- Process remaining ":" headers
         strt_ndx, end_ndx = string.find (str, "([^:]+)")
         if (end_ndx ~= nil) then
            v = utils.trim (string.sub (str, end_ndx + 2))
            key = utils.trim (string.sub (str, strt_ndx, end_ndx))
            res.headers[key] = v
         end
      end
   end

   return res
end


local function connect (conn, data)
    conn:on ("receive",
    function (conn, req)
        local queryData=""
        s,err = pcall( function() queryData = parseHttpRequest(req) end)
        local out,code
        if not s then
            out = "Bad request: "..err
            code = 400
        else
            local path = queryData.path;
            print (queryData.method .. " '" .. path .. "'")
            
            local fn = requestTable[path] ;
            if fn ~= nil 
            then
                out,code = fn(queryData)
            else
                code=404
                out="Not Found"
            end
        end
        local reply = {
            "HTTP/1.0 "..code.." NA",
            "Server: PositronESP (nodeMCU)",
            "Content-Length: "..out:len(),
            "",
            out
        }
        conn:send( utils.join(reply, "\r\n") )
        conn:close()
        collectgarbage()
    end )
end

return { connect=connect, setHandlerTable=setHandlerTable }

