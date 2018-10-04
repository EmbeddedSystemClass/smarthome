local modname = ...
local M = {}
if modname == nil then
    modname = "fs"
end
_G[modname] = M

local file = file
local string = string

setfenv(1,M)


function save_value(filename, val)
    file.open(filename, "w")
    
    local str = string.format("%f", val)
    file.writeline(str)
    
    file.close()
end

function init_value(filename, default)
    if file.open(filename, "r") ~= nil then
        val = file.readline()
        file.close()
        if val ~= nil then
            return val
        else
            return default
        end
    end
end

return M
