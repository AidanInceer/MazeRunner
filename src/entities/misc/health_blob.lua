--[[
    Health Blob Entity Module
    
    Handles green health blobs that restore player health when collected.
    Manages healing logic and visual effects.
]]

local HealthBlob = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

--[[
    Creates a new health blob
    
    @param r number Row position
    @param c number Column position
    @return table Health blob object
]]
function HealthBlob.create(r, c)
    return {
        r = r,
        c = c,
        collected = false,
        healAmount = GameConfig.HEALTH_RESTORE,
        color = "green"
    }
end

--[[
    Checks if blob can be collected by player
    
    @param blob table Health blob object
    @param player table Player object
    @return boolean True if can be collected
]]
function HealthBlob.canCollect(blob, player)
    return not blob.collected and blob.r == player.r and blob.c == player.c
end

--[[
    Collects the health blob
    
    @param blob table Health blob object
    @param player table Player object
    @return table Collection result with heal amount and particles
]]
function HealthBlob.collect(blob, player)
    if not blob.collected then
        blob.collected = true
        local actualHeal = math.min(blob.healAmount, player.maxHealth - player.health)
        player.health = player.health + actualHeal
        
        return {
            healAmount = actualHeal,
            particles = HealthBlob._createParticles(blob.r, blob.c)
        }
    end
    
    return nil
end

--[[
    Creates collection particles
    
    @param r number Row position
    @param c number Column position
    @return table Array of particles
]]
function HealthBlob._createParticles(r, c)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local cellSize, _, _, offsetX, offsetY = 
        Helpers.calculateGridDimensions(screenWidth, screenHeight, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS)
    
    local centerX = offsetX + (c - 1) * cellSize + cellSize / 2
    local centerY = offsetY + (r - 1) * cellSize + cellSize / 2
    
    return Helpers.createCircularParticles(
        centerX, centerY, 6, 80, GameConfig.PARTICLE_LIFE, 2, "green"
    )
end

--[[
    Places multiple health blobs on the maze
    
    @param maze table 2D maze array
    @param rows number Number of maze rows
    @param cols number Number of maze columns
    @param count number Number of blobs to place
    @return table 2D array of health blobs
]]
function HealthBlob.placeMultiple(maze, rows, cols, count)
    local blobs = {}
    for r = 1, rows do
        blobs[r] = {}
        for c = 1, cols do
            blobs[r][c] = false
        end
    end
    
    local placed = 0
    local attempts = 0
    local maxAttempts = 500
    
    while placed < count and attempts < maxAttempts do
        attempts = attempts + 1
        local r = math.random(1, rows)
        local c = math.random(1, cols)
        
        if not maze[r][c] and not blobs[r][c] then
            blobs[r][c] = HealthBlob.create(r, c)
            placed = placed + 1
        end
    end
    
    return blobs
end

--[[
    Gets render data for the blob
    
    @param blob table Health blob object
    @return table Render data
]]
function HealthBlob.getRenderData(blob)
    return {
        r = blob.r,
        c = blob.c,
        collected = blob.collected,
        color = blob.color,
        healAmount = blob.healAmount
    }
end

--[[
    Checks if blob is collected
    
    @param blob table Health blob object
    @return boolean True if collected
]]
function HealthBlob.isCollected(blob)
    return blob.collected
end

--[[
    Resets blob to uncollected state
    
    @param blob table Health blob object
]]
function HealthBlob.reset(blob)
    blob.collected = false
end

--[[
    Gets the heal amount
    
    @param blob table Health blob object
    @return number Heal amount
]]
function HealthBlob.getHealAmount(blob)
    return blob.healAmount
end

return HealthBlob
