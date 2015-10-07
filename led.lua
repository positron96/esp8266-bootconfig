local pin=3
--gpio.mode(pin,gpio.OUTPUT)
pwm.setup(pin, 500, 512)
pwm.start(pin)
local v=512
local dv=1
tmr.alarm(1, 10, 1, function()
    pwm.setduty(pin, v)
    v = v + dv*10
    if v>1000 then dv = -1 end
    if v<5 then dv = 1 end
end)
