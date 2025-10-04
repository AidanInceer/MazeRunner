local PoisonEnemy = {}
local Enemy = require("src.entities.enemies.enemy")
local GameConfig = require("src.config.game_config")

-- Extend the base enemy blueprint
PoisonEnemy.__index = Enemy
setmetatable(PoisonEnemy, Enemy)

function PoisonEnemy.create(r, c)
    local enemy = Enemy.create(r, c, "poison")
    -- Attach methods to the enemy instance
    enemy.move = Enemy.move
    enemy.handlePlayerCollision = PoisonEnemy.handlePlayerCollision
    enemy.getTrail = PoisonEnemy.getTrail
    enemy.onBeforeMove = PoisonEnemy.onBeforeMove
    enemy.onAfterMove = PoisonEnemy.onAfterMove
    -- Call onCreate hook
    PoisonEnemy.onCreate(enemy, r, c)
    return enemy
end

function PoisonEnemy.onCreate(enemy, r, c)
    -- Add poison-specific properties
    enemy.trail = {}  -- Track last 5 positions for poison trail
end

function PoisonEnemy.onBeforeMove(enemy, newR, newC)
    -- Add current position to trail before moving
    table.insert(enemy.trail, 1, {r = enemy.r, c = enemy.c})
    
    -- Keep only last 5 positions
    if #enemy.trail > GameConfig.POISON_TRAIL_LENGTH then
        table.remove(enemy.trail, #enemy.trail)
    end
end

function PoisonEnemy.onAfterMove(enemy, newR, newC)
    -- Poison enemy has no special post-move behavior
end

function PoisonEnemy.getTrail(enemy)
    return enemy.trail
end

function PoisonEnemy.handlePlayerCollision(enemy, player)
    if player.immune and player.immunityKills > 0 then
        return "killed"
    elseif not player.immune then
        return "poisoned"  -- Poison enemies poison instead of damage
    end
    return "none"
end

function PoisonEnemy.createMultiple(count, maze, rows, cols)
    return Enemy.createMultiple(count, maze, rows, cols, "poison")
end

function PoisonEnemy.update(enemy, maze, rows, cols, dt)
    return Enemy.update(enemy, maze, rows, cols, dt)
end

function PoisonEnemy.checkPlayerCollision(enemy, player)
    return Enemy.checkPlayerCollision(enemy, player)
end

function PoisonEnemy.updateAll(enemies, maze, rows, cols, dt)
    return Enemy.updateAll(enemies, maze, rows, cols, dt)
end

return PoisonEnemy