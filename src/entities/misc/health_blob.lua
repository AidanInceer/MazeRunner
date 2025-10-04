local HealthBlob = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

function HealthBlob.create(r, c)
    return {
        r = r,
        c = c,
        collected = false,
        healAmount = GameConfig.HEALTH_RESTORE,
        color = "green"
    }
end

function HealthBlob.canCollect(blob, player)
    return not blob.collected and blob.r == player.r and blob.c == player.c
end

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

function HealthBlob.getRenderData(blob)
    return {
        r = blob.r,
        c = blob.c,
        collected = blob.collected,
        color = blob.color,
        healAmount = blob.healAmount
    }
end

function HealthBlob.isCollected(blob)
    return blob.collected
end

function HealthBlob.reset(blob)
    blob.collected = false
end

function HealthBlob.getHealAmount(blob)
    return blob.healAmount
end

return HealthBlob
