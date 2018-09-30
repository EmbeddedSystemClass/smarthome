local filter = {}
filter.__index = filter

setmetatable(filter, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function filter.new(size)
    local self = setmetatable({}, filter)
    self.len = size
    self.sum = 0
    self.buf = {}
    self.head = 1
    return self
end

function filter:get_value(value)
    if not (self.head < self.len) then
        self.head = 1
    end
    if self.buf[self.head] ~= nil then
        self.sum = self.sum - self.buf[self.head]
    end
    self.sum = self.sum + value
    self.buf[self.head] = value
    self.head = self.head + 1
    
    return self.sum / table.getn(self.buf)
end

return filter

