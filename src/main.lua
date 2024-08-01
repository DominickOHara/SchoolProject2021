math.randomseed(os.clock())

local game = require("Game")
local Heart = require("Classes.Entities.Heart")
local EvilNeedle = require("Classes.Entities.EvilNeedle")
local Player = require("Classes.Entities.Player")


------------------------------------------------------------
-- LOVE 2D MAIN FUNCTIONS

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest") --1st when scaling down -- 2nd when scaling up
    game:Init()
    -- allow these classes to have access to the game object; increadibly unefficent, but will do
    Heart:ClassInit()
    EvilNeedle:ClassInit()
    Player:ClassInit()

    game:StartRound()
end

function love.update(dt)
    if game._running then
        game:DoTick(dt)
    end
end

function love.draw()
    if game._running then
        game:Draw()
    end
end
