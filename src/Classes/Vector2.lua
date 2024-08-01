local Vector2 = {}

function Vector2.new(x, y)
    return setmetatable({X = x, Y = y}, Vector2)
end

return Vector2