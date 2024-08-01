local Signal = require("Classes.Signal")
local Vector2 = require("Classes.Vector2")

local Entity = {}
Entity.__index = Entity 

function Entity.new(entityType)
    local self = setmetatable({}, Entity)
    self.EntityType = entityType
    self.ParentStorage = nil
    self.Tags = {}

    self.PositionBounds = nil
    self.Position = nil
    self.Orientation = 0

    self.Hitbox = nil

    self.Touched = Signal.new()

    return self
end

function Entity:Destroy()
    self = nil
end


------------------------------------------------------------
-- entity funcs

function Entity:GetEntityType()
    return self.EntityType
end



------------------------------------------------------------
-- Tag functionality

function Entity:HasTag(tag)
    return self:GetTag(tag) ~= nil
end

function Entity:GetTag(tag)
    return self.Tags[tag]
end

function Entity:RemoveTag(tag)
    self.Tags[tag] = nil 
end

function Entity:AddTag(tag, value)
    value = value or tag
    self.Tags[tag] = value
end

------------------------------------------------------------
-- Parent Storage

function Entity:SetParentStorage(parentStorage)
    assert(parentStorage, string.format("Invalid argument 1, table expected, got %s", type(parentStorage)))
    self.ParentStorage = parentStorage
end

function Entity:GetParentStorage()
    return self.ParentStorage
end


------------------------------------------------------------
-- Collision

function Entity:SetHitbox(hitbox)
    assert(getmetatable(hitbox) == Vector2, string.format("Invalid argument 1, Vector2 expected"))
    self.Hitbox = hitbox
end

function Entity:GetHitbox()
    return self.Hitbox
end


------------------------------------------------------------
-- Movment and position and orientation

function Entity:SetPositionBounds(positionBounds)
    assert(getmetatable(positionBounds) == Vector2, string.format("Invalid argument 1, Vector2 expected"))
    self.PositionBounds = positionBounds
end

function Entity:SetPosition(position)
    assert(getmetatable(position) == Vector2, string.format("Invalid argument 1, Vector2 expected"))
    self.Position = position
end

function Entity:GetPosition(position)
    return self.Position
end

function Entity:GetDistanceFrom(otherPosition)
    assert(getmetatable(otherPosition) == Vector2, string.format("Invalid argument 1, Vector2 expected"))
    local position = self.Position 
    if not position then return end
    return math.sqrt((position.X - otherPosition.X) ^ 2 + (position.Y - otherPosition.Y) ^ 2)
end

function Entity:GetOrientationFromPosition()
    local oldPosition = self.OldPosition
    if oldPosition == nil then return 0 end

    local oldPos = oldPosition
    local currentPosition = self.Position

    local deltaY = currentPosition.Y - oldPos.Y
    local deltaX = currentPosition.X - oldPos.X

    return math.deg(math.atan(deltaX / deltaY))
end

function Entity:GetOrientation()
    return self.Oritentation
end

function Entity:SetOrientation(orientation)
    self.Orientation = orientation
end


------------------------------------------------------------
-- VIRTUAL FUNCTIONS

function Entity:Draw()

end

--function Entity:DoTick()

--end

return Entity