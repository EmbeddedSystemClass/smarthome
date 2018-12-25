local fs = {}

function fs.write_tweet(n, msg)
    name = "tweet" .. n .. ".txt"
    if file.open(name, "w") then
        file.write(msg)
        file.close()
    end
end

function fs.read_tweet(n)
    local msg = nil
    name = "tweet" .. n .. ".txt"
    if file.open(name, "r") then
        msg = file.read()
        file.close()
    end
    return msg
end

function fs.erase_tweet(n)
    name = "tweet" .. n .. ".txt"
    if file.exists(name) then
        file.close(name)
        file.remove(name)
    end
end

function fs.erase_all(count)
    for n = 1, count do
        name = "tweet" .. n .. ".txt"
        if file.exists(name) then
            file.close(name)
            file.remove(name)
        end
    end
end

function fs.read_value(name)
    local value = nil
    if file.open(name .. ".txt", "r") then
        value = file.read()
        file.close()
    end
    return value
end

function fs.write_value(name, value)
    if file.open(name .. ".txt", "w") then
        file.write(value)
        file.close()
    end
end

return fs