-- Game logic and mechanics handling
local GameLogic = {}
local GameConfig = require("src.config.game_config")
local LevelConfig = require("src.config.level_config")
local LevelManager = require("src.core.level_manager")
local GameState = require("src.core.game_state")
local WorldManager = require("src.world.world_manager")
local Helpers = require("src.utils.helpers")
local PoisonEnemy = require("src.entities.enemies.poison_enemy")
local SplashEnemy = require("src.entities.enemies.splash_enemy")
local BlobEnemy = require("src.entities.enemies.blob_enemy")
local LightningEnemy = require("src.entities.enemies.lightning_enemy")

-- Handle item collection when player moves to a new position
function GameLogic.handleItemCollection(r, c, gameObjects)
    local collected = false
    local particles = {}
    
    -- Check collectibles
    if gameObjects.collectibles[r][c] then
        gameObjects.collectibles[r][c] = false
        GameState.addScore(1)
        collected = true
        
        -- Create collection particles
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local cellSize, _, _, offsetX, offsetY = 
            Helpers.calculateGridDimensions(screenWidth, screenHeight, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS)
        local centerX = offsetX + (c - 1) * cellSize + cellSize / 2
        local centerY = offsetY + (r - 1) * cellSize + cellSize / 2
        
        particles = Helpers.createCircularParticles(
            centerX, centerY, 6, 80, GameConfig.PARTICLE_LIFE, 2, "yellow"
        )
    end
    
    -- Check damage tiles
    if gameObjects.damageTiles[r][c] then
        GameState.takeDamage(GameConfig.TILE_DAMAGE.DAMAGE_TILE)
        GameState.setHitFlash(GameConfig.HIT_FLASH_DURATION)
    end
    
    -- Check health blobs
    if gameObjects.healthBlobs[r][c] then
        gameObjects.healthBlobs[r][c] = false
        GameState.heal(GameConfig.HEALTH_RESTORE)
        collected = true
        
        -- Create healing particles
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local cellSize, _, _, offsetX, offsetY = 
            Helpers.calculateGridDimensions(screenWidth, screenHeight, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS)
        local centerX = offsetX + (c - 1) * cellSize + cellSize / 2
        local centerY = offsetY + (r - 1) * cellSize + cellSize / 2
        
        particles = Helpers.createCircularParticles(
            centerX, centerY, 8, 100, GameConfig.PARTICLE_LIFE, 3, "green"
        )
    end
    
    -- Check immunity blobs
    if gameObjects.immunityBlobs[r][c] then
        gameObjects.immunityBlobs[r][c] = false
        GameState.grantImmunity(GameConfig.IMMUNITY_BLOB_KILLS)
        collected = true
        
        -- Create immunity particles
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local cellSize, _, _, offsetX, offsetY = 
            Helpers.calculateGridDimensions(screenWidth, screenHeight, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS)
        local centerX = offsetX + (c - 1) * cellSize + cellSize / 2
        local centerY = offsetY + (r - 1) * cellSize + cellSize / 2
        
        particles = Helpers.createCircularParticles(
            centerX, centerY, 8, 100, GameConfig.IMMUNITY_PARTICLE_LIFE, 3, "red"
        )
    end
    
    if collected then
        GameState.addParticles(particles)
    end
end

