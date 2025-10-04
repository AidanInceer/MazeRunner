-- Import modules
local GameConfig = require("src.config.game_config")
local GameState = require("src.core.game_state")
local Rendering = require("src.systems.rendering")
local LevelManager = require("src.core.level_manager")
local WorldManager = require("src.world.world_manager")
local GameLogic = require("src.core.game_logic")
local Helpers = require("src.utils.helpers")
local ShaderManager = require("src.shaders.shader_manager")

function love.load()
    math.randomseed(os.time())
    LevelManager.init()
    local colors = LevelManager.getCurrentColors()
    love.graphics.setBackgroundColor(colors.background)
    GameState.initialize()
    ShaderManager.init()
    local worldData = WorldManager.generateGameWorld()
    GameState.setPlayerPosition(worldData.spawnR, worldData.spawnC)
    GameState.setCurrentLevel(LevelManager.getCurrentLevel())
    GameState.setGameObjects(worldData)
end







function love.update(dt)
    local gameState = GameState.getGameState()
    
    -- Skip game logic updates when paused
    if gameState == GameConfig.STATES.PAUSED then
        return
    end
    
    local animationData = GameState.getAnimationData()
    
    if animationData.hitFlashTimer > 0 then
        GameState.updateAnimationTimers(animationData.hitFlashTimer - dt)
    end
    
    GameLogic.updateParticles(dt)
    GameLogic.updateEnemies(dt)
    GameLogic.updatePoisonEnemies(dt)
    GameLogic.updateSplashEnemies(dt)
    GameLogic.updatePoisonDamage(dt)
    GameLogic.updatePlayerMovement(dt)  -- Handle continuous movement
    GameState.updateSpeedBoost(dt)  -- Update speed boost timer
    GameState.updateSpikeAnimation(dt)
end


function love.draw()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gameState = GameState.getGameState()
    
    if gameState == GameConfig.STATES.MENU then
        local uiElements = GameState.getUIElements()
        Rendering.drawMainMenu(screenWidth, screenHeight, uiElements.startButton, LevelManager.getCurrentColors())
    elseif gameState == GameConfig.STATES.PAUSED then
        -- Draw the game in the background (dimmed)
        local gameObjects = GameState.getGameObjects()
        local playerData = GameState.getPlayerData()
        local animationData = GameState.getAnimationData()
        
        -- Draw game with dimmed overlay
        love.graphics.setColor(0.3, 0.3, 0.3, 1)  -- Dim the game
        Rendering.drawGame(screenWidth, screenHeight, gameObjects.maze, gameObjects, playerData, animationData, LevelManager.getCurrentColors())
        love.graphics.setColor(1, 1, 1, 1)  -- Reset color
        
        -- Draw pause menu overlay
        Rendering.drawPauseMenu(screenWidth, screenHeight, LevelManager.getCurrentColors())
    else
        local gameObjects = GameState.getGameObjects()
        local playerData = GameState.getPlayerData()
        local animationData = GameState.getAnimationData()
        
        Rendering.drawGame(screenWidth, screenHeight, gameObjects.maze, gameObjects, playerData, animationData, LevelManager.getCurrentColors())
        
        local uiElements = GameState.getUIElements()
        Rendering.drawUI(playerData, screenHeight, uiElements.restartButton, LevelManager.getCurrentColors())
        
        -- Draw level display in top right
        Rendering.drawLevelDisplay(screenWidth, screenHeight, LevelManager.getCurrentLevel(), LevelManager.getCurrentName(), LevelManager.getCurrentColors())
        
        local gameState = GameState.getGameState()
        if gameState == GameConfig.STATES.INSUFFICIENT_SCORE then
            Rendering.drawInsufficientScoreMessage(screenWidth, screenHeight, GameConfig.REQUIRED_COLLECTIBLES)
        else
            Rendering.drawGameMessages(screenWidth, screenHeight, 
                GameState.getAllState().gameWon, GameState.getAllState().gameOver)
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local gameState = GameState.getGameState()
        local uiElements = GameState.getUIElements()
        
        if gameState == GameConfig.STATES.MENU and 
           Helpers.isMouseHovering(x, y, uiElements.startButton.x, uiElements.startButton.y, 
                                  uiElements.startButton.width, uiElements.startButton.height) then
            GameState.setGameState(GameConfig.STATES.PLAYING)
            local worldData = WorldManager.generateGameWorld()
            GameState.setPlayerPosition(worldData.spawnR, worldData.spawnC)
            GameState.setCurrentLevel(LevelManager.getCurrentLevel())
            GameState.setGameObjects(worldData)
            GameState.setPlayerScore(0)
            return
        end
        
        if Helpers.isMouseHovering(x, y, uiElements.restartButton.x, uiElements.restartButton.y,
                                  uiElements.restartButton.width, uiElements.restartButton.height) then
            LevelManager.restartGame()
            love.load()
            return
        end
    end
end

function love.keypressed(key)
    if key == "r" then
        LevelManager.restartGame()
        GameState.clearPreviousLevelExit()  -- Clear previous level exit on restart
        love.load()
        return
    end
    
    local gameState = GameState.getGameState()
    
    if gameState == GameConfig.STATES.MENU and (key == "space" or key == "return" or key == "enter") then
        GameState.setGameState(GameConfig.STATES.PLAYING)
        -- Clear any previous level exit position for the first level
        GameState.clearPreviousLevelExit()
        print("DEBUG: Starting first level - no preferred spawn position")
        local worldData = WorldManager.generateGameWorld()  -- No preferred spawn for first level
        print("DEBUG: First level spawn placed at " .. worldData.spawnR .. ", " .. worldData.spawnC)
        GameState.setPlayerPosition(worldData.spawnR, worldData.spawnC)
        GameState.setCurrentLevel(LevelManager.getCurrentLevel())
        GameState.setGameObjects(worldData)
        GameState.setPlayerScore(0)
        return
    end
    
    if gameState == GameConfig.STATES.PLAYING then
        -- Handle pause key
        if key == "p" then
            GameState.setGameState(GameConfig.STATES.PAUSED)
            return
        end
        
        -- Handle movement keys for continuous movement
        if key == "w" or key == "a" or key == "s" or key == "d" or 
           key == "up" or key == "left" or key == "down" or key == "right" then
            -- Mark key as held and trigger immediate movement
            GameState.setHeldKey(key, true)
            GameLogic.handlePlayerMovement(key)
            GameState.setPlayerMoveTimer(0)  -- Reset timer for immediate response
        end
    elseif gameState == GameConfig.STATES.PAUSED then
        -- Handle unpause key
        if key == "p" or key == "escape" then
            GameState.setGameState(GameConfig.STATES.PLAYING)
            return
        end
    elseif gameState == GameConfig.STATES.INSUFFICIENT_SCORE then
        GameState.setGameState(GameConfig.STATES.PLAYING)
    end
end

function love.keyreleased(key)
    local gameState = GameState.getGameState()
    
    if gameState == GameConfig.STATES.PLAYING then
        -- Handle movement keys for continuous movement
        if key == "w" or key == "a" or key == "s" or key == "d" or 
           key == "up" or key == "left" or key == "down" or key == "right" then
            -- Mark key as released
            GameState.setHeldKey(key, false)
        end
    end
end


