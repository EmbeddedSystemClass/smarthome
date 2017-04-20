local trimmer = {}

valves_closed = {150, 150, 150, 150, 150}
valves_opened = {210, 210, 210, 210, 210}
valves_trim_op = {}
valves_trim_cl = {}
valves_states = {}


function trim_parce(str, table)
    local i = 1
    for token in string.gmatch(str, "%S+") do
        table[i] = tonumber(token)
        i=i+1
    end
end

function save_trimmer()
    file.open("trim.txt", "w")
    
    trim = ""
    for k, v in pairs(valves_closed) do 
        trim = trim .. v 
        trim = trim .. " "
        end
    --trim = trim .. "\n"
    file.writeline(trim)

    trim = ""
    for k, v in pairs(valves_opened) do
        trim = trim .. v 
        trim = trim .. " "
     end
    --trim = trim .. "\n"
    file.writeline(trim)    
    
    file.close()
end

function init_trimmer()
    if file.open("trim.txt", "r") ~= nil then
    
        trim = file.readline()
        if trim ~= nil then
            trim_parce(trim, valves_closed)
            print("valves sclosed:")
            for k, v in pairs(valves_closed) do print(k .. ": " .. v) end
        else
            print("read error")
        end

        trim = file.readline()
        if trim ~= nil then
            trim_parce(trim, valves_opened)
            print("valves opened:")
            for k, v in pairs(valves_opened) do print(k .. ": " .. v) end
        else
            print("read error")
        end
        
        file.close()
    else
        print("Trim mot found. Defaults restored")
        file.open("trim.txt", "w")
        file.writeline("150 150 150 150 150")
        file.writeline("210 210 210 210 210")
        file.close()
    end
end

return trimmer