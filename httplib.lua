local utils=require("utils")

local M = {
    proxy=nil,
    proxyport=nil,
    M_GET="GET",
    M_POST="POST",
    M_PUT="PUT"
}

-- Build and return a table of the http response data
function M.parseHttpResponse (req)
   local res = {}
   res.headers = {}
   local first = nil
   local key, v, strt_ndx, end_ndx

   local trim = utils.trim
   local decode = utils.decodeUrl
   local split = utils.split
   --print("parsing string '"..req.."'") 
   for str in string.gmatch (req, "([^\n]+)") do
      -- First line in the method and path
      if (first == nil) then
         first = 1
         str = decode(str)
         parts = split(str, " ")
         res.code = tonumber(trim( parts[2] ) )
         res.codetext = trim(parts[3])
         res.request = req
         res.httpVer = trim(parts[1])
         
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


function M.geturl(arg)
    local addr=arg.host
    local path=arg.path
    local finished = false
    
    if path==nil then path="/" end
    local resp=""
    local method = M.M_GET
    if arg.method ~= nil then method=arg.method end
    local request = {
            method.." "..path.." HTTP/1.1",
            "Host: "..addr,
            "Connection: close",
            "Accept: */*" }
    if arg.headers ~= nil then
        for k,v in pairs(arg.headers) do
            table.insert(request, v )
        end
    end
    
    if (method==M.M_POST or method==M.M_PUT) and (arg.data~=nil) then
        --request = request .. arg.data
        table.insert(request, "Content-Length: "..string.len(arg.data) )
        table.insert(request, "")
        table.insert(request, arg.data)
    else
        table.insert(request, "\r\n")
    end
    conn=net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload) 
        local s, err = pcall(function() resp = resp..payload end)  
        if not s then
            print("Error: "..err)
            conn:close()
        end      
    end )
    conn:on("connection", function(c)
        local s = utils.join(request, "\r\n")
        --print ("Sending "..s)
        conn:send(s) 
    end)
    conn:on("disconnection", function(c)
        local res=M.parseHttpResponse(resp)
        if arg.cb ~= nil then 
            local s,err = pcall( function() arg.cb(res) end)  
            if not s then
                print("Callback error: "..err)
                conn:close()
            end   
        end
    end)
    
    local realaddr = M.proxy~=nil and M.proxy or addr
    local realport = M.proxyport~=nil and M.proxyport or 80
    --print("Connecting to "..realaddr..":"..realport)
    conn:connect(realport, realaddr)
    if arg.blocking ~= nil and arg.blocking then
        while not finished do
            tmr.delay(500000)
        end
    end
end

return M
