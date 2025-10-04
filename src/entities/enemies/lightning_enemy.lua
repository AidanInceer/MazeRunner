local LightningEnemy = {}
local Enemy = require("src.entities.enemies.enemy")
local GameConfig = require("src.config.game_config")

function LightningEnemy.create(r, c)
    local enemy = Enemy.create(r, c, "lightning")
    
    -- Lightning-specific properties
    enemy.color = "light_blue"
    enemy.lightningEffect = true
    
    -- Initialize lightning-specific properties
    LightningEnemy.onCreate(enemy)
    
    return enemy
end

function LightningEnemy.onCreate(enemy)
    -- Lightning enemy specific initialization
    enemy.lightningTimer = 0
    enemy.lightningInterval = 0.1  -- Lightning effect frequency
end

function LightningEnemy.update(enemy, maze, rows, cols, dt)
    -- Update lightning effect timer
    enemy.lightningTimer = enemy.lightningTimer + dt
    
    -- Use base enemy movement logic
    return Enemy.update(enemy, maze, rows, cols, dt)
end

function LightningEnemy.checkPlayerCollision(enemy, player)
    return Enemy.checkPlayerCollision(enemy, player)
end

function LightningEnemy.handlePlayerCollision(enemy, player)
    if player.immune and player.immunityKills > 0 then
        return "killed"
    elseif not player.immune then
        return "damaged"  -- Lightning enemies damage the player
    end
    return "none"
end

function LightningEnemy.onBeforeMove(enemy, newR, newC)
    -- Lightning enemies can move through some obstacles
end

function LightningEnemy.onAfterMove(enemy, newR, newC)
    -- Lightning effect after moving
end

function LightningEnemy.getAnimationData(enemy)
    return {
        lightningTimer = enemy.lightningTimer,
        lightningInterval = enemy.lightningInterval
    }
end

function LightningEnemy.createMultiple(count, maze, rows, cols)
    return Enemy.createMultiple(count, maze, rows, cols, "lightning")
end

return LightningEnemy
