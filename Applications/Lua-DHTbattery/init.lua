gpio.mode(6, gpio.FLOAT)
if(gpio.read(6) ~= gpio.LOW)
then
    dofile("start_justDHT.lua")
else
    print("Config mode")
    if file.exists("serverHTTP.lua") then dofile("serverHTTP.lua")
    else dofile("serverHTTP.lc") end
end
