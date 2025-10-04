-- Multi-tier level generation system
local MultiTierGenerator = {}
local Helpers = require("src.utils.helpers")
local GameConfig = require("src.config.game_config")

-- Generate elevated zones (islands) in the level
function MultiTierGenerator.generateElevatedZones(maze, rows, cols)
    local zones = {}
    local zoneCount = GameConfig.ELEVATED_ZONES_PER_LEVEL
    local minSize = GameConfig.MIN_ELEVATED_ZONE_SIZE
    
    for i = 1, zoneCount do
        local zone = MultiTierGenerator._createElevatedZone(maze, rows, cols, minSize, zones)
        if zone then
            table.insert(zones, zone)
            print("DEBUG: Created elevated zone " .. i .. " with " .. zone.size .. " blocks at (" .. zone.centerR .. ", " .. zone.centerC .. ")")
        end
    end
    
    return zones
end

-- Create a single elevated zone
function MultiTierGenerator._createElevatedZone(maze, rows, cols, minSize, existingZones)
    local maxAttempts = 50
    
    for attempt = 1, maxAttempts do
        -- Pick a random center point (avoid edges)
        local centerR = math.random(5, rows - 5)
        local centerC = math.random(5, cols - 5)
        
        -- Check if this area is clear and not too close to existing zones
        if MultiTierGenerator._isAreaClear(maze, centerR, centerC, 3, rows, cols, existingZones) then
            -- Create irregular shaped zone
            local zoneBlocks = MultiTierGenerator._growZone(maze, centerR, centerC, minSize, rows, cols)
            
            if #zoneBlocks >= minSize then
                return {
                    centerR = centerR,
                    centerC = centerC,
                    blocks = zoneBlocks,
                    size = #zoneBlocks,
                    ramps = {}
                }
            end
        end
    end
    
    return nil
end

-- Check if an area is clear for zone placement
function MultiTierGenerator._isAreaClear(maze, centerR, centerC, radius, rows, cols, existingZones)
    -- Check bounds
    if centerR - radius < 1 or centerR + radius > rows or
       centerC - radius < 1 or centerC + radius > cols then
        return false
    end
    
    -- Check distance from existing zones
    for _, zone in ipairs(existingZones) do
        local dist = math.sqrt((centerR - zone.centerR)^2 + (centerC - zone.centerC)^2)
        if dist < 10 then  -- Minimum distance between zones
            return false
        end
    end
    
    return true
end

-- Grow a zone from a center point using flood fill (creates solid island)
function MultiTierGenerator._growZone(maze, centerR, centerC, targetSize, rows, cols)
    local blocks = {}
    local candidates = {{centerR, centerC}}
    local checked = {}
    checked[centerR .. "," .. centerC] = true
    
    while #candidates > 0 and #blocks < targetSize * 1.5 do
        -- Always take from the front to create more compact, solid shapes
        local cell = table.remove(candidates, 1)
        local r, c = cell[1], cell[2]
        
        -- Add this block if it's walkable
        if not maze[r][c] then
            table.insert(blocks, {r, c})
            
            -- Add neighbors as candidates (prioritize nearby cells for solid shape)
            local directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
            for _, dir in ipairs(directions) do
                local newR, newC = r + dir[1], c + dir[2]
                local key = newR .. "," .. newC
                
                -- Calculate distance from center
                local distFromCenter = math.abs(newR - centerR) + math.abs(newC - centerC)
                
                -- Only add if close to center (creates compact islands)
                if Helpers.isValidPosition(newR, newC, rows, cols) and
                   not checked[key] and
                   not maze[newR][newC] and
                   distFromCenter <= math.sqrt(targetSize) + 2 then
                    table.insert(candidates, {newR, newC})
                    checked[key] = true
                end
            end
        end
        
        -- Stop if we've reached target size
        if #blocks >= targetSize then
            break
        end
    end
    
    return blocks
end