-- Handle player movement input
function GameLogic.handlePlayerMovement(key)
    local gameObjects = GameState.getGameObjects()
    local playerData = GameState.getPlayerData()
    local newR, newC = playerData.r, playerData.c
    
    -- Calculate new position based on input
    if key == "w" or key == "up" then
        newR = newR - 1
    elseif key == "s" or key == "down" then
        newR = newR + 1
    elseif key == "a" or key == "left" then
        newC = newC - 1
    elseif key == "d" or key == "right" then
        newC = newC + 1
    else
        return  -- Invalid key
    end
    
    -- Check if move is valid (allow movement to walkable areas and special tiles)
    local canMove = Helpers.isValidPosition(newR, newC, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS) and
                   (not gameObjects.maze[newR][newC] or gameObjects.maze[newR][newC] == "spawn" or gameObjects.maze[newR][newC] == "finale")
    
    if canMove then
        -- Check for enemy collision at new position
        if gameObjects.enemies[newR] and gameObjects.enemies[newR][newC] then
            -- Player is moving into an enemy
            if playerData.immune and playerData.immunityKills > 0 then
                -- Kill enemy
                gameObjects.enemies[newR][newC] = false
                GameState.killEnemy()
                -- Allow movement after killing enemy
            else
                -- Damage player and prevent movement
                GameState.takeDamage(GameConfig.ENEMY_DAMAGE.DEFAULT)
                GameState.setHitFlash(GameConfig.ENEMY_HIT_FLASH_DURATION)
                return  -- Don't move the player
            end
        end
        
        -- Check for poison enemy collision at new position
        if gameObjects.poisonEnemies then
            for _, poisonEnemy in ipairs(gameObjects.poisonEnemies) do
                if poisonEnemy.r == newR and poisonEnemy.c == newC then
                    -- Player is moving into a poison enemy
                    if playerData.immune and playerData.immunityKills > 0 then
                        -- Kill poison enemy
                        poisonEnemy.r = -1  -- Mark for removal
                        GameState.killEnemy()
                        -- Allow movement after killing enemy
                    else
                        -- Poison player and prevent movement
                        GameState.setPlayerPoisoned(true, GameConfig.POISON_DURATION)
                        GameState.setHitFlash(GameConfig.ENEMY_HIT_FLASH_DURATION)
                        return  -- Don't move the player
                    end
                end
            end
        end
        
        -- Check for splash enemy collision at new position
        if gameObjects.splashEnemies then
            for _, splashEnemy in ipairs(gameObjects.splashEnemies) do
                if splashEnemy.r == newR and splashEnemy.c == newC then
                    -- Player is moving into a splash enemy
                    if playerData.immune and playerData.immunityKills > 0 then
                        -- Kill splash enemy
                        splashEnemy.r = -1  -- Mark for removal
                        GameState.killEnemy()
                        -- Allow movement after killing enemy
                    else
                        -- Damage player and prevent movement
                        GameState.takeDamage(GameConfig.ENEMY_DAMAGE.SPLASH)
                        GameState.setHitFlash(GameConfig.ENEMY_HIT_FLASH_DURATION)
                        return  -- Don't move the player
                    end
                end
            end
        end
        
        GameState.setPlayerPosition(newR, newC)
        GameState.markVisited(newR, newC)
        
        -- Handle item collection
        GameLogic.handleItemCollection(newR, newC, gameObjects)
        
        -- Check win condition (collect 5 yellow blobs AND reach exit tile)
        if gameObjects.maze[newR][newC] == "finale" then
            local playerData = GameState.getPlayerData()
            
            if playerData.score >= GameConfig.REQUIRED_COLLECTIBLES then
                LevelManager.completeLevel()
                if LevelManager.isGameComplete() then
                    GameState.getAllState().gameWon = true
                    GameState.setGameState(GameConfig.STATES.GAME_WON)
                else
                    -- Level completed, generate next level
                    local worldData = WorldManager.generateGameWorld()
                    GameState.setPlayerPosition(worldData.spawnR, worldData.spawnC)
                    GameState.setCurrentLevel(LevelManager.getCurrentLevel())
                    GameState.setGameObjects(worldData)
                    -- Reset score and immunity for new level
                    GameState.setPlayerScore(0)
                    GameState.setImmunity(false, 0)
                    GameState.setGameState(GameConfig.STATES.PLAYING)
                end
            else
                -- Not enough blobs collected, show message
                GameState.setGameState(GameConfig.STATES.INSUFFICIENT_SCORE)
            end
        end
    end
end

