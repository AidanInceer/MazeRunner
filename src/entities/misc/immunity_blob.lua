-- Immunity blob entity for granting temporary immunity and enemy-killing ability
local ImmunityBlob = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

function ImmunityBlob.create(r, c)
    return {
        r = r,
        c = c,
        collected = false,
        immunityKills = 1,  -- Number of enemies that can be killed
        color = "red"
    }
end

function ImmunityBlob.canCollect(blob, player)
    return not blob.collected and blob.r == player.r and blob.c == player.c
end

function ImmunityBlob.collect(blob, player)
    if not blob.collected then
        blob.collected = true
        player.immune = true
        player.immunityKills = player.immunityKills + blob.immunityKills
        
        return {
            immunityKills = blob.immunityKills,
            particles = ImmunityBlob._createParticles(blob.r, blob.c)
        }
    end
    
    return nil
end

function ImmunityBlob._createParticles(r, c)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local cellSize, _, _, offsetX, offsetY = 
        Helpers.calculateGridDimensions(screenWidth, screenHeight, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS)
    
    local centerX = offsetX + (c - 1) * cellSize + cellSize / 2
    local centerY = offsetY + (r - 1) * cellSize + cellSize / 2
    
    return Helpers.createCircularParticles(
        centerX, centerY, 8, 100, GameConfig.IMMUNITY_PARTICLE_LIFE, 3, "red"
    )
end

function ImmunityBlob.placeMultiple(maze, rows, cols, count)
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
            blobs[r][c] = ImmunityBlob.create(r, c)
            placed = placed + 1
        end
    end
    
    return blobs
end

function ImmunityBlob.getRenderData(blob)
    return {
        r = blob.r,
        c = blob.c,
        collected = blob.collected,
        color = blob.color,
        immunityKills = blob.immunityKills
    }
end

function ImmunityBlob.isCollected(blob)
    return blob.collected
end

function ImmunityBlob.reset(blob)
    blob.collected = false
end

function ImmunityBlob.getImmunityKills(blob)
    return blob.immunityKills
end

return ImmunityBlob
