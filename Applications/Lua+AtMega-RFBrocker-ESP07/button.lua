--button.lua
-- buttonPin = 4 -- this is ESP-01 pin GPIO02
-- gpio.mode(buttonPin,gpio.INT,gpio.PULLUP)

local module = {}



local function debounce (func)
    local last = 0
    local delay = 200000

    return function (...)
        local now = tmr.now()
        if now - last < delay then return end

        last = now
        return func(...)
    end
end

local function onChange()

    for k,v in ipairs(config.bMap) do
        if gpio.read(v) == 0 then
            print("That was easy! "..v.."       "..config.swMap[k])
            if (gpio.read(config.swMap[k]) == 0) then gpio.write(config.swMap[k],gpio.HIGH)
            else gpio.write(config.swMap[k],gpio.LOW) end
            app.publish_topic("powerSW" .. k, config.STATUS[gpio.read(config.swMap[k])])
        end
    end
end

local function onChange_common_button()

    for k,v in ipairs(config.cMap) do
        if gpio.read(v) == 0 then
            print("That was easy! "..v.."       "..config.strMap[k])
                app.publish_topic(config.strMap[k],"ON")
        end
    end
end

local function button_start()
    gpio.trig(config.bSSW1,"down", debounce(onChange))
    gpio.trig(config.bSSW2,"down", debounce(onChange))
    gpio.trig(config.bSW10A1,"down", debounce(onChange_common_button))
    gpio.trig(config.bSW10A2,"down", debounce(onChange_common_button))
end

function module.start()
  button_start()
end

return module
-- gpio.trig(buttonPin,"down", debounce(onChange))