-- Update enemy movement
function GameLogic.updateParticles(dt)
    local animationData = GameState.getAnimationData()
    local particles = animationData.collectParticles
    
    for i = #particles, 1, -1 do
        local particle = particles[i]
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
        particle.life = particle.life - dt
        
        if particle.life <= 0 then
            table.remove(particles, i)
        end
    end
end

function GameLogic.updateEnemyAnimations(dt)
    local gameObjects = GameState.getGameObjects()
    
    -- Update animations for all enemies
    for r = 1, GameConfig.MAZE_ROWS do
        for c = 1, GameConfig.MAZE_COLS do
            if gameObjects.enemies[r][c] then
                local enemy = gameObjects.enemies[r][c]
                
                -- Update animation progress
                if enemy.animProgress < 1.0 then
                    local animSpeed = enemy.animSpeed or 2.5  -- Even slower, smoother animation
                    enemy.animProgress = enemy.animProgress + dt * animSpeed
                    if enemy.animProgress >= 1.0 then
                        enemy.animProgress = 1.0
                        enemy.animR = enemy.targetR
                        enemy.animC = enemy.targetC
                    else
                        -- Interpolate between starting position and target position with smooth easing
                        local easedProgress = GameLogic._easeInOutCubic(enemy.animProgress)
                        enemy.animR = enemy.startR + (enemy.targetR - enemy.startR) * easedProgress
                        enemy.animC = enemy.startC + (enemy.targetC - enemy.startC) * easedProgress
                    end
                end
            end
        end
    end
end

function GameLogic.updateEnemies(dt)
    local gameObjects = GameState.getGameObjects()
    local playerData = GameState.getPlayerData()
    
    -- Update enemy animations
    GameLogic.updateEnemyAnimations(dt)
    
    -- Update each enemy type with their specific move timers
    GameLogic.updateEnemyType(gameObjects.enemies, "default", dt, gameObjects, playerData)
    
    -- Update special enemy types with their specific behaviors
    GameLogic.updatePoisonEnemies(dt)
    GameLogic.updateSplashEnemies(dt)
    GameLogic.updateBlobEnemies(dt)
    GameLogic.updateLightningEnemies(dt)
end

function GameLogic.updateEnemyType(enemies, enemyType, dt, gameObjects, playerData)
    if not enemies then return end
    
    local moveInterval = GameConfig.ENEMY_SPEEDS[enemyType:upper()]
    if not moveInterval then return end
    
    -- Handle 2D array for default enemies
    if enemyType == "default" then
        for r = 1, GameConfig.MAZE_ROWS do
            for c = 1, GameConfig.MAZE_COLS do
                if enemies[r][c] then
                    local enemy = enemies[r][c]
                    enemy.moveTimer = (enemy.moveTimer or 0) + dt
                    
                    if enemy.moveTimer >= moveInterval then
                        enemy.moveTimer = 0
                        GameLogic.moveEnemy(enemy, r, c, gameObjects, playerData)
                    end
                end
            end
        end
    else
        -- Handle 1D array for poison and splash enemies
        for i, enemy in ipairs(enemies) do
            enemy.moveTimer = (enemy.moveTimer or 0) + dt
            
            if enemy.moveTimer >= moveInterval then
                enemy.moveTimer = 0
                GameLogic.moveEnemy(enemy, enemy.r, enemy.c, gameObjects, playerData)
            end
        end
    end
end

