local GOLD_NEEDLE_IMG = love.graphics.newImage("Assets/GoldNeedle.png")

local NeedleThread = require("Classes.Cosmetic.NeedleThread")
local Entity = require("Classes.Entities.Entity")
local Vector2 = require("Classes.Vector2")
local Vector2Util = require("Util.Vector2Util")

local Game

local Player = {}
setmetatable(Player, Entity)
Player.__index = Player

local _class_init = false
function Player:ClassInit()
    assert(_class_init == false, "Cannot reinit the player class")
    Game = require "Game"
    _class_init = true
end

function Player.new(position)
    local self = Entity.new("Player")
    setmetatable(self, Player)

    self:SetPosition(position)
    self.NeedleThread = NeedleThread.new(position, 80, 188, 124, 20) 

    self:SetHitbox(Vector2.new(0.5, 0.5))
    self:AddTag("Healing", true)
    self.MovementSpeed = 3;
    return self
end

function Player:Destroy()
    --is this what it is supposed to be? i read that to delete something in a table u just make it nil
    self = nil
end

function Player:Draw()
    local pixelsPerTile = Game:GetPixelsPerTile()
    local drawPosx = self.Position.X * pixelsPerTile
    local drawPosY = self.Position.Y * pixelsPerTile
    local img = GOLD_NEEDLE_IMG
    img:setFilter("nearest")
    local scaleFactorX = Game:GetImageTileScaleFactor(img:getWidth())
    local scaleFactorY = Game:GetImageTileScaleFactor(img:getHeight())
    local imgOffsetX = img:getWidth() / 2
    local imgOffsetY = img:getHeight() / 2
    self.NeedleThread:Draw()
    love.graphics.draw(img, drawPosx, drawPosY, math.rad(self.Orientation), scaleFactorX, scaleFactorY, imgOffsetX, imgOffsetY)
end

function Player:DoTick(dt)
    local movement = self.MovementSpeed * dt
    local deltaX = 0
    local deltaY = 0
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        deltaY = deltaY - movement
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("right") then
        deltaX = deltaX - movement
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        deltaY = deltaY + movement
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("left") then
        deltaX = deltaX + movement
    end
    if deltaX == 0 and deltaY == 0 then return end
    local oldPosition = self:GetPosition()
    local newPosition = Vector2.new(oldPosition.X + deltaX, oldPosition.Y + deltaY)
    self.NeedleThread:UpdatePosition(newPosition.X - 0.5, newPosition.Y + 0.5)
    --self:SetOrientation(Vector2Util:GetLookatOrientation(oldPosition, newPosition))
    self:SetPosition(newPosition)
end

return Player