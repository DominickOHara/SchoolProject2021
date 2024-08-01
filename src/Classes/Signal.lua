local Connection = {}
Connection.__index = Connection

function Connection.new(func)
    local self = setmetatable({}, Connection)
    self._function = func
    self._active = true
    return self
end

function Connection:Disconnect()
    self._active = false
    self._function = nil
    self = nil
end

function Connection:Destroy()
    self:Disconnect()
end


local Signal = {}
Signal.__index = Signal 

function Signal.new()
    local self = setmetatable({}, Signal)
    self.Connections = {}
    return self
end

function Signal:Fire(...)
    for _, v in pairs(self.Connections) do
        if v._active == true then
            v._function(...)
        end
    end
end

function Signal:Connect(func)
    local conn = Connection.new(func)
    table.insert(self.Connections, conn)
    return conn
end

function Signal:Destroy()
    for _, v in pairs(self.Connections) do
        v:Disconnect()
    end
    self = nil
end

return Signal