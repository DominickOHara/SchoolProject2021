local LEAD_NEEDLE_IMG = love.graphics.newImage("Assets/LeadNeedle.png")

local MovingEntity = require("Classes.Entities.MovingEntity")
local NeedleThread = require("Classes.Cosmetic.NeedleThread")
local Vector2 = require("Classes.Vector2")

local Game; -- cant do require "game" since that will cause a stack overflow; game also requires heart
local BoardWidth
local BoardHeight


local EvilNeedle = {}
setmetatable(EvilNeedle, MovingEntity)
EvilNeedle.__index = EvilNeedle

local _class_init = false
function EvilNeedle:ClassInit()
    assert(_class_init == false, "Cannot reinit the evil needle class")
    Game = require("Game")
    BoardWidth = Game.BoardWidth
    BoardHeight = Game.BoardHeight
    _class_init = true
end

function EvilNeedle.new(position)
    local self = MovingEntity.new("EvilNeedle")
    setmetatable(self, EvilNeedle)

    self:SetHitbox(Vector2.new(0.5, 0.5))

    self:SetSpeed(4)

    self:SetPosition(position)
    self.NeedleThread = NeedleThread.new(position, 80, 128, 128, 128)  

    self._ai_running = false
    self._ai_init_complete = false
    self:AddTag("Harmful")  

    self.Handlers = {}  

    -- AI STUFF
    self.Target = nil
    self.Counter = 0
    self.CounterFunction = nil

    table.insert(self.Handlers, self.MovementCompleted:Connect(function()
        if self._ai_runnig == false then return end
        if self.Target ~= nil then
            self.Target = nil
            self:MoveTo(Vector2.new(math.random(BoardWidth / 2 - BoardWidth / 3, BoardWidth / 2 + BoardWidth / 3), math.random(BoardHeight / 2 - BoardHeight / 3, BoardHeight / 3 + BoardHeight / 2)))
            local selfRef = self
            self:SetCounter(math.random(1), function()
                if self._ai_runnig == false then return end
                self:Attack()
            end)
        else
            self:Attack()
        end
    end))

    return self
end

function EvilNeedle:Destroy()

end


------------------------------------------------------------
-- AI

function EvilNeedle:StartAI()
    assert(self._ai_running ~= true, "Cannot enable ai when it is already running")
    self._ai_running = true

    self:Attack() -- get it to start moving
end

function EvilNeedle:DisableAI()
    assert(self._ai_running, "Cannot disable ai when it is running")
    self._ai_running = false
end

function EvilNeedle:Attack()
    local hearts = self:GetAliveHearts()
    if #hearts == 0 then
        self:MoveToCenter()
        return
    end
    local randHeart = hearts[math.random(1, #hearts)]
    self.Target = randHeart
    self:MoveTo(randHeart.Position)
end

function EvilNeedle:SetCounter(seconds, func)
    self.Counter = seconds
    self.CounterFunction = func
end

function EvilNeedle:DegradeCounter(seconds)
    self.Counter = math.max(0, self.Counter - seconds)
    if self.Counter == nil then return end
    if self.CounterFunction == nil then return end
    if self.Counter <= 0 then
        self.CounterFunction()
    end
end




------------------------------------------------------------
-- Utility

function EvilNeedle:MoveToCenter()
    self:MoveTo(Vector2.new(BoardWidth / 2, BoardHeight / 2))
end

function EvilNeedle:GetHearts()
    local parentStorage = self.ParentStorage
    if parentStorage == nil then return end
    local hearts = {}
    for _, v in pairs(parentStorage) do
        if v:GetEntityType() == "Heart" then
            table.insert(hearts, v)
        end
    end
    return hearts
end

function EvilNeedle:GetAliveHearts()
    local parentStorage = self.ParentStorage
    if parentStorage == nil then return end
    local hearts = {}
    for _, v in pairs(self:GetHearts()) do
        if v:IsAlive() == true then
            table.insert(hearts, v)
        end
    end
    return hearts
end

------------------------------------------------------------
-- Logic etc

function EvilNeedle:Draw() 
    local pixelsPerTile = Game:GetPixelsPerTile()
    local drawPosx = self.Position.X * pixelsPerTile
    local drawPosY = self.Position.Y * pixelsPerTile
    local img = LEAD_NEEDLE_IMG
    img:setFilter("nearest")
    local scaleFactorX = Game:GetImageTileScaleFactor(img:getWidth())
    local scaleFactorY = Game:GetImageTileScaleFactor(img:getHeight())
    local imgOffsetX = img:getWidth() / 2
    local imgOffsetY = img:getHeight() / 2
    self.NeedleThread:Draw()
    love.graphics.draw(img, drawPosx, drawPosY, math.rad(self.Orientation), scaleFactorX, scaleFactorY, imgOffsetX, imgOffsetY)
end

function EvilNeedle:DoTick(dt)
    self:UpdateMovement(dt)
    local newPosition = self:GetPosition()
    self.NeedleThread:UpdatePosition(newPosition.X - 0.5, newPosition.Y + 0.5)
    self:DegradeCounter(dt)
end

return EvilNeedle