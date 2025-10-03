-- Game logic and mechanics handling
local GameLogic = {}
local GameConfig = require("src.config.game_config")
local LevelConfig = require("src.config.level_config")
local LevelManager = require("src.core.level_manager")
local GameState = require("src.core.game_state")
local WorldManager = require("src.world.world_manager")
local Helpers = require("src.utils.helpers")

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
        GameState.takeDamage(GameConfig.DAMAGE_TILE_DAMAGE)
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

function GameLogic.updateEnemies(dt)
    local gameObjects = GameState.getGameObjects()
    local playerData = GameState.getPlayerData()
    local enemyMoveTimer = GameState.getEnemyMoveTimer()
    local currentLevel = LevelManager.getCurrentLevel()
    local enemyMoveInterval = LevelConfig.getEnemySpeed(currentLevel)
    
    enemyMoveTimer = enemyMoveTimer + dt
    
    if enemyMoveTimer >= enemyMoveInterval then
        enemyMoveTimer = 0
        
        -- Move all enemies
        for r = 1, GameConfig.MAZE_ROWS do
            for c = 1, GameConfig.MAZE_COLS do
                if gameObjects.enemies[r][c] then
                    local enemy = gameObjects.enemies[r][c]
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
                        -- Remove from old position
                        gameObjects.enemies[enemy.r][enemy.c] = false
                        
                        -- Update enemy position
                        enemy.r = newR
                        enemy.c = newC
                        
                        -- Add to new position
                        gameObjects.enemies[newR][newC] = enemy
                        
                        -- Check collision with player
                        if newR == playerData.r and newC == playerData.c then
                            if playerData.immune and playerData.immunityKills > 0 then
                                -- Kill enemy
                                gameObjects.enemies[newR][newC] = false
                                GameState.killEnemy()
                            else
                                -- Damage player
                                GameState.takeDamage(GameConfig.ENEMY_DAMAGE)
                                GameState.setHitFlash(GameConfig.ENEMY_HIT_FLASH_DURATION)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Always update the timer
    GameState.setEnemyMoveTimer(enemyMoveTimer)
end

return GameLogic
