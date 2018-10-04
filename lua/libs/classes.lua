local _M = {} -- module table
 
_M.someProperty = 1 -- class properties
 
local function createText()
   -- local functions are still valid, but not seen from outside - "private"
end
 
local privateVar -- so do local variables
 
_GLOBAL_VAR -- without local it's global
 
function _M.staticMethod(vars)
    -- this is class method like function (dot)
    -- there is no "self"
end
 
function _M:someMethod(vars)
    -- this is object method like function (colon)
    -- there is "self"
end
 
function _M:newBaseObject()
    -- Here goes constructor code
    local object = {}
    object.vars = 'some vars'
    object.name = 'BaseObject'
    object.property = self.someProperty -- from module

    local privateObjectVar = 'my_secret' -- private, can't be seen from outside
 
    function object.staticMethodInc(i) -- without colon it's "static"
        return i + 1
    end
    
    function object:sign(song)
        print(self.name .. ' is singing ' .. song)
    end

    function object:destroy()
       -- optional destructor, after this to delete an object you just need to remove all references to it
       self.vars = nil
    end
 
    return object
end
 
-- Now inheritance
function _M:newChildObject()
    local object = self:newBaseObject()
    -- override any methods or add new
    object.name = 'ChildObject'
    function object:tell(story)
        print(self.name .. ' is telling ' .. story)
    end
    return object
end
 
return _M -- return this table as a module to require()