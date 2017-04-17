local runtime = {}

timers = {}

function time_parce(str, table)
    local i = 1
    for token in string.gmatch(str, "%S+") do
        table[i] = tonumber(token)
        i=i+1
    end
end

function set_timer(m, pl)
    local args = {}
    for arg in string.gmatch(pl, "([^,]+)") do
        table.insert(args, arg)
    end
    timers[tonumber(args[1])] = tonumber(args[2])
    save_timer()
end

function save_timer()
    file.open("time.txt", "w")
    
    time = ""
    for k, v in pairs(timers) do 
        time = time .. v 
        time = time .. " "
        end
    file.writeline(time)
    
    file.close()
end

function init_timer()
    if file.open("time.txt", "r") ~= nil then
    
        time = file.readline()
        if time ~= nil then
            time_parce(time, timers)
            print("timers:")
            for k, v in pairs(timers) do print(k .. ": " .. v) end
        else
            print("read error")
        end
        
        file.close()
    else
        print("Timers mot found. Defaults restored")
        file.open("time.txt", "w")
        file.writeline("10 10 10 10 10")
        file.close()
    end
end

return runtime
   