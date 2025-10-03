--[[
    Game State Module
    
    Manages the overall game state, including player data, game objects,
    and state transitions. Centralizes game state management.
]]

local GameState = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

-- Game state variables
local state = {
    -- Core game state
    gameState = GameConfig.STATES.MENU,
    gameWon = false,
    gameOver = false,
    
    -- Player data
    playerR = 1,
    playerC = 1,
    playerHealth = GameConfig.MAX_HEALTH,
    maxHealth = GameConfig.MAX_HEALTH,
    score = 0,
    maxScore = GameConfig.MAX_SCORE,
    currentLevel = 1,
    
    -- Immunity system
    playerImmune = false,
    immunityKills = 0,
    totalEnemiesKilled = 0,
    
    -- Poison system
    playerPoisoned = false,
    poisonTimer = 0,
    
    -- Game objects
    maze = {},
    collectibles = {},
    damageTiles = {},
    healthBlobs = {},
    immunityBlobs = {},
    enemies = {},
    poisonEnemies = {},
    poisonTiles = {},
    visited = {},
    
    -- Animation and effects
    hitFlashTimer = 0,
    collectParticles = {},
    collectParticleTimer = 0,
    enemyMoveTimer = 0,
    spikeAnimationTime = 0,
    
    -- UI elements
    restartButton = {
        x = 20,
        y = 0,
        width = 100,
        height = 30,
        hovered = false
    },
    startButton = {
        x = 0,
        y = 0,
        width = 200,
        height = 50,
        hovered = false
    }
}

--[[
    Initializes the game state with default values
]]
function GameState.initialize()
    state.gameState = GameConfig.STATES.MENU
    state.gameWon = false
    state.gameOver = false
    state.playerHealth = GameConfig.MAX_HEALTH
    state.maxHealth = GameConfig.MAX_HEALTH
    state.score = 0
    state.maxScore = GameConfig.MAX_SCORE
    state.playerImmune = false
    state.immunityKills = 0
    state.totalEnemiesKilled = 0
    state.hitFlashTimer = 0
    state.collectParticles = {}
    state.collectParticleTimer = 0
    state.enemyMoveTimer = 0
end

--[[
    Gets the current game state
    
    @return string Current game state
]]
function GameState.getGameState()
    return state.gameState
end

--[[
    Sets the game state
    
    @param newState string New game state
]]
function GameState.setGameState(newState)
    state.gameState = newState
end

--[[
    Gets player data
    
    @return table Player data
]]
function GameState.getPlayerData()
    return {
        r = state.playerR,
        c = state.playerC,
        health = state.playerHealth,
        maxHealth = state.maxHealth,
        score = state.score,
        maxScore = state.maxScore,
        immune = state.playerImmune,
        immunityKills = state.immunityKills,
        totalEnemiesKilled = state.totalEnemiesKilled
    }
end

--[[
    Updates player position
    
    @param r number Row position
    @param c number Column position
]]
function GameState.setPlayerPosition(r, c)
    state.playerR = r
    state.playerC = c
end

function GameState.setCurrentLevel(level)
    state.currentLevel = level
end

function GameState.getEnemyMoveTimer()
    return state.enemyMoveTimer
end

function GameState.setEnemyMoveTimer(timer)
    state.enemyMoveTimer = timer
end

function GameState.addScore(amount)
    state.score = state.score + amount
end

function GameState.takeDamage(amount)
    state.playerHealth = state.playerHealth - amount
    if state.playerHealth <= 0 then
        state.playerHealth = 0
        state.gameOver = true
        state.gameState = GameConfig.STATES.GAME_OVER
    end
end

function GameState.setHitFlash(duration)
    state.hitFlashTimer = duration
end

function GameState.heal(amount)
    state.playerHealth = state.playerHealth + amount
    if state.playerHealth > state.maxHealth then
        state.playerHealth = state.maxHealth
    end
end

function GameState.grantImmunity(kills)
    state.playerImmune = true
    state.immunityKills = state.immunityKills + kills
end

function GameState.addParticles(particles)
    for _, particle in ipairs(particles) do
        table.insert(state.collectParticles, particle)
    end
end

function GameState.killEnemy()
    state.immunityKills = state.immunityKills - 1
    state.totalEnemiesKilled = state.totalEnemiesKilled + 1
    if state.immunityKills <= 0 then
        state.playerImmune = false
    end
end

--[[
    Updates player health
    
    @param health number New health value
]]
function GameState.setPlayerHealth(health)
    state.playerHealth = Helpers.clamp(health, 0, state.maxHealth)
    if state.playerHealth <= 0 then
        state.gameOver = true
        state.gameState = GameConfig.STATES.GAME_OVER
    end
end

--[[
    Adds to player health
    
    @param amount number Amount to add
]]
function GameState.addPlayerHealth(amount)
    GameState.setPlayerHealth(state.playerHealth + amount)
end

--[[
    Updates player score
    
    @param score number New score value
]]
function GameState.setPlayerScore(score)
    state.score = Helpers.clamp(score, 0, state.maxScore)
    if state.score >= state.maxScore then
        -- Could add score-based achievements here
    end
end

--[[
    Adds to player score
    
    @param amount number Amount to add
]]
function GameState.addPlayerScore(amount)
    GameState.setPlayerScore(state.score + amount)
end

--[[
    Sets immunity state
    
    @param immune boolean Whether player is immune
    @param kills number Number of kills available
]]
function GameState.setImmunity(immune, kills)
    state.playerImmune = immune
    state.immunityKills = kills or 0
end

--[[
    Uses one immunity kill
    
    @return boolean True if kill was used successfully
]]
function GameState.useImmunityKill()
    if state.playerImmune and state.immunityKills > 0 then
        state.immunityKills = state.immunityKills - 1
        state.totalEnemiesKilled = state.totalEnemiesKilled + 1
        
        if state.immunityKills <= 0 then
            state.playerImmune = false
        end
        return true
    end
    return false
end

--[[
    Gets game objects
    
    @return table Game objects
]]
function GameState.getGameObjects()
    return {
        maze = state.maze,
        collectibles = state.collectibles,
        damageTiles = state.damageTiles,
        healthBlobs = state.healthBlobs,
        immunityBlobs = state.immunityBlobs,
        enemies = state.enemies,
        poisonEnemies = state.poisonEnemies,
        poisonTiles = state.poisonTiles,
        visited = state.visited
    }
end

--[[
    Sets game objects
    
    @param objects table Game objects
]]
function GameState.setGameObjects(objects)
    state.maze = objects.maze or state.maze
    state.collectibles = objects.collectibles or state.collectibles
    state.damageTiles = objects.damageTiles or state.damageTiles
    state.healthBlobs = objects.healthBlobs or state.healthBlobs
    state.immunityBlobs = objects.immunityBlobs or state.immunityBlobs
    state.enemies = objects.enemies or state.enemies
    state.poisonEnemies = objects.poisonEnemies
    state.poisonTiles = objects.poisonTiles
    state.visited = objects.visited or state.visited
    
end

--[[
    Gets animation data
    
    @return table Animation data
]]
function GameState.getAnimationData()
    return {
        hitFlashTimer = state.hitFlashTimer,
        collectParticles = state.collectParticles,
        collectParticleTimer = state.collectParticleTimer,
        enemyMoveTimer = state.enemyMoveTimer
    }
end

--[[
    Updates animation timers
    
    @param hitFlash number Hit flash timer
    @param particleTimer number Particle timer
    @param enemyTimer number Enemy move timer
]]
function GameState.updateAnimationTimers(hitFlash, particleTimer, enemyTimer)
    state.hitFlashTimer = hitFlash or state.hitFlashTimer
    state.collectParticleTimer = particleTimer or state.collectParticleTimer
    state.enemyMoveTimer = enemyTimer or state.enemyMoveTimer
end

--[[
    Adds particles to the collection
    
    @param particles table Array of particles to add
]]
function GameState.addParticles(particles)
    for _, particle in ipairs(particles) do
        table.insert(state.collectParticles, particle)
    end
end

--[[
    Gets UI elements
    
    @return table UI elements
]]
function GameState.getUIElements()
    return {
        restartButton = state.restartButton,
        startButton = state.startButton
    }
end

--[[
    Updates UI element hover state
    
    @param element string Element name
    @param hovered boolean Hover state
]]
function GameState.setUIHover(element, hovered)
    if state[element] then
        state[element].hovered = hovered
    end
end

--[[
    Marks a position as visited
    
    @param r number Row position
    @param c number Column position
]]
function GameState.markVisited(r, c)
    if state.visited[r] and state.visited[r][c] ~= nil then
        state.visited[r][c] = true
    end
end

--[[
    Checks if a position is visited
    
    @param r number Row position
    @param c number Column position
    @return boolean True if visited
]]
function GameState.isVisited(r, c)
    return state.visited[r] and state.visited[r][c] or false
end

--[[
    Removes an enemy from the game
    
    @param enemy table Enemy to remove
    @return boolean True if enemy was removed
]]
function GameState.removeEnemy(enemy)
    for i = #state.enemies, 1, -1 do
        if state.enemies[i] == enemy then
            table.remove(state.enemies, i)
            return true
        end
    end
    return false
end

--[[
    Gets all state data (for debugging)
    
    @return table Complete state data
]]
function GameState.getAllState()
    return state
end

--[[
    Gets the spike animation time
    
    @return number Spike animation time
]]
function GameState.getSpikeAnimationTime()
    return state.spikeAnimationTime
end

--[[
    Updates the spike animation time
    
    @param dt number Delta time
]]
function GameState.updateSpikeAnimation(dt)
    state.spikeAnimationTime = state.spikeAnimationTime + dt
end

--[[
    Gets the poison state
    
    @return boolean True if player is poisoned
]]
function GameState.isPlayerPoisoned()
    return state.playerPoisoned
end

--[[
    Sets the poison state
    
    @param poisoned boolean Whether player is poisoned
    @param duration number Duration of poison effect
]]
function GameState.setPlayerPoisoned(poisoned, duration)
    state.playerPoisoned = poisoned
    state.poisonTimer = duration or 0
end

--[[
    Gets the poison timer
    
    @return number Poison timer value
]]
function GameState.getPoisonTimer()
    return state.poisonTimer
end

--[[
    Updates the poison timer
    
    @param dt number Delta time
]]
function GameState.updatePoisonTimer(dt)
    if state.playerPoisoned then
        state.poisonTimer = state.poisonTimer - dt
        if state.poisonTimer <= 0 then
            state.playerPoisoned = false
            state.poisonTimer = 0
        end
    end
end

--[[
    Gets poison tiles
    
    @return table Poison tiles array
]]
function GameState.getPoisonTiles()
    return state.poisonTiles
end

--[[
    Sets poison tiles
    
    @param poisonTiles table Poison tiles array
]]
function GameState.setPoisonTiles(poisonTiles)
    state.poisonTiles = poisonTiles
end

--[[
    Gets poison enemies
    
    @return table Poison enemies array
]]
function GameState.getPoisonEnemies()
    return state.poisonEnemies
end

--[[
    Sets poison enemies
    
    @param poisonEnemies table Poison enemies array
]]
function GameState.setPoisonEnemies(poisonEnemies)
    state.poisonEnemies = poisonEnemies
end

return GameState
