local SplashEnemy = {}
local Enemy = require("src.entities.enemies.enemy")
local GameConfig = require("src.config.game_config")

-- Extend the base enemy blueprint
SplashEnemy.__index = Enemy
setmetatable(SplashEnemy, Enemy)

function SplashEnemy.create(r, c)
    local enemy = Enemy.create(r, c, "splash")
    -- Attach methods to the enemy instance
    enemy.move = Enemy.move
    enemy.handlePlayerCollision = SplashEnemy.handlePlayerCollision
    enemy.onBeforeMove = SplashEnemy.onBeforeMove
    enemy.onAfterMove = SplashEnemy.onAfterMove
    -- Call onCreate hook
    SplashEnemy.onCreate(enemy, r, c)
    return enemy
end

function SplashEnemy.onCreate(enemy, r, c)
    -- Add splash-specific properties
    enemy.splashTimer = 0
    enemy.splashInterval = 4.0  -- Splash every 3 seconds
    enemy.isSplashing = false
    enemy.splashDuration = 0
    enemy.splashMaxDuration = 2.0  -- Burn for 3 seconds
    enemy.animationTimer = 0
    enemy.animationPhase = 0  -- 0: normal, 1: jumping, 2: flashing
    enemy.originalY = 0  -- For jump animation
end

function SplashEnemy.onBeforeMove(enemy, newR, newC)
    -- Splash enemy has no special pre-move behavior
end

function SplashEnemy.onAfterMove(enemy, newR, newC)
    -- Splash enemy has no special post-move behavior
end

function SplashEnemy.handlePlayerCollision(enemy, player)
    if player.immune and player.immunityKills > 0 then
        return "killed"
    elseif not player.immune then
        return "damaged"
    end
    return "none"
end

function SplashEnemy.update(enemy, maze, rows, cols, dt)
    -- Update splash timer
    enemy.splashTimer = enemy.splashTimer + dt
    
    -- Update animation
    enemy.animationTimer = enemy.animationTimer + dt
    
    -- Check if it's time to splash
    if enemy.splashTimer >= enemy.splashInterval then
        enemy.splashTimer = 0
        enemy.isSplashing = true
        enemy.splashDuration = 0
        enemy.animationPhase = 1  -- Start jump animation
        enemy.animationTimer = 0
    end
    
    -- Update splash duration
    if enemy.isSplashing then
        enemy.splashDuration = enemy.splashDuration + dt
        
        -- Handle animation phases
        if enemy.animationPhase == 1 and enemy.animationTimer >= 0.2 then
            enemy.animationPhase = 2  -- Switch to flash
            enemy.animationTimer = 0
        end
        
        -- End splash after duration
        if enemy.splashDuration >= enemy.splashMaxDuration then
            enemy.isSplashing = false
            enemy.animationPhase = 0  -- Back to normal
            enemy.animationTimer = 0
        end
        
        -- Don't move while splashing - stay stationary
        return false
    else
        -- Only move when not splashing
        return Enemy.update(enemy, maze, rows, cols, dt)
    end
end

function SplashEnemy.checkPlayerCollision(enemy, player)
    return Enemy.checkPlayerCollision(enemy, player)
end

function SplashEnemy.getSplashArea(enemy)
    -- Return the 3x3 area around the enemy (excluding walls)
    local splashArea = {}
    for dr = -1, 1 do
        for dc = -1, 1 do
            local newR = enemy.r + dr
            local newC = enemy.c + dc
            table.insert(splashArea, {r = newR, c = newC})
        end
    end
    return splashArea
end

function SplashEnemy.isSplashActive(enemy)
    return enemy.isSplashing
end

function SplashEnemy.getAnimationData(enemy)
    return {
        phase = enemy.animationPhase,
        timer = enemy.animationTimer,
        isSplashing = enemy.isSplashing
    }
end

function SplashEnemy.createMultiple(count, maze, rows, cols)
    return Enemy.createMultiple(count, maze, rows, cols, "splash")
end

function SplashEnemy.updateAll(enemies, maze, rows, cols, dt)
    local movedEnemies = {}
    
    for _, enemy in ipairs(enemies) do
        if SplashEnemy.update(enemy, maze, rows, cols, dt) then
            table.insert(movedEnemies, enemy)
        end
    end
    
    return movedEnemies
end

return SplashEnemy