-- Place ramps to connect zones to ground floor
function MultiTierGenerator.placeRamps(maze, zones, rows, cols)
    for _, zone in ipairs(zones) do
        -- Find more ramp locations on the edge of the zone for better accessibility
        local minRamps = 4
        local maxRamps = 8
        local rampCount = math.random(minRamps, maxRamps)
        local edgeBlocks = MultiTierGenerator._findZoneEdges(zone.blocks)
        
        local rampsPlaced = 0
        for attempt = 1, #edgeBlocks * 2 do
            if rampsPlaced >= rampCount then break end
            
            local edgeBlock = edgeBlocks[math.random(1, #edgeBlocks)]
            local r, c = edgeBlock[1], edgeBlock[2]
            
            -- Check if we already have a ramp here
            local hasRamp = false
            for _, existingRamp in ipairs(zone.ramps) do
                if existingRamp.r == r and existingRamp.c == c then
                    hasRamp = true
                    break
                end
            end
            
            if not hasRamp then
                -- Check if at least one adjacent tile is ground floor
                local directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
                local hasGroundAdjacent = false
                
                for _, dir in ipairs(directions) do
                    local adjR, adjC = r + dir[1], c + dir[2]
                    
                    -- Check if adjacent tile is on ground floor (not in any elevated zone)
                    local isGroundFloor = true
                    for _, otherZone in ipairs(zones) do
                        if MultiTierGenerator._isInZone(adjR, adjC, otherZone.blocks) then
                            isGroundFloor = false
                            break
                        end
                    end
                    
                    if Helpers.isValidPosition(adjR, adjC, rows, cols) and
                       not maze[adjR][adjC] and
                       isGroundFloor then
                        hasGroundAdjacent = true
                        break
                    end
                end
                
                -- Place ramp as a single block on the edge (accessible from any side)
                if hasGroundAdjacent then
                    table.insert(zone.ramps, {
                        r = r,
                        c = c
                    })
                    rampsPlaced = rampsPlaced + 1
                    print("DEBUG: Placed ramp at (" .. r .. ", " .. c .. ") - accessible from any adjacent ground floor")
                end
            end
        end
        
        if rampsPlaced == 0 then
            print("WARNING: Could not place any ramps for elevated zone at " .. zone.centerR .. ", " .. zone.centerC)
        else
            print("DEBUG: Placed " .. rampsPlaced .. " ramps for elevated zone")
        end
    end
    
    -- Ensure every elevated zone block is accessible by verifying connectivity
    MultiTierGenerator.ensureZoneAccessibility(maze, zones, rows, cols)
end

-- Ensure all elevated zone blocks are accessible
function MultiTierGenerator.ensureZoneAccessibility(maze, zones, rows, cols)
    for _, zone in ipairs(zones) do
        -- Find any edge blocks that don't have ramps nearby
        local edgeBlocks = MultiTierGenerator._findZoneEdges(zone.blocks)
        
        -- Add additional ramps if sections seem isolated
        for _, edgeBlock in ipairs(edgeBlocks) do
            local r, c = edgeBlock[1], edgeBlock[2]
            
            -- Check if there's a ramp within 5 tiles
            local hasNearbyRamp = false
            for _, ramp in ipairs(zone.ramps) do
                local dist = math.abs(r - ramp.r) + math.abs(c - ramp.c)
                if dist <= 5 then
                    hasNearbyRamp = true
                    break
                end
            end
            
            -- If no nearby ramp, try to add one
            if not hasNearbyRamp and #zone.ramps < 12 then  -- Cap at 12 ramps per zone
                local directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
                for _, dir in ipairs(directions) do
                    local adjR, adjC = r + dir[1], c + dir[2]
                    
                    -- Check if adjacent is ground floor
                    local isGroundFloor = true
                    for _, otherZone in ipairs(zones) do
                        if MultiTierGenerator._isInZone(adjR, adjC, otherZone.blocks) then
                            isGroundFloor = false
                            break
                        end
                    end
                    
                    if Helpers.isValidPosition(adjR, adjC, rows, cols) and
                       not maze[adjR][adjC] and
                       isGroundFloor then
                        table.insert(zone.ramps, {
                            r = r,
                            c = c
                        })
                        print("DEBUG: Added accessibility ramp at (" .. r .. ", " .. c .. ")")
                        break
                    end
                end
            end
        end
    end
end

-- Find edge blocks of a zone
function MultiTierGenerator._findZoneEdges(blocks)
    local blockSet = {}
    for _, block in ipairs(blocks) do
        blockSet[block[1] .. "," .. block[2]] = true
    end
    
    local edges = {}
    for _, block in ipairs(blocks) do
        local r, c = block[1], block[2]
        
        -- Check if this block has at least one neighbor not in the zone
        local directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
        for _, dir in ipairs(directions) do
            local adjR, adjC = r + dir[1], c + dir[2]
            if not blockSet[adjR .. "," .. adjC] then
                table.insert(edges, block)
                break
            end
        end
    end
    
    return edges
end

-- Check if a position is within a zone
function MultiTierGenerator._isInZone(r, c, blocks)
    for _, block in ipairs(blocks) do
        if block[1] == r and block[2] == c then
            return true
        end
    end
    return false
end

-- Get floor level at a position
function MultiTierGenerator.getFloorLevel(r, c, zones)
    -- Check if position is a ramp first
    for _, zone in ipairs(zones) do
        for _, ramp in ipairs(zone.ramps) do
            if ramp.r == r and ramp.c == c then
                return "ramp"
            end
        end
    end
    
    -- Check if position is in an elevated zone
    for _, zone in ipairs(zones) do
        if MultiTierGenerator._isInZone(r, c, zone.blocks) then
            return GameConfig.FLOOR_LEVELS.ELEVATED
        end
    end
    
    return GameConfig.FLOOR_LEVELS.GROUND
end

return MultiTierGenerator

