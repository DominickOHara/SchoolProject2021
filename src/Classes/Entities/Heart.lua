local Heart_Alive_Img = love.graphics.newImage("Assets/StitchedHeart.png")
local Heart_Stitched_Img = love.graphics.newImage("Assets/NormalHeart.png")
local Heart_Dead_Img = love.graphics.newImage("Assets/DeadHeart.png")

local Entity = require("Classes.Entities.Entity")
local Vector2 = require("Classes.Vector2")

local Game; -- cant do require "game" since that will cause a stack overflow; game also requires heart


local Heart = {}
setmetatable(Heart, Entity)
Heart.__index = Heart

local _class_init = false
function Heart:ClassInit()
    assert(_class_init == false, "Cannot reinit the Heart class")
    Game = require("Game")
    _class_init = true
end

function Heart.new()
    local self = Entity.new("Heart")
    setmetatable(self, Heart)
    self.Healed = nil

    self:SetHitbox(Vector2.new(1, 1))

    self.Handlers = {}

    table.insert(self.Handlers, self.Touched:Connect(function(hit)
        if hit:HasTag("Harmful") and self.Alive == true then
            self:Harm()
        elseif hit:HasTag("Healing") and self.Alive == false then
            self:Heal()
            --keeps track of whether or not a heart has to be displayed as stitched
            self.Healed = true
        end
    end))

    self.Alive = true

    return self
end


function Heart:Destroy()
    for _, v in pairs(self.Handlers) do
        v:Disconnect()
    end
end

function Heart:Harm()
    if not self.Alive then return end
    self.Alive = false
end

function Heart:Heal()
    if self.Alive then return end
    self.Alive = true
end

function Heart:IsAlive()
    return self.Alive
end

function Heart:Draw()
    if self.Position == nil then return end
    --draw heart based on current condition. self.Healed should only return if the heart has been injured and healed in the past
    local pixelsPerTile = Game:GetPixelsPerTile()
    local drawPosx = self.Position.X * pixelsPerTile
    local drawPosY = self.Position.Y * pixelsPerTile
    local img = self.Alive and Heart_Alive_Img or Heart_Dead_Img
    img:setFilter("nearest")
    local scaleFactorX = Game:GetImageTileScaleFactor(img:getWidth())
    local scaleFactorY = Game:GetImageTileScaleFactor(img:getHeight())
    local imgOffsetX = img:getWidth() / 2
    local imgOffsetY = img:getHeight() / 2
    love.graphics.draw(img, drawPosx, drawPosY, self.Orientation, scaleFactorX, scaleFactorY, imgOffsetX, imgOffsetY)
end

function Heart:DoTick()

end

return Heart