local Vector2
local Player
local Heart
local EvilNeedle
------------------------------------------------------------
-- GAME FUNCTIONS -- wrapper for all the enemies, objects, etc

local game = {}

game.BoardWidth = 20
game.BoardHeight = 12

game.Score = 0
game._running = false

game.Entities = {}
game.Player = nil


------------------------------------------------------------
-- Init

function game:Init()
    Vector2 = require("Classes.Vector2")
    Player = require("Classes.Entities.Player")
    Heart = require("Classes.Entities.Heart")
    EvilNeedle = require("Classes.Entities.EvilNeedle") -- Madame Defarge
end


------------------------------------------------------------
-- Game rounds managment

function game:InitRound()
    assert(self._running == false, "Cannot init game round while running")
    self._running = false

    -- create Hearts
    local heartA = Heart.new()
    local heartB = Heart.new()
    local heartC = Heart.new()
    local heartD = Heart.new()
    local heartE = Heart.new()
    local heartF = Heart.new()

    local boardWidth = self.BoardWidth
    local boardHeight = self.BoardHeight

    local x1 = boardWidth / 3
    local x2 = boardWidth / 2
    local x3 = (boardWidth / 2) + (x2 - x1)
    local y1 = boardHeight / 2 - boardHeight / 6
    local y2 = boardHeight / 2 + boardHeight / 6
    heartA:SetPosition(Vector2.new(x1, y1))
    heartB:SetPosition(Vector2.new(x2, y1))
    heartC:SetPosition(Vector2.new(x3, y1))
    heartD:SetPosition(Vector2.new(x1, y2))
    heartE:SetPosition(Vector2.new(x2, y2))
    heartF:SetPosition(Vector2.new(x3, y2))

    self:AddEntity(heartA)
    self:AddEntity(heartB)
    self:AddEntity(heartC)
    self:AddEntity(heartD)
    self:AddEntity(heartE)
    self:AddEntity(heartF)


    -- create player
    local player = Player.new(Vector2.new(2, boardHeight - 2))
    self:SetPlayer(player)

    --create thread

    local newEvilNeedle = EvilNeedle.new(Vector2.new(boardWidth - 2, 2))
    self:AddEntity(newEvilNeedle)
    newEvilNeedle:StartAI()

    --[[
    local newEvilNeedle2 = EvilNeedle.new(Vector2.new(boardWidth - 2, 2))
    self:AddEntity(newEvilNeedle2)
    newEvilNeedle2:StartAI()
    -- done
--]]
    self._running = true
end

function game:CleanupRound()
    self._running = false
    for _, v in pairs(self.Entities) do
        v:Destroy()
    end
end

function game:StartRound()
    self:InitRound()
end


------------------------------------------------------------
-- Scoring

function game:AddScore(amnt)
    self.Score = self.Score + amnt
end

------------------------------------------------------------
-- entity managment

function game:SetPlayer(player)
    self:AddEntity(player)
    self.Player = player --
end

function game:GetPlayer()
    return self.Player
end

function game:AddEntity(entity)
    table.insert(self.Entities, entity)
    entity:SetPositionBounds(Vector2.new(self.BoardWidth, self.BoardHeight))
    entity:SetParentStorage(self.Entities)
end


------------------------------------------------------------
-- collisions

function game:CheckCollisions()
    local collidedWith = {}

    local function posInBounds(pos1x, pos1y, pos2x, pos2y, boundsWidth, boundsHeight)
        local xInBounds = (pos1x <= pos2x + (boundsWidth / 2) and pos1x >= pos2x - (boundsWidth / 2))
        local yInBounds = (pos1y <= pos2y + (boundsHeight / 2) and pos1y >= pos2y - (boundsHeight / 2))
        return xInBounds and yInBounds
    end

    -- tables themselves can act like a index to a table!
    local entities = self.Entities
    -- go through each entity
    -- the goto is used to terminate the current itteration if certain
    -- conditions are not present to check for collisions
    for _, v in pairs(entities) do
        -- check each entity if it collides with this specific entity
        if v.Hitbox == nil or v.Position == nil then goto collision_continue end
        local pos1 = v.Position
        local hitbox1 = v:GetHitbox()
        local pos1x = pos1.X
        local pos1y = pos1.Y
        local h1width = hitbox1.X
        local h1height = hitbox1.Y
        collidedWith[v] = {}
        for _, k in pairs(entities) do
            if k ~= v then
                if k.Hitbox == nil or k.Position == nil then goto collision_continue end
                local pos2 = k.Position
                local hitbox2 = k:GetHitbox()
                if not hitbox2 then goto collision_continue end
                local pos2x = pos2.X
                local pos2y = pos2.Y 
                local h2width = hitbox2.X
                local h2height = hitbox2.Y
                local e1ine2 = posInBounds(pos1x, pos1y, pos2x, pos2y, h2width, h2height)
                local e2ine1 = posInBounds(pos2x, pos2y, pos1x, pos1y, h1width, h1height)
                if e1ine2 or e2ine1 then
                    table.insert(collidedWith[v], k)
                end
            end
        end
        if #collidedWith[v] == 0 then
            collidedWith[v] = nil
        end
        ::collision_continue::
    end

    return collidedWith
end


------------------------------------------------------------
-- graphical utilites

function game:GetPixelsPerTile()
    return (love.graphics.getWidth() / self.BoardWidth)
end

function game:GetImageTileScaleFactor(imgSize)
    return self:GetPixelsPerTile() / imgSize
end


------------------------------------------------------------
-- gameloop functions


function game:DoTick(dt)

    local collisions  = self:CheckCollisions() 
    for entity, collidedWith in pairs(collisions) do
        for _, v in pairs(collidedWith) do
            entity.Touched:Fire(v)
        end
    end

    for _, v in pairs(self.Entities) do
        v:DoTick(dt)
    end
end

function game:Draw()
    for _, v in pairs(self.Entities) do
        v:Draw()
    end

    -- draw score
end

return game