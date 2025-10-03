-- Poison Enemy Entity Module
local PoisonEnemy = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

-- Creates a new poison enemy instance
function PoisonEnemy.create(r, c)
    return {
        r = r,
        c = c,
        direction = math.random(1, 4),
        moveTimer = 0,
        moveInterval = GameConfig.ENEMY_MOVE_INTERVAL,
        trail = {},  -- Track last 5 positions
        type = "poison"
    }
end

-- Updates poison enemy movement
function PoisonEnemy.update(enemy, maze, rows, cols, dt)
    enemy.moveTimer = enemy.moveTimer + dt
    
    if enemy.moveTimer >= enemy.moveInterval then
        enemy.moveTimer = 0
        return PoisonEnemy.move(enemy, maze, rows, cols)
    end
    
    return false
end

-- Moves the poison enemy and manages trail
function PoisonEnemy.move(enemy, maze, rows, cols)
    local newR, newC = enemy.r, enemy.c
    
    -- Calculate new position based on direction
    if enemy.direction == GameConfig.DIRECTIONS.UP then
        newR = newR - 1
    elseif enemy.direction == GameConfig.DIRECTIONS.DOWN then
        newR = newR + 1
    elseif enemy.direction == GameConfig.DIRECTIONS.LEFT then
        newC = newC - 1
    elseif enemy.direction == GameConfig.DIRECTIONS.RIGHT then
        newC = newC + 1
    end
    
    -- Check if move is valid
    if Helpers.isValidPosition(newR, newC, rows, cols) and
       (not maze[newR][newC] or maze[newR][newC] == "spawn" or maze[newR][newC] == "finale") then
        
        -- Add current position to trail before moving
        table.insert(enemy.trail, 1, {r = enemy.r, c = enemy.c})
        
        -- Keep only last 5 positions
        if #enemy.trail > GameConfig.POISON_TRAIL_LENGTH then
            table.remove(enemy.trail, #enemy.trail)
        end
        
        -- Update position
        enemy.r, enemy.c = newR, newC
        return true
    else
        -- Choose new random direction if blocked
        enemy.direction = math.random(1, 4)
        return false
    end
end

-- Gets the poison trail positions
function PoisonEnemy.getTrail(enemy)
    return enemy.trail
end

-- Checks collision with player
function PoisonEnemy.checkPlayerCollision(enemy, player)
    return enemy.r == player.r and enemy.c == player.c
end

-- Handles collision with player
function PoisonEnemy.handlePlayerCollision(enemy, player)
    if player.immune and player.immunityKills > 0 then
        return "killed"
    elseif not player.immune then
        return "poisoned"  -- Poison enemies poison instead of damage
    end
    return "none"
end

-- Gets enemy render data
function PoisonEnemy.getRenderData(enemy)
    return {
        r = enemy.r,
        c = enemy.c,
        direction = enemy.direction,
        type = enemy.type
    }
end

-- Creates multiple poison enemies
function PoisonEnemy.createMultiple(count, maze, rows, cols)
    local enemies = {}
    local placed = 0
    local attempts = 0
    local maxAttempts = 200
    
    while placed < count and attempts < maxAttempts do
        attempts = attempts + 1
        local r = math.random(1, rows)
        local c = math.random(1, cols)
        
        if not maze[r][c] and maze[r][c] ~= "spawn" and maze[r][c] ~= "finale" then
            -- Check if position is not occupied by another enemy
            local positionOccupied = false
            for _, enemy in ipairs(enemies) do
                if enemy.r == r and enemy.c == c then
                    positionOccupied = true
                    break
                end
            end
            
            if not positionOccupied then
                table.insert(enemies, PoisonEnemy.create(r, c))
                placed = placed + 1
            end
        end
    end
    
    return enemies
end

-- Updates all poison enemies in a list
function PoisonEnemy.updateAll(enemies, maze, rows, cols, dt)
    local movedEnemies = {}
    
    for _, enemy in ipairs(enemies) do
        if PoisonEnemy.update(enemy, maze, rows, cols, dt) then
            table.insert(movedEnemies, enemy)
        end
    end
    
    return movedEnemies
end

return PoisonEnemy