function GameLogic.moveEnemy(enemy, currentR, currentC, gameObjects, playerData)
    local newR, newC = enemy.r, enemy.c
    
    -- Random direction
    local direction = math.random(1, 4)
    if direction == GameConfig.DIRECTIONS.UP then
        newR = newR - 1
    elseif direction == GameConfig.DIRECTIONS.DOWN then
        newR = newR + 1
    elseif direction == GameConfig.DIRECTIONS.LEFT then
        newC = newC - 1
    elseif direction == GameConfig.DIRECTIONS.RIGHT then
        newC = newC + 1
    end
    
    -- Check if move is valid
    if Helpers.isValidPosition(newR, newC, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS) and
       not gameObjects.maze[newR][newC] and
       not gameObjects.enemies[newR][newC] then
        
        -- Set up smooth animation BEFORE updating position
        enemy.targetR = newR
        enemy.targetC = newC
        enemy.animProgress = 0.0
        enemy.startR = enemy.r
        enemy.startC = enemy.c
        
        -- Remove from old position (only for default enemies in 2D array)
        if gameObjects.enemies[currentR] and gameObjects.enemies[currentR][currentC] then
            gameObjects.enemies[currentR][currentC] = false
        end
        
        -- Update enemy position
        enemy.r = newR
        enemy.c = newC
        
        -- Add to new position (only for default enemies in 2D array)
        if gameObjects.enemies[newR] then
            gameObjects.enemies[newR][newC] = enemy
        end
        
        -- Check collision with player
        if newR == playerData.r and newC == playerData.c then
            if playerData.immune and playerData.immunityKills > 0 then
                -- Kill enemy
                if gameObjects.enemies[newR] then
                    gameObjects.enemies[newR][newC] = false
                end
                GameState.killEnemy()
            else
                -- Damage player based on enemy type
                local damage = GameConfig.ENEMY_DAMAGE.DEFAULT
                if enemy.type == "poison" then
                    damage = GameConfig.ENEMY_DAMAGE.POISON
                elseif enemy.type == "splash" then
                    damage = GameConfig.ENEMY_DAMAGE.SPLASH
                end
                GameState.takeDamage(damage)
                GameState.setHitFlash(GameConfig.ENEMY_HIT_FLASH_DURATION)
            end
        end
    end
end

-- Update poison enemies and manage poison tiles
function GameLogic.updatePoisonEnemies(dt)
    local gameObjects = GameState.getGameObjects()
    local playerData = GameState.getPlayerData()
    
    -- Ensure poison arrays are initialized
    if not gameObjects.poisonEnemies then
        gameObjects.poisonEnemies = {}
    end
    if not gameObjects.poisonTiles then
        gameObjects.poisonTiles = {}
    end
    
    local poisonEnemies = gameObjects.poisonEnemies
    local poisonTiles = gameObjects.poisonTiles
    
    -- Update poison enemies
    for i = #poisonEnemies, 1, -1 do
        local poisonEnemy = poisonEnemies[i]
        
        -- Remove dead enemies
        if poisonEnemy.r == -1 then
            table.remove(poisonEnemies, i)
        else
            -- Update enemy movement
            if PoisonEnemy.update(poisonEnemy, gameObjects.maze, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS, dt) then
                -- Enemy moved, add trail positions to poison tiles
                local trail = PoisonEnemy.getTrail(poisonEnemy)
                for _, pos in ipairs(trail) do
                    -- Add poison tile at trail position
                    if not poisonTiles[pos.r] then
                        poisonTiles[pos.r] = {}
                    end
                    poisonTiles[pos.r][pos.c] = {
                        timer = GameConfig.POISON_TILE_DURATION,
                        r = pos.r,
                        c = pos.c
                    }
                end
                
                -- Check collision with player
                if PoisonEnemy.checkPlayerCollision(poisonEnemy, playerData) then
                    local result = PoisonEnemy.handlePlayerCollision(poisonEnemy, playerData)
                    if result == "killed" then
                        poisonEnemy.r = -1  -- Mark for removal
                        GameState.killEnemy()
                    elseif result == "poisoned" then
                        GameState.setPlayerPoisoned(true, GameConfig.POISON_DURATION)
                        GameState.setHitFlash(GameConfig.ENEMY_HIT_FLASH_DURATION)
                    end
                end
            end
        end
    end
    
    -- Update poison tiles
    for r = 1, GameConfig.MAZE_ROWS do
        if poisonTiles[r] then
            for c = 1, GameConfig.MAZE_COLS do
                if poisonTiles[r][c] then
                    poisonTiles[r][c].timer = poisonTiles[r][c].timer - dt
                    if poisonTiles[r][c].timer <= 0 then
                        poisonTiles[r][c] = nil
                    end
                end
            end
        end
    end
    
    -- Check if player is standing on poison tile
    if poisonTiles[playerData.r] and poisonTiles[playerData.r][playerData.c] then
        if not GameState.isPlayerPoisoned() then
            GameState.setPlayerPoisoned(true, GameConfig.POISON_DURATION)
        end
    end
    
    -- Update the game objects with the modified arrays
    gameObjects.poisonEnemies = poisonEnemies
    gameObjects.poisonTiles = poisonTiles
