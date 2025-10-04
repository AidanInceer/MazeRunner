local DefaultEnemy = {}
local Enemy = require("src.entities.enemies.enemy")
local GameConfig = require("src.config.game_config")

-- Extend the base enemy blueprint
DefaultEnemy.__index = Enemy
setmetatable(DefaultEnemy, Enemy)

function DefaultEnemy.create(r, c, floor)
    local enemy = Enemy.create(r, c, "default", floor)
    -- Attach methods to the enemy instance
    enemy.move = Enemy.move
    enemy.handlePlayerCollision = DefaultEnemy.handlePlayerCollision
    enemy.onBeforeMove = DefaultEnemy.onBeforeMove
    enemy.onAfterMove = DefaultEnemy.onAfterMove
    -- Call onCreate hook
    DefaultEnemy.onCreate(enemy, r, c)
    return enemy
end

function DefaultEnemy.onCreate(enemy, r, c)
    -- Default enemy has no special properties
    -- Just uses the base enemy functionality
end

function DefaultEnemy.onBeforeMove(enemy, newR, newC)
    -- Default enemy has no special pre-move behavior
end

function DefaultEnemy.onAfterMove(enemy, newR, newC)
    -- Default enemy has no special post-move behavior
end

function DefaultEnemy.handlePlayerCollision(enemy, player)
    if player.immune and player.immunityKills > 0 then
        return "killed"
    elseif not player.immune then
        return "damaged"
    end
    return "none"
end

function DefaultEnemy.createMultiple(count, maze, rows, cols)
    return Enemy.createMultiple(count, maze, rows, cols, "default")
end

function DefaultEnemy.updateAll(enemies, maze, rows, cols, dt)
    return Enemy.updateAll(enemies, maze, rows, cols, dt)
end

return DefaultEnemy
