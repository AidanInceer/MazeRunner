local GameState = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

local state = {
    gameState = GameConfig.STATES.MENU,
    gameWon = false,
    gameOver = false,
    playerR = 1,
    playerC = 1,
    playerHealth = GameConfig.MAX_HEALTH,
    maxHealth = GameConfig.MAX_HEALTH,
    score = 0,
    maxScore = GameConfig.MAX_SCORE,
    currentLevel = 1,
    playerImmune = false,
    immunityKills = 0,
    totalEnemiesKilled = 0,
    playerPoisoned = false,
    poisonTimer = 0,
    maze = {},
    collectibles = {},
    damageTiles = {},
    healthBlobs = {},
    immunityBlobs = {},
    speedBoostOrbs = {},
    moveableCrates = {},
    greyOrbs = {},
    inventory = {
        slot1 = nil, slot2 = nil, slot3 = nil, slot4 = nil,
        slot5 = nil, slot6 = nil, slot7 = nil, slot8 = nil,
        slot9 = nil, slot10 = nil, slot11 = nil, slot12 = nil,
        slot13 = nil, slot14 = nil, slot15 = nil, slot16 = nil,
        slot17 = nil, slot18 = nil, slot19 = nil, slot20 = nil,
        slot21 = nil, slot22 = nil, slot23 = nil, slot24 = nil,
        slot25 = nil, slot26 = nil, slot27 = nil, slot28 = nil,
        slot29 = nil, slot30 = nil, slot31 = nil, slot32 = nil
    },
    enemies = {},
    poisonEnemies = {},
    poisonTiles = {},
    splashEnemies = {},
    splashTiles = {},
    blobEnemies = {},
    lightningEnemies = {},
    visited = {},
    hitFlashTimer = 0,
    collectParticles = {},
    collectParticleTimer = 0,
    enemyMoveTimer = 0,
    spikeAnimationTime = 0,
    -- Continuous movement system
    playerMoveTimer = 0,
    playerMoveInterval = 0.2,  -- 200ms between moves (5 moves per second)
    heldKeys = {},  -- Track which keys are currently held down
    -- Level progression system
    previousLevelExitR = nil,  -- Previous level's exit row
    previousLevelExitC = nil,  -- Previous level's exit column
    -- Speed boost system
    speedBoostActive = false,  -- Whether speed boost is currently active
    speedBoostTimer = 0,       -- Time remaining for speed boost
    speedBoostMultiplier = 1.0, -- Current speed multiplier
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

function GameState.getGameState()
    return state.gameState
end

function GameState.setGameState(newState)
    state.gameState = newState
end

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

function GameState.setPlayerHealth(health)
    state.playerHealth = Helpers.clamp(health, 0, state.maxHealth)
    if state.playerHealth <= 0 then
        state.gameOver = true
        state.gameState = GameConfig.STATES.GAME_OVER
    end
end

function GameState.addPlayerHealth(amount)
    GameState.setPlayerHealth(state.playerHealth + amount)
end

function GameState.setPlayerScore(score)
    state.score = Helpers.clamp(score, 0, state.maxScore)
    if state.score >= state.maxScore then
        -- Could add score-based achievements here
    end
end

function GameState.addPlayerScore(amount)
    GameState.setPlayerScore(state.score + amount)
end

-- Inventory management functions
function GameState.addToInventory(item)
    -- Find the first empty slot
    for i = 1, 32 do
        local slotKey = "slot" .. i
        if state.inventory[slotKey] == nil then
            state.inventory[slotKey] = item
            return true
        end
    end
    return false -- Inventory full
end

function GameState.getInventory()
    return state.inventory
end

function GameState.clearInventory()
    for i = 1, 32 do
        local slotKey = "slot" .. i
        state.inventory[slotKey] = nil
    end
end

function GameState.setImmunity(immune, kills)
    state.playerImmune = immune
    state.immunityKills = kills or 0
end


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


function GameState.getGameObjects()
    return {
        maze = state.maze,
        collectibles = state.collectibles,
        damageTiles = state.damageTiles,
        healthBlobs = state.healthBlobs,
        immunityBlobs = state.immunityBlobs,
        speedBoostOrbs = state.speedBoostOrbs,
        moveableCrates = state.moveableCrates,
        greyOrbs = state.greyOrbs,
        enemies = state.enemies,
        poisonEnemies = state.poisonEnemies,
        poisonTiles = state.poisonTiles,
        splashEnemies = state.splashEnemies,
        splashTiles = state.splashTiles,
        blobEnemies = state.blobEnemies,
        lightningEnemies = state.lightningEnemies,
        visited = state.visited
    }
end


function GameState.setGameObjects(objects)
    state.maze = objects.maze or state.maze
    state.collectibles = objects.collectibles or state.collectibles
    state.damageTiles = objects.damageTiles or state.damageTiles
    state.healthBlobs = objects.healthBlobs or state.healthBlobs
    state.immunityBlobs = objects.immunityBlobs or state.immunityBlobs
    state.speedBoostOrbs = objects.speedBoostOrbs or state.speedBoostOrbs
    state.moveableCrates = objects.moveableCrates or state.moveableCrates
    state.greyOrbs = objects.greyOrbs or state.greyOrbs
    state.enemies = objects.enemies or state.enemies
    state.poisonEnemies = objects.poisonEnemies
    state.poisonTiles = objects.poisonTiles
    state.splashEnemies = objects.splashEnemies
    state.splashTiles = objects.splashTiles
    state.blobEnemies = objects.blobEnemies
    state.lightningEnemies = objects.lightningEnemies
    state.visited = objects.visited or state.visited
end

function GameState.getAnimationData()
    return {
        hitFlashTimer = state.hitFlashTimer,
        collectParticles = state.collectParticles,
        collectParticleTimer = state.collectParticleTimer,
        enemyMoveTimer = state.enemyMoveTimer
    }
end

function GameState.updateAnimationTimers(hitFlash, particleTimer, enemyTimer)
    state.hitFlashTimer = hitFlash or state.hitFlashTimer
    state.collectParticleTimer = particleTimer or state.collectParticleTimer
    state.enemyMoveTimer = enemyTimer or state.enemyMoveTimer
end

function GameState.addParticles(particles)
    for _, particle in ipairs(particles) do
        table.insert(state.collectParticles, particle)
    end
end

function GameState.getUIElements()
    return {
        restartButton = state.restartButton,
        startButton = state.startButton
    }
end

function GameState.setUIHover(element, hovered)
    if state[element] then
        state[element].hovered = hovered
    end
end

function GameState.markVisited(r, c)
    if state.visited[r] and state.visited[r][c] ~= nil then
        state.visited[r][c] = true
    end
end

function GameState.isVisited(r, c)
    return state.visited[r] and state.visited[r][c] or false
end

function GameState.removeEnemy(enemy)
    for i = #state.enemies, 1, -1 do
        if state.enemies[i] == enemy then
            table.remove(state.enemies, i)
            return true
        end
    end
    return false
end

function GameState.getAllState()
    return state
end

function GameState.getSpikeAnimationTime()
    return state.spikeAnimationTime
end

function GameState.updateSpikeAnimation(dt)
    state.spikeAnimationTime = state.spikeAnimationTime + dt
end

function GameState.isPlayerPoisoned()
    return state.playerPoisoned
end

function GameState.setPlayerPoisoned(poisoned, duration)
    state.playerPoisoned = poisoned
    state.poisonTimer = duration or 0
end

function GameState.getPoisonTimer()
    return state.poisonTimer
end

function GameState.updatePoisonTimer(dt)
    if state.playerPoisoned then
        state.poisonTimer = state.poisonTimer - dt
        if state.poisonTimer <= 0 then
            state.playerPoisoned = false
            state.poisonTimer = 0
        end
    end
end

function GameState.getPoisonTiles()
    return state.poisonTiles
end

function GameState.setPoisonTiles(poisonTiles)
    state.poisonTiles = poisonTiles
end

function GameState.getPoisonEnemies()
    return state.poisonEnemies
end

function GameState.setPoisonEnemies(poisonEnemies)
    state.poisonEnemies = poisonEnemies
end

-- Continuous movement system functions
function GameState.setHeldKey(key, isHeld)
    state.heldKeys[key] = isHeld
end

function GameState.getHeldKeys()
    return state.heldKeys
end

function GameState.getPlayerMoveTimer()
    return state.playerMoveTimer
end

function GameState.setPlayerMoveTimer(timer)
    state.playerMoveTimer = timer
end

function GameState.getPlayerMoveInterval()
    return state.playerMoveInterval
end

-- Level progression system functions
function GameState.setPreviousLevelExit(r, c)
    state.previousLevelExitR = r
    state.previousLevelExitC = c
end

function GameState.getPreviousLevelExit()
    return state.previousLevelExitR, state.previousLevelExitC
end

function GameState.clearPreviousLevelExit()
    state.previousLevelExitR = nil
    state.previousLevelExitC = nil
end

-- Speed boost system functions
function GameState.activateSpeedBoost(multiplier, duration)
    state.speedBoostActive = true
    state.speedBoostMultiplier = multiplier
    state.speedBoostTimer = duration
    print("DEBUG: Speed boost activated - " .. multiplier .. "x speed for " .. duration .. " seconds")
end

function GameState.updateSpeedBoost(dt)
    if state.speedBoostActive then
        state.speedBoostTimer = state.speedBoostTimer - dt
        if state.speedBoostTimer <= 0 then
            state.speedBoostActive = false
            state.speedBoostMultiplier = 1.0
            state.speedBoostTimer = 0
            print("DEBUG: Speed boost expired")
        end
    end
end

function GameState.getSpeedBoostData()
    return {
        active = state.speedBoostActive,
        timer = state.speedBoostTimer,
        multiplier = state.speedBoostMultiplier
    }
end

function GameState.clearSpeedBoost()
    state.speedBoostActive = false
    state.speedBoostMultiplier = 1.0
    state.speedBoostTimer = 0
end

return GameState
