local Vector2Util = {}

function Vector2Util:GetLookatOrientation(pos1, pos2)
    if pos1 == nil then return 0 end

    local deltaY = pos2.Y - pos1.Y
    local deltaX = pos2.X - pos1.X

    if deltaY == 0 and deltaX > 0 then
        return 0
    elseif deltaY == 0 and deltaX < 0 then
        return 180
    elseif deltaY < 0 and deltaX == 0 then
        return 90
    elseif deltaY > 0 and deltaX == 0 then
        return 270
    end
    
    local baseDegreese = math.deg(math.atan(deltaX / deltaY))
    if pos2.Y <= pos1.Y and pos2.X >= pos1.X then
        -- quadrant 1
    elseif pos2.Y <= pos1.Y and pos2.X < pos1.X then
        -- quadrant 2
        baseDegreese = baseDegreese + 90
    elseif pos2.Y > pos1.Y and pos2.X < pos1.X then
        -- quadrant 3
        baseDegreese = baseDegreese + 180
    elseif pos2.Y > pos1.Y and pos2.X >= pos1.X then
    -- quadrant 4
        baseDegreese = baseDegreese + 270
    end
    return baseDegreese
end

return Vector2Util