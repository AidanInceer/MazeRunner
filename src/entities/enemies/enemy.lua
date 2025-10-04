local Enemy = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

-- Base enemy blueprint - extend this to create new enemy types
function Enemy.create(r, c, enemyType)
    local baseEnemy = {
        r = r,
        c = c,
        direction = math.random(1, 4),
        moveTimer = 0,
        moveInterval = GameConfig.ENEMY_MOVE_INTERVAL,
        type = enemyType or "default"
    }
    
    -- Allow enemy types to extend the base enemy
    -- This will be called by the specific enemy type's onCreate method
    
    return baseEnemy
end

function Enemy.update(enemy, maze, rows, cols, dt)
    enemy.moveTimer = enemy.moveTimer + dt
    
    if enemy.moveTimer >= enemy.moveInterval then
        enemy.moveTimer = 0
        return Enemy.move(enemy, maze, rows, cols)
    end
    
    return false
end

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
        
        -- Allow enemy types to handle pre-move logic
        if enemy.onBeforeMove then
            enemy.onBeforeMove(enemy, newR, newC)
        end
        
        enemy.r, enemy.c = newR, newC
        
        -- Allow enemy types to handle post-move logic
        if enemy.onAfterMove then
            enemy.onAfterMove(enemy, newR, newC)
        end
        
        return true
    else
        -- Choose new random direction if blocked
        enemy.direction = math.random(1, 4)
        return false
    end
end

function Enemy.checkPlayerCollision(enemy, player)
    return enemy.r == player.r and enemy.c == player.c
end

function Enemy.handlePlayerCollision(enemy, player)
    if player.immune and player.immunityKills > 0 then
        return "killed"
    elseif not player.immune then
        return "damaged"
    end
    return "none"
end

function Enemy.getRenderData(enemy)
    return {
        r = enemy.r,
        c = enemy.c,
        direction = enemy.direction,
        type = enemy.type
    }
end

function Enemy.createMultiple(count, maze, rows, cols, enemyType)
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
                table.insert(enemies, Enemy.create(r, c, enemyType))
                placed = placed + 1
            end
        end
    end
    
    return enemies
end

function Enemy.updateAll(enemies, maze, rows, cols, dt)
    local movedEnemies = {}
    
    for _, enemy in ipairs(enemies) do
        if Enemy.update(enemy, maze, rows, cols, dt) then
            table.insert(movedEnemies, enemy)
        end
    end
    
    return movedEnemies
end

function Enemy.removeFromList(enemies, enemy)
    for i = #enemies, 1, -1 do
        if enemies[i] == enemy then
            table.remove(enemies, i)
            return true
        end
    end
    return false
end

-- Hook functions that can be overridden by enemy types
function Enemy.onCreate(enemy, r, c)
    -- Override in enemy type implementations
end

function Enemy.onBeforeMove(enemy, newR, newC)
    -- Override in enemy type implementations
end

function Enemy.onAfterMove(enemy, newR, newC)
    -- Override in enemy type implementations
end

return Enemy