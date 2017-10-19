-- Begin WiFi configuration
print("Get available APs")
available_aps = ""
wifi.setmode(wifi.STATION)
local tmrSetupServer = tmr.create()
wifi.sta.getap(function(t)
   if t then
      for k,v in pairs(t) do
         ap = string.format("%-10s",k)
         ap = trim(ap)
         print(ap)
         available_aps = available_aps .. "<option>".. ap .."</option>"
      end
 --     print(available_aps)
      print("Debuggin!")
      tmr.alarm(tmrSetupServer,5000,1, function() setup_server(available_aps) end )
   end
end)

local unescape = function (s)
   s = string.gsub(s, "+", " ")
   s = string.gsub(s, "%%(%x%x)", function (h)
         return string.char(tonumber(h, 16))
      end)
   return s
end

function setup_server(aps)
   print("Setting up Wifi AP")
   wifi.setmode(wifi.SOFTAP)
   wifi.ap.config({ssid="sqowe"..node.chipid()})
   wifi.ap.setip({ip="192.168.111.1",netmask="255.255.255.0",gateway="192.168.111.1"})
   print("Setting up webserver")

--web server
--srv:close()
srv = nil
   srv=net.createServer(net.TCP)
   srv:listen(80,function(conn)
       conn:on("sent",function(conn)
            conn:close()
            collectgarbage()
       end)
       conn:on("receive", function(client,request)
            print("Connection Open")
           local buf = ""

           local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
           if(method == nil)then
               _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
           end
           local _GET = {}
           if (vars ~= nil)then
               for k, v in string.gmatch(vars, "(%w+)=([^%&]+)&*") do
                   _GET[k] = unescape(v)
               end
           end

           if (_GET.mqttServer ~= nil and _GET.ap ~= nil) then
     --         client:send("Saving data..")
              print("Saving data..")
              file.open("ssid.lua", "w")
              file.writeline('local module = {}')
              file.writeline('module.SSID = "' .. _GET.ap .. '"')
              if(_GET.psw ~= nil) then file.writeline('module.PASSWD = "' .. _GET.psw .. '"')
              else file.writeline('module.PASSWD = ""') end
              file.writeline('return module')
              file.close()

              file.open("mqtt-config.lua", "w")
              file.writeline('local module = {}')
              file.writeline('module.HOST = "' .. _GET.mqttServer .. '"')
              if (config.MQTT_SSH == 0) then
                file.writeline('module.PORT = 1883')
              else
                file.writeline('module.PORT = 8883')
              end
              if(_GET.mqttUser ~= nil) then file.writeline('module.LOGIN = "' .. _GET.mqttUser .. '"')
              else file.writeline('module.LOGIN = ""') end
              if(_GET.mqttPsw ~= nil) then file.writeline('module.PASS = "' .. _GET.mqttPsw .. '"')
              else file.writeline('module.PASS = ""') end
              file.writeline('return module')
              file.close()
--              node.compile("ssid.lua")
--              file.remove("ssid.lua")
buf = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<!DOCTYPE HTML>\r\n<html>"
buf = buf .. "<head>"
buf = buf .. "<meta charset=\"utf-8\">\r\n\r\n"
buf = buf .. "<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\r\n\r\n"
buf = buf .. "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no\" />\r\n\r\n"
buf = buf .. "<meta name=\"HandheldFriendly\" content=\"true\" />\r\n\r\n"

buf = buf .. "<title>Sqowe</title></head><body>"
buf = buf .. "<h2 style=\"text-align: center;\">Sqowe Settings</h2>"
buf = buf .. "<h3 style=\"text-align: center;\">Sensor ID: <span style=\"color: #ff0000;\">" .. node.chipid() .. "</span></h3>"
buf = buf .. "<div><form action=\"/\" method=\"get\">"
buf = buf .. "<div style=\"text-align: center;\">"
buf = buf .. "<div><strong><label for=\"ap\">WiFi Network</label></strong></div>"
buf = buf .. "<div style=\"text-align: center;\"><span style=\"color: #3366ff;\"><strong><span style=\"font-family: -apple-system;\"><span style=\"white-space: pre;\">" .. _GET.ap .. "</span></span></strong></span></div>"
buf = buf .. "<div><span style=\"color: #3366ff;\">&nbsp;</span></div>"
buf = buf .. "<div>&nbsp;</div>"
buf = buf .. "<div><strong><label for=\"mqttServer\">Controller Address</label> </strong></div>"
buf = buf .. "<div style=\"text-align: center;\"><strong><span style=\"color: #3366ff;\"><span style=\"font-family: -apple-system;\">" .. _GET.mqttServer .. "</span></span></strong></div>"
if (_GET.mqttUser == nil) then _GET.mqttUser = "Without password" end
buf = buf .. "<div><strong><label for=\"mqttUser\">Controller Username</label> </strong></div>"
buf = buf .. "<div style=\"text-align: center;\"><span style=\"color: #3366ff;\"><strong><span style=\"font-family: -apple-system;\">" .. _GET.mqttUser .. "</span></strong></span></div>"
buf = buf .. "<input type='hidden' name='reboot' value='1'></input>"
buf = buf .. "<div>&nbsp;</div><div>&nbsp;</div></div>"
buf = buf .. "<div style=\"text-align: center;\"><button type=\"submit\">Apply and reboot</button></div>"
buf = buf .. "</form></div></body></html>"
              client:send(buf)
--              node.restart()


           elseif (_GET.reboot ~= nil) then
                node.restart()
           else

buf = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<!DOCTYPE html>\r\n\r\n"
buf = buf .. "<html>\r\n\r\n"

buf = buf .. "<head>"
buf = buf .. "<meta charset=\"utf-8\">\r\n\r\n"
buf = buf .. "<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\r\n\r\n"
buf = buf .. "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no\" />\r\n\r\n"
buf = buf .. "<meta name=\"HandheldFriendly\" content=\"true\" />\r\n\r\n"

buf = buf .. "<title>Sqowe</title></head><body>"

buf = buf .. "<h2 style=\"text-align: center;\">Sqowe</h2>"
buf = buf .. "<div><form action=\"/\" method=\"get\">"
buf = buf .. "<div>"
buf = buf .. "<div style=\"text-align: center;\">"
buf = buf .. "<div><strong><label for=\"ap\">Available APs</label></strong></div>"
buf = buf .. "<div><select name=\"ap\">"
buf = buf ..  aps
buf = buf .. "</select></div>"
buf = buf .. "<div><strong><label for=\"psw\">Wi-Fi Password</label> </strong></div>"
buf = buf .. "<div><input name=\"psw\"  type=\"password\" placeholder=\"Wi-Fi Password\" /></div>"
buf = buf .. "<div>&nbsp;</div>"
buf = buf .. "<div>&nbsp;</div>"
buf = buf .. "<div><strong><label for=\"mqttServer\">Controller Address</label> </strong></div>"
buf = buf .. "<div><input name=\"mqttServer\" required=\"\" type=\"text\" placeholder=\"IP Address\" /></div>"
buf = buf .. "<div><strong><label for=\"mqttUser\">Controller Username</label> </strong></div>"
buf = buf .. "<div><input name=\"mqttUser\"  type=\"text\" placeholder=\"Username\" /></div>"
buf = buf .. "<div><strong><label for=\"mqttPsw\">Controller Password</label></strong></div>"
buf = buf .. "<div><input name=\"mqttPsw\" type=\"password\" placeholder=\"Password\" /></div>"
buf = buf .. "<div>&nbsp;</div>"
buf = buf .. "</div>"
buf = buf .. "<div style=\"text-align: center;\"><button type=\"submit\">Setup</button></div>"
buf = buf .. "</div>"
buf = buf .. "</form></div></body></html>"


           client:send(buf)
           end
--           client:close()
--           collectgarbage()
       end)
   end)

   print("Please connect to: " .. wifi.ap.getip())
   tmr.stop(tmrSetupServer)
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
