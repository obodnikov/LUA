gpio.mode(7, gpio.INPUT)

if(gpio.read(7) == gpio.HIGH)
then
    dofile("start_BME280.lua")
else
    print("Config mode")
    if file.exists("serverHTTP.lua") then dofile("serverHTTP.lua")
    else dofile("serverHTTP.lc") end
end
