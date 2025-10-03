--[[
    Enemy Entity Module
    
    Handles enemy movement, AI behavior, and collision detection.
    Manages individual enemy state and movement patterns.
]]

local Enemy = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

--[[
    Creates a new enemy instance
    
    @param r number Starting row position
    @param c number Starting column position
    @return table Enemy object
]]
function Enemy.create(r, c)
    return {
        r = r,
        c = c,
        direction = math.random(1, 4),  -- Random initial direction
        moveTimer = 0,
        moveInterval = GameConfig.ENEMY_MOVE_INTERVAL
    }
end

--[[
    Updates enemy movement
    
    @param enemy table Enemy object
    @param maze table 2D maze array
    @param rows number Number of maze rows
    @param cols number Number of maze columns
    @param dt number Delta time
    @return boolean True if enemy moved
]]
function Enemy.update(enemy, maze, rows, cols, dt)
    enemy.moveTimer = enemy.moveTimer + dt
    
    if enemy.moveTimer >= enemy.moveInterval then
        enemy.moveTimer = 0
        return Enemy.move(enemy, maze, rows, cols)
    end
    
    return false
end

--[[
    Moves the enemy in its current direction
    
    @param enemy table Enemy object
    @param maze table 2D maze array
    @param rows number Number of maze rows
    @param cols number Number of maze columns
    @return boolean True if enemy moved
]]
function Enemy.move(enemy, maze, rows, cols)
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
        enemy.r, enemy.c = newR, newC
        return true
    else
        -- Choose new random direction if blocked
        enemy.direction = math.random(1, 4)
        return false
    end
end

--[[
    Checks collision with player
    
    @param enemy table Enemy object
    @param player table Player object
    @return boolean True if colliding with player
]]
function Enemy.checkPlayerCollision(enemy, player)
    return enemy.r == player.r and enemy.c == player.c
end

--[[
    Handles collision with player
    
    @param enemy table Enemy object
    @param player table Player object
    @return string Collision result ("killed", "damaged", "none")
]]
function Enemy.handlePlayerCollision(enemy, player)
    if player.immune and player.immunityKills > 0 then
        return "killed"
    elseif not player.immune then
        return "damaged"
    end
    return "none"
end

--[[
    Gets enemy render data
    
    @param enemy table Enemy object
    @return table Enemy render data
]]
function Enemy.getRenderData(enemy)
    return {
        r = enemy.r,
        c = enemy.c,
        direction = enemy.direction
    }
end

--[[
    Creates multiple enemies
    
    @param count number Number of enemies to create
    @param maze table 2D maze array
    @param rows number Number of maze rows
    @param cols number Number of maze columns
    @return table Array of enemy objects
]]
function Enemy.createMultiple(count, maze, rows, cols)
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
                table.insert(enemies, Enemy.create(r, c))
                placed = placed + 1
            end
        end
    end
    
    return enemies
end

--[[
    Updates all enemies in a list
    
    @param enemies table Array of enemy objects
    @param maze table 2D maze array
    @param rows number Number of maze rows
    @param cols number Number of maze columns
    @param dt number Delta time
    @return table Array of enemies that moved
]]
function Enemy.updateAll(enemies, maze, rows, cols, dt)
    local movedEnemies = {}
    
    for _, enemy in ipairs(enemies) do
        if Enemy.update(enemy, maze, rows, cols, dt) then
            table.insert(movedEnemies, enemy)
        end
    end
    
    return movedEnemies
end

--[[
    Removes an enemy from a list
    
    @param enemies table Array of enemy objects
    @param enemy table Enemy to remove
    @return boolean True if enemy was removed
]]
function Enemy.removeFromList(enemies, enemy)
    for i = #enemies, 1, -1 do
        if enemies[i] == enemy then
            table.remove(enemies, i)
            return true
        end
    end
    return false
end

return Enemy
