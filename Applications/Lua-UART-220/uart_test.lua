function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end


uart.on("data", "$", function(data)

   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   t = split(data,":")
        print("command: "..t[1])
        print("topic: "..t[2])
        print("info: "..t[3])
end, 0)
