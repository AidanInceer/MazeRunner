

local CollectibleBlob = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

function CollectibleBlob.create(r, c)
    return {
        r = r,
        c = c,
        collected = false,
        value = 1,  -- Score value
        color = "yellow"
    }
end

function CollectibleBlob.canCollect(blob, player)
    return not blob.collected and blob.r == player.r and blob.c == player.c
end

function CollectibleBlob.collect(blob, player)
    if not blob.collected then
        blob.collected = true
        player.score = player.score + blob.value
        
        return {
            score = blob.value,
            particles = CollectibleBlob._createParticles(blob.r, blob.c)
        }
    end
    
    return nil
end

function CollectibleBlob._createParticles(r, c)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local cellSize, _, _, offsetX, offsetY = 
        Helpers.calculateGridDimensions(screenWidth, screenHeight, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS)
    
    local centerX = offsetX + (c - 1) * cellSize + cellSize / 2
    local centerY = offsetY + (r - 1) * cellSize + cellSize / 2
    
    return Helpers.createCircularParticles(
        centerX, centerY, 8, 100, GameConfig.PARTICLE_LIFE, 3, "yellow"
    )
end

function CollectibleBlob.placeMultiple(maze, rows, cols, count)
    local blobs = Helpers.create2DArray(rows, cols, false)
    local placed = 0
    local attempts = 0
    local maxAttempts = 500
    
    while placed < count and attempts < maxAttempts do
        attempts = attempts + 1
        local r = math.random(1, rows)
        local c = math.random(1, cols)
        
        if not maze[r][c] and not blobs[r][c] then
            blobs[r][c] = CollectibleBlob.create(r, c)
            placed = placed + 1
        end
    end
    
    return blobs
end

function CollectibleBlob.getRenderData(blob)
    return {
        r = blob.r,
        c = blob.c,
        collected = blob.collected,
        color = blob.color,
        value = blob.value
    }
end

function CollectibleBlob.isCollected(blob)
    return blob.collected
end

function CollectibleBlob.reset(blob)
    blob.collected = false
end

return CollectibleBlob
