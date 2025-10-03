-- Level progression and theming system
local LevelManager = {}
local LevelConfig = require("src.config.level_config")
local GameConfig = require("src.config.game_config")

-- Current level state
LevelManager.currentLevel = LevelConfig.THEMES.FOREST
LevelManager.levelProgress = 1  -- Track how many levels completed
LevelManager.levelComplete = false
LevelManager.gameComplete = false

-- Level-specific settings
LevelManager.settings = LevelConfig.getSettings(LevelManager.currentLevel)
LevelManager.colors = LevelConfig.getColors(LevelManager.currentLevel)

function LevelManager.init()
    LevelManager.currentLevel = LevelConfig.THEMES.FOREST
    LevelManager.levelProgress = 1
    LevelManager.levelComplete = false
    LevelManager.gameComplete = false
    LevelManager.settings = LevelConfig.getSettings(LevelManager.currentLevel)
    LevelManager.colors = LevelConfig.getColors(LevelManager.currentLevel)
end

function LevelManager.getCurrentLevel()
    return LevelManager.currentLevel
end

function LevelManager.getCurrentSettings()
    return LevelManager.settings
end

function LevelManager.getCurrentColors()
    return LevelManager.colors
end

function LevelManager.getCurrentName()
    return LevelConfig.getName(LevelManager.currentLevel)
end

function LevelManager.getCurrentDescription()
    return LevelConfig.getDescription(LevelManager.currentLevel)
end

function LevelManager.completeLevel()
    LevelManager.levelComplete = true
    LevelManager.levelProgress = LevelManager.levelProgress + 1
    local nextLevel = LevelConfig.getNextTheme(LevelManager.currentLevel)
    
    if nextLevel then
        LevelManager.currentLevel = nextLevel
        LevelManager.settings = LevelConfig.getSettings(LevelManager.currentLevel)
        LevelManager.colors = LevelConfig.getColors(LevelManager.currentLevel)
        LevelManager.levelComplete = false
    else
        LevelManager.gameComplete = true
    end
end

function LevelManager.isLevelComplete()
    return LevelManager.levelComplete
end

function LevelManager.isGameComplete()
    return LevelManager.gameComplete
end

function LevelManager.resetLevel()
    LevelManager.levelComplete = false
end

function LevelManager.restartGame()
    LevelManager.init()
end

function LevelManager.getLevelProgress()
    return LevelManager.levelProgress
end

function LevelManager.getEnemyCount()
    return LevelConfig.getEnemyCount(LevelManager.currentLevel, LevelManager.levelProgress)
end

function LevelManager.getRequiredScore()
    return LevelConfig.getRequiredScore(LevelManager.currentLevel)
end

return LevelManager
