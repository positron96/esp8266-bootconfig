local FILE="bootstate.txt"

local mod = {}

-- returns a number of successive reboots
-- (5 secs between reboots)
function mod.saveState(s)
    --print("writing state "..s)
    file.open(FILE, "w+")
    file.write(""..s) 
    file.close()
end

function mod.getState() 
    if file.open(FILE, "r") == nil then return 0 end
    v = file.read(1)
    file.close()
    --print("read state "..v)
    return tonumber(v)
end

return mod

