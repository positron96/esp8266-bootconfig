local utils=require("utils")

local M = {
    proxy=nil,
    proxyport=nil,
    M_GET="GET",
    M_POST="POST",
    M_PUT="PUT"
}

function M.geturl(arg)
    local addr=arg.host
    local path=arg.path
    
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
        table.insert(request, "")
    end
    conn=net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload) 
        s, err = pcall(function() resp = resp..payload end)  
        if not s then
            print("Error: "..err)
            conn:close()
        end      
    end )
    conn:on("connection", function(c)
        local s = utils.join(request, "\r\n");
        --for i,s in pairs(request) do
        --    print ("sending "..s)
            
        --end
        conn:send(s) 
    end)
    conn:on("disconnection", function(c)
        if arg.cb ~= nil then pcall( function() arg.cb(resp) end)  end
    end)
    
    local realaddr = M.proxy~=nil and M.proxy or addr
    local realport = M.proxyport~=nil and M.proxport or 80
    conn:connect(realport, realaddr)
end

return M
