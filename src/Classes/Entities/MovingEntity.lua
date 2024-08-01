local Entity = require "Classes.Entities.Entity"
local Vector2 = require "Classes.Vector2"
local Signal = require "Classes.Signal"

local Vector2Util = require("Util.Vector2Util")

local MovingEntity = {}
setmetatable(MovingEntity, Entity)
MovingEntity.__index = MovingEntity

function MovingEntity.new(entityType)
    local self = Entity.new(entityType)

    self._moving = false
    self._movement_canceled = false

    self.Speed = nil
    self.MovingTo = nil

    self.MovementBegan = Signal.new() 
    self.MovementEnded = Signal.new()
    self.MovementCompleted = Signal.new()

    setmetatable(self, MovingEntity)
    return self
end

--speed is tiles per second
function MovingEntity:SetSpeed(speed)
    self.Speed = speed
end


function MovingEntity:MoveTo(position)
    assert(getmetatable(position) == Vector2, string.format("Invalid argument 1, Vector2 expected"))
    if self._moving == true then return end
    self._moving = true
    self._movement_canceled = false
    self.MovingTo = position
    self.MovementBegan:Fire(position)
end

function MovingEntity:UpdateMovement(dt)
    if self._moving == false or self._movement_canceled == true then return end
    if self.MovingTo == nil then return end

    local currentPosition = self.Position
    local movingTo = self.MovingTo
    local movement = self.Speed * dt

    local dist = self:GetDistanceFrom(movingTo)

    if dist < 0.01 or movement >= dist then
        self:SetPosition(movingTo)
        self:CompleteMovement()
        return
    end

    local xDeltaDir = self.MovingTo.X - self.Position.X
    local yDeltaDir = self.MovingTo.Y - self.Position.Y

    local theta = math.atan(math.abs(yDeltaDir) / math.abs(xDeltaDir))

    local xDelta = math.cos(theta) * movement
    local yDelta = math.sin(theta) * movement

    local dirX = xDeltaDir == 0 and 0 or xDeltaDir / math.abs(xDeltaDir)
    local dirY = yDeltaDir == 0 and 0 or yDeltaDir / math.abs(yDeltaDir)


    xDelta = xDelta * dirX
    yDelta = yDelta * dirY

    if xDeltaDir == 0 then
        xDelta = 0
        yDelta = movement * dirY
    end
    if yDeltaDir == 0 then
        xDelta = movement * dirX
        yDelta = 0
    end
    local newPosition = Vector2.new(currentPosition.X + xDelta, currentPosition.Y + yDelta)
    --self:SetOrientation(Vector2Util:GetLookatOrientation(currentPosition, newPosition))
    self:SetPosition(newPosition)
end

function MovingEntity:CompleteMovement()
    assert(self._moving, "Cannot complete movement if not moving")
    local oldMovingTo = self.MovingTo
    self.MovingTo = nil
    self._moving = false
    self._movement_canceled = false
    self.MovementEnded:Fire(oldMovingTo)
    self.MovementCompleted:Fire(oldMovingTo)
end

function MovingEntity:CancelMovement()
    assert(self._moving, "Cannot cancel movement if not moving")
    self._movement_canceled = true
    local oldMovingTo = self.MovingTo
    self._moving = false
    self._movement_canceled = false
    self.MovementEnded:Fire(oldMovingTo)
end

return MovingEntity