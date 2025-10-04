local BlobEnemy = {}
local Enemy = require("src.entities.enemies.enemy")
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

function BlobEnemy.create(r, c, floor)
    local enemy = Enemy.create(r, c, "blob", floor)
    
    -- Blob-specific properties
    enemy.color = "black"
    enemy.size = 2  -- 2x2 blob
    enemy.blobCells = {}  -- Track all cells occupied by blob
    
    -- Initialize blob-specific properties
    BlobEnemy.onCreate(enemy)
    
    return enemy
end

function BlobEnemy.onCreate(enemy)
    -- Blob enemy specific initialization
    enemy.blobTimer = 0
    enemy.blobPulse = 0
end

function BlobEnemy.update(enemy, maze, rows, cols, dt, elevatedZones)
    -- Update blob animation
    enemy.blobTimer = enemy.blobTimer + dt
    enemy.blobPulse = 0.8 + 0.2 * math.sin(enemy.blobTimer * 3)
    
    -- Update movement animation
    if enemy.animProgress < 1.0 then
        enemy.animProgress = enemy.animProgress + dt * enemy.animSpeed
        if enemy.animProgress >= 1.0 then
            enemy.animProgress = 1.0
            enemy.animR = enemy.targetR
            enemy.animC = enemy.targetC
        else
            -- Interpolate between starting position and target position with smooth easing
            local easedProgress = Enemy._easeInOutCubic(enemy.animProgress)
            enemy.animR = enemy.startR + (enemy.targetR - enemy.startR) * easedProgress
            enemy.animC = enemy.startC + (enemy.targetC - enemy.startC) * easedProgress
        end
    end
    
    -- Use custom blob movement logic that checks all 4 cells
    return BlobEnemy.move(enemy, maze, rows, cols, dt, elevatedZones)
end

function BlobEnemy.checkPlayerCollision(enemy, player)
    -- Check collision with any part of the 2x2 blob
    local blobR1, blobC1 = enemy.r, enemy.c
    local blobR2, blobC2 = enemy.r + 1, enemy.c
    local blobR3, blobC3 = enemy.r, enemy.c + 1
    local blobR4, blobC4 = enemy.r + 1, enemy.c + 1
    
    return (player.r == blobR1 and player.c == blobC1) or
           (player.r == blobR2 and player.c == blobC2) or
           (player.r == blobR3 and player.c == blobC3) or
           (player.r == blobR4 and player.c == blobC4)
end

function BlobEnemy.handlePlayerCollision(enemy, player)
    if player.immune and player.immunityKills > 0 then
        return "killed"
    elseif not player.immune then
        return "damaged"  -- Blob enemies damage the player
    end
    return "none"
end

function BlobEnemy.move(enemy, maze, rows, cols, dt, elevatedZones)
    -- Custom movement logic for 2x2 blob enemies
    local MultiTierGenerator = require("src.world.multi_tier_generator")
    enemy.moveTimer = (enemy.moveTimer or 0) + dt
    
    if enemy.moveTimer >= enemy.moveInterval then
        enemy.moveTimer = 0
        
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
        
        -- Check floor compatibility for all 4 cells of the 2x2 blob
        local currentFloor = enemy.floor or GameConfig.FLOOR_LEVELS.GROUND
        local canMove = true
        local targetFloor = currentFloor
        
        -- Check all 4 cells for walkability and floor compatibility
        for dr = 0, 1 do
            for dc = 0, 1 do
                local checkR = newR + dr
                local checkC = newC + dc
                
                -- Check basic validity
                if not Helpers.isValidPosition(checkR, checkC, rows, cols) or
                   (maze[checkR][checkC] and maze[checkR][checkC] ~= "spawn" and maze[checkR][checkC] ~= "finale") then
                    canMove = false
                    break
                end
                
                -- Check floor level
                local cellFloor = MultiTierGenerator.getFloorLevel(checkR, checkC, elevatedZones or {})
                if cellFloor ~= "ramp" and cellFloor ~= currentFloor then
                    canMove = false
                    break
                end
                
                -- Update target floor if moving onto ramp
                if cellFloor == "ramp" then
                    targetFloor = (currentFloor == GameConfig.FLOOR_LEVELS.GROUND) and GameConfig.FLOOR_LEVELS.ELEVATED or GameConfig.FLOOR_LEVELS.GROUND
                end
            end
            if not canMove then break end
        end
        
        if canMove then
            -- Set up animation for smooth movement
            enemy.targetR = newR
            enemy.targetC = newC
            enemy.animProgress = 0.0
            enemy.startR = enemy.r
            enemy.startC = enemy.c
            
            -- Update actual position immediately for collision detection
            enemy.r, enemy.c = newR, newC
            enemy.floor = targetFloor  -- Update floor level
            
            -- Update blob cell positions
            BlobEnemy.onAfterMove(enemy, newR, newC)
            
            return true
        else
            -- Choose new random direction if blocked
            enemy.direction = math.random(1, 4)
        end
    end
    
    return false
end

function BlobEnemy.onBeforeMove(enemy, newR, newC)
    -- This function is no longer used since we override the move function
    return true
end

function BlobEnemy.onAfterMove(enemy, newR, newC)
    -- Update blob cell positions
    enemy.blobCells = {
        {r = newR, c = newC},
        {r = newR + 1, c = newC},
        {r = newR, c = newC + 1},
        {r = newR + 1, c = newC + 1}
    }
end

function BlobEnemy.getAnimationData(enemy)
    return {
        blobTimer = enemy.blobTimer,
        blobPulse = enemy.blobPulse,
        size = enemy.size
    }
end

function BlobEnemy.createMultiple(count, maze, rows, cols)
    return Enemy.createMultiple(count, maze, rows, cols, "blob")
end

return BlobEnemy
