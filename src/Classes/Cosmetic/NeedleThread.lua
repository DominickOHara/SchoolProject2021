local Vector2 = require "Classes.Vector2"
-- A thread is a cosmetic strinbg that follows a needle
local game = require("Game")

local THREAD_SIZE_DIVIDAND = 16
local THREAD_SIZE = 1 / THREAD_SIZE_DIVIDAND-- 0.2 tiles per thread point

local NeedleThread = {}
NeedleThread.__index = NeedleThread

function NeedleThread.new(pos, length, r, g, b)
    local self = setmetatable({}, NeedleThread)
    self.ThreadLength = length
    --i, jp, added self.ThreadPoints{x = {}, y={}}
    self.ThreadPoints = {}
    self.Color = {R = r, G = g, B = b}
    self.CurrentIndex = 0
    --not sure if this is how i should initialize the coord arrays in LUA
    return self
end

function NeedleThread:Destroy()
    self = nil
end

--i, jp, edited this
function NeedleThread:Draw()
    local color = self.Color
    local pixelsPerTile = game:GetPixelsPerTile()
    local radius = pixelsPerTile * THREAD_SIZE
    love.graphics.setColor(color.R / 255, color.G / 255, color.B / 255)
    for i = 1, #self.ThreadPoints, 1 do
        local point = self.ThreadPoints[i]
        local x = point.X * pixelsPerTile
        local y = point.Y * pixelsPerTile
        love.graphics.rectangle("fill", x, y, radius, radius)
    end
    love.graphics.setColor(1, 1, 1)
end

--i, jp edited this function. it most likely has table manipulation errors
function NeedleThread:UpdatePosition(newX, newY)
    local threadPoints = self.ThreadPoints
    local lastPoint = threadPoints[self.CurrentIndex]
    local newX = math.floor(newX * THREAD_SIZE_DIVIDAND) / THREAD_SIZE_DIVIDAND
    local newY = math.floor(newY * THREAD_SIZE_DIVIDAND) / THREAD_SIZE_DIVIDAND

    if lastPoint ~= nil then
        local oldX = math.floor(lastPoint.X * THREAD_SIZE_DIVIDAND) / THREAD_SIZE_DIVIDAND
        local oldY = math.floor(lastPoint.Y * THREAD_SIZE_DIVIDAND) / THREAD_SIZE_DIVIDAND
        if newX == oldX and newY == oldY then
            return 
        end
    end
    self.CurrentIndex = self.CurrentIndex + 1 --starts at 0 so the +1 is the index of 1

    if self.CurrentIndex == self.ThreadLength then
        self.CurrentIndex = 1
    end

    self.ThreadPoints[self.CurrentIndex] = Vector2.new(newX, newY)
end


return NeedleThread