local BlobEnemy = {}
local Enemy = require("src.entities.enemies.enemy")
local GameConfig = require("src.config.game_config")

function BlobEnemy.create(r, c)
    local enemy = Enemy.create(r, c, "blob")
    
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

function BlobEnemy.update(enemy, maze, rows, cols, dt)
    -- Update blob animation
    enemy.blobTimer = enemy.blobTimer + dt
    enemy.blobPulse = 0.8 + 0.2 * math.sin(enemy.blobTimer * 3)
    
    -- Use base enemy movement logic
    return Enemy.update(enemy, maze, rows, cols, dt)
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

function BlobEnemy.onBeforeMove(enemy, newR, newC)
    -- Blob needs to check if all 4 cells are available
    -- This function is called by the base enemy movement, but we need to override
    -- the movement logic entirely for blob enemies since they're 2x2
    return true  -- Let the base movement handle the basic validation
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
