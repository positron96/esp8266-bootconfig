local FILE="bootstate.txt"

local M = {}

local state

-- returns a number of successive reboots
-- (5 secs between reboots)
local function saveState(s)
    --print("writing state "..s)
    if file.open(FILE, "w+") == nil then
        -- try delete
        print("bootconfig file corrupted and cannot be written to! Trying to recreate")
        file.remove(FILE)
        if file.open(FILE, "w+") == nil then 
            print("could not recreate, memory damaged")
            return
            end
        end
    file.write(""..s) 
    file.close()
end

local function getState() 
    if file.open(FILE, "r") == nil then return 0 end
    v = file.read(1)
    file.close()
    if v==nil then return 0 end
    print("read state "..v)
    return tonumber(v)
end

function M.checkBoot() 
    state = getState() 
    saveState(state+1)
    tmr.alarm(5, 5000, 0, function()
        saveState(0)
    end)
    return M.isConfBoot()
end

function M.isConfBoot()
    return state >= 2
end

function M.resetState()
    saveState(0)
end

return M

