local res = dofile("wifi.lua")
if res then 
    print "Normal run, starting main.lua"
    dofile("main.lua") 
end