end

-- Update splash enemies and manage splash tiles
function GameLogic.updateSplashEnemies(dt)
    local gameObjects = GameState.getGameObjects()
    local playerData = GameState.getPlayerData()
    
    -- Ensure splash arrays are initialized
    if not gameObjects.splashEnemies then
        gameObjects.splashEnemies = {}
    end
    if not gameObjects.splashTiles then
        gameObjects.splashTiles = {}
    end
    
    local splashEnemies = gameObjects.splashEnemies
    local splashTiles = gameObjects.splashTiles
    
    -- Update splash enemies
    for i = #splashEnemies, 1, -1 do
        local splashEnemy = splashEnemies[i]
        
        -- Remove dead enemies
        if splashEnemy.r == -1 then
            table.remove(splashEnemies, i)
        else
            -- Check if enemy just started splashing
            local wasSplashing = splashEnemy.isSplashing
            
            -- Update enemy movement
            SplashEnemy.update(splashEnemy, gameObjects.maze, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS, dt)
            
            -- Check if enemy just started splashing (transitioned from not splashing to splashing)
            if not wasSplashing and splashEnemy.isSplashing then
                -- Enemy just started splashing, create splash tiles
                -- Enemy just started splashing, create splash tiles
                local splashArea = SplashEnemy.getSplashArea(splashEnemy)
                for _, pos in ipairs(splashArea) do
                    -- Add splash tile at position (only if not a wall)
                    if Helpers.isValidPosition(pos.r, pos.c, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS) and
                       not gameObjects.maze[pos.r][pos.c] then
                        if not splashTiles[pos.r] then
                            splashTiles[pos.r] = {}
                        end
                        splashTiles[pos.r][pos.c] = {
                            timer = 2.0,  -- 2 seconds duration
                            r = pos.r,
                            c = pos.c
                        }
                    end
                end
            end
            
            -- Check collision with player
            if SplashEnemy.checkPlayerCollision(splashEnemy, playerData) then
                local result = SplashEnemy.handlePlayerCollision(splashEnemy, playerData)
                if result == "killed" then
                    splashEnemy.r = -1  -- Mark for removal
                    GameState.killEnemy()
                elseif result == "damaged" then
                    GameState.takeDamage(GameConfig.ENEMY_DAMAGE.SPLASH)
                    GameState.setHitFlash(GameConfig.ENEMY_HIT_FLASH_DURATION)
                end
            end
        end
    end
    
    -- Update splash tiles
    for r = 1, GameConfig.MAZE_ROWS do
        if splashTiles[r] then
            for c = 1, GameConfig.MAZE_COLS do
                if splashTiles[r][c] then
                    splashTiles[r][c].timer = splashTiles[r][c].timer - dt
                    if splashTiles[r][c].timer <= 0 then
                        splashTiles[r][c] = nil
                    end
                end
            end
        end
    end
    
    -- Check player collision with splash tiles (only once per tile)
    if splashTiles[playerData.r] and splashTiles[playerData.r][playerData.c] then
        -- Player is on a splash tile, damage them and remove the tile
        GameState.takeDamage(GameConfig.TILE_DAMAGE.SPLASH_TILE)
        GameState.setHitFlash(GameConfig.ENEMY_HIT_FLASH_DURATION)
        splashTiles[playerData.r][playerData.c] = nil  -- Remove tile after damage
    end
    
    -- Update the game objects with the modified arrays
    gameObjects.splashEnemies = splashEnemies
    gameObjects.splashTiles = splashTiles
