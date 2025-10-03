--[[
    Main Game File - Maze Game
    
    A procedural maze game with collectibles, enemies, and power-ups.
    Features:
    - Procedural maze generation with rooms and corridors
    - Collectible yellow blobs for scoring
    - Dangerous grey tiles that deal damage
    - Healing green blobs that restore health
    - Immunity red blobs that allow enemy killing
    - Moving purple enemies that deal damage
    - Visual effects and particle systems
    
    Controls:
    - WASD: Move player
    - R: Restart game
    - Space/Enter: Start game from menu
    - Mouse: Click buttons and interact with UI
]]

-- Import modules
local GameConfig = require("src.config.game_config")
local GameState = require("src.core.game_state")
local Rendering = require("src.systems.rendering")
local LevelManager = require("src.core.level_manager")
local WorldManager = require("src.world.world_manager")
local GameLogic = require("src.core.game_logic")
local Helpers = require("src.utils.helpers")
local ShaderManager = require("src.shaders.shader_manager")

-- Game initialization
function love.load()
    -- Set random seed for procedural generation
    math.randomseed(os.time())
    
    -- Initialize level manager
    LevelManager.init()
    
    -- Set background color based on current level
    local colors = LevelManager.getCurrentColors()
    love.graphics.setBackgroundColor(colors.background)
    
    -- Initialize game state
    GameState.initialize()
    
    -- Initialize shaders
    ShaderManager.init()
    
    -- Generate initial game world
    local worldData = WorldManager.generateGameWorld()
    GameState.setPlayerPosition(worldData.spawnR, worldData.spawnC)
    GameState.setCurrentLevel(LevelManager.getCurrentLevel())
    GameState.setGameObjects(worldData)
end







-- Game update loop
function love.update(dt)
    local animationData = GameState.getAnimationData()
    
    -- Update hit flash animation
    if animationData.hitFlashTimer > 0 then
        GameState.updateAnimationTimers(animationData.hitFlashTimer - dt)
    end
    
    -- Update particle system
    GameLogic.updateParticles(dt)
    
    -- Update enemy movement
    GameLogic.updateEnemies(dt)
    
    -- Update poison enemies and poison damage
    GameLogic.updatePoisonEnemies(dt)
    GameLogic.updatePoisonDamage(dt)
    
    -- Update spike animation
    GameState.updateSpikeAnimation(dt)
end


-- Game rendering
function love.draw()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gameState = GameState.getGameState()
    
    if gameState == GameConfig.STATES.MENU then
        local uiElements = GameState.getUIElements()
        Rendering.drawMainMenu(screenWidth, screenHeight, uiElements.startButton, LevelManager.getCurrentColors())
    else
        -- Draw game
        local gameObjects = GameState.getGameObjects()
        local playerData = GameState.getPlayerData()
        local animationData = GameState.getAnimationData()
        
        Rendering.drawGame(screenWidth, screenHeight, gameObjects.maze, gameObjects, playerData, animationData, LevelManager.getCurrentColors())
        
        -- Draw UI
        local uiElements = GameState.getUIElements()
        Rendering.drawUI(playerData, screenHeight, uiElements.restartButton, LevelManager.getCurrentColors())
        
        -- Draw game messages
        local gameState = GameState.getGameState()
        if gameState == GameConfig.STATES.INSUFFICIENT_SCORE then
            Rendering.drawInsufficientScoreMessage(screenWidth, screenHeight, GameConfig.REQUIRED_COLLECTIBLES)
        else
            Rendering.drawGameMessages(screenWidth, screenHeight, 
                GameState.getAllState().gameWon, GameState.getAllState().gameOver)
        end
    end
end

-- Input handling
function love.mousepressed(x, y, button)
    if button == 1 then  -- Left mouse button
        local gameState = GameState.getGameState()
        local uiElements = GameState.getUIElements()
        
        -- Handle start button click
        if gameState == GameConfig.STATES.MENU and 
           Helpers.isMouseHovering(x, y, uiElements.startButton.x, uiElements.startButton.y, 
                                  uiElements.startButton.width, uiElements.startButton.height) then
            GameState.setGameState(GameConfig.STATES.PLAYING)
            local worldData = WorldManager.generateGameWorld()
            GameState.setPlayerPosition(worldData.spawnR, worldData.spawnC)
            GameState.setCurrentLevel(LevelManager.getCurrentLevel())
            GameState.setGameObjects(worldData)
            -- Reset score for new game
            GameState.setPlayerScore(0)
            return
        end
        
        -- Handle restart button click
        if Helpers.isMouseHovering(x, y, uiElements.restartButton.x, uiElements.restartButton.y,
                                  uiElements.restartButton.width, uiElements.restartButton.height) then
            LevelManager.restartGame()
            love.load()
            return
        end
    end
end

function love.keypressed(key)
    -- Handle restart
    if key == "r" then
        LevelManager.restartGame()
        love.load()
        return
    end
    
    -- No shader controls (only enemy shaders remain)
    
    local gameState = GameState.getGameState()
    
    -- Handle start game from menu
    if gameState == GameConfig.STATES.MENU and (key == "space" or key == "return" or key == "enter") then
        GameState.setGameState(GameConfig.STATES.PLAYING)
        local worldData = WorldManager.generateGameWorld()
        GameState.setPlayerPosition(worldData.spawnR, worldData.spawnC)
        GameState.setCurrentLevel(LevelManager.getCurrentLevel())
        GameState.setGameObjects(worldData)
        -- Reset score for new game
        GameState.setPlayerScore(0)
        return
    end
    
    -- Handle player movement
    if gameState == GameConfig.STATES.PLAYING then
        GameLogic.handlePlayerMovement(key)
    elseif gameState == GameConfig.STATES.INSUFFICIENT_SCORE then
        -- Return to playing state if any key is pressed
        GameState.setGameState(GameConfig.STATES.PLAYING)
    end
end