end

-- Update blob enemies
function GameLogic.updateBlobEnemies(dt)
    local gameObjects = GameState.getGameObjects()
    local playerData = GameState.getPlayerData()
    
    -- Ensure blob enemies array is initialized
    if not gameObjects.blobEnemies then
        gameObjects.blobEnemies = {}
    end
    
    local blobEnemies = gameObjects.blobEnemies
    
    -- Update blob enemies
    for i = #blobEnemies, 1, -1 do
        local blobEnemy = blobEnemies[i]
        
        -- Remove dead enemies
        if blobEnemy.r == -1 then
            table.remove(blobEnemies, i)
        else
            -- Update enemy movement
            BlobEnemy.update(blobEnemy, gameObjects.maze, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS, dt)
            
            -- Check collision with player
            if BlobEnemy.checkPlayerCollision(blobEnemy, playerData) then
                local result = BlobEnemy.handlePlayerCollision(blobEnemy, playerData)
                if result == "killed" then
                    blobEnemy.r = -1  -- Mark for removal
                    GameState.killEnemy()
                elseif result == "damaged" then
                    GameState.takeDamage(GameConfig.ENEMY_DAMAGE.BLOB)
                    GameState.setHitFlash(GameConfig.ENEMY_HIT_FLASH_DURATION)
                end
            end
        end
    end
    
    -- Update the game objects with the modified arrays
    gameObjects.blobEnemies = blobEnemies
end

-- Update lightning enemies
function GameLogic.updateLightningEnemies(dt)
    local gameObjects = GameState.getGameObjects()
    local playerData = GameState.getPlayerData()
    
    -- Ensure lightning enemies array is initialized
    if not gameObjects.lightningEnemies then
        gameObjects.lightningEnemies = {}
    end
    
    local lightningEnemies = gameObjects.lightningEnemies
    
    -- Update lightning enemies
    for i = #lightningEnemies, 1, -1 do
        local lightningEnemy = lightningEnemies[i]
        
        -- Remove dead enemies
        if lightningEnemy.r == -1 then
            table.remove(lightningEnemies, i)
        else
            -- Update enemy movement
            LightningEnemy.update(lightningEnemy, gameObjects.maze, GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS, dt)
            
            -- Check collision with player
            if LightningEnemy.checkPlayerCollision(lightningEnemy, playerData) then
                local result = LightningEnemy.handlePlayerCollision(lightningEnemy, playerData)
                if result == "killed" then
                    lightningEnemy.r = -1  -- Mark for removal
                    GameState.killEnemy()
                elseif result == "damaged" then
                    GameState.takeDamage(GameConfig.ENEMY_DAMAGE.LIGHTNING)
                    GameState.setHitFlash(GameConfig.ENEMY_HIT_FLASH_DURATION)
                end
            end
        end
    end
    
    -- Update the game objects with the modified arrays
    gameObjects.lightningEnemies = lightningEnemies
end

-- Update poison damage over time
function GameLogic.updatePoisonDamage(dt)
    local playerData = GameState.getPlayerData()
    
    if GameState.isPlayerPoisoned() then
        GameState.updatePoisonTimer(dt)
        
        -- Apply poison damage every second
        local poisonTimer = GameState.getPoisonTimer()
        if poisonTimer > 0 and poisonTimer % 1.0 < dt then
            GameState.takeDamage(GameConfig.POISON_DAMAGE)
        end
    end
end

-- Smooth easing function for animation
function GameLogic._easeInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        return 1 - math.pow(-2 * t + 2, 3) / 2
    end
end

return GameLogic
