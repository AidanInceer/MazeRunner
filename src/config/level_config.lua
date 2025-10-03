-- Level themes and progression settings
local LevelConfig = {}

-- Level themes
LevelConfig.THEMES = {
    FOREST = 1,
    CAVE = 2,
    VOID = 3,
    ABYSS = 4
}

-- Level names
LevelConfig.LEVEL_NAMES = {
    [LevelConfig.THEMES.FOREST] = "The Withered Forest",
    [LevelConfig.THEMES.CAVE] = "The Crystal Caves",
    [LevelConfig.THEMES.VOID] = "The Empty Void",
    [LevelConfig.THEMES.ABYSS] = "The Infernal Abyss"
}

-- Level descriptions
LevelConfig.LEVEL_DESCRIPTIONS = {
    [LevelConfig.THEMES.FOREST] = "Navigate through the twisted trees and avoid the corrupted wildlife.",
    [LevelConfig.THEMES.CAVE] = "Explore the crystalline depths and watch for falling rocks.",
    [LevelConfig.THEMES.VOID] = "Survive in the endless darkness where reality bends.",
    [LevelConfig.THEMES.ABYSS] = "Descend into the fiery depths of hell itself."
}

-- Import colors from separate config
local Colors = require("src.config.colors")
LevelConfig.COLORS = Colors.THEMES

-- Level progression settings
LevelConfig.LEVEL_SETTINGS = {
    [LevelConfig.THEMES.FOREST] = {
        baseEnemyCount = 15,
        enemySpeed = 0.6,
        collectibleCount = 8,
        damageTileCount = 15,
        healthBlobCount = 2,
        immunityBlobCount = 3,
        requiredScore = 10
    },
    [LevelConfig.THEMES.CAVE] = {
        baseEnemyCount = 25,
        enemySpeed = 0.7,
        collectibleCount = 10,
        damageTileCount = 20,
        healthBlobCount = 3,
        immunityBlobCount = 4,
        requiredScore = 10
    },
    [LevelConfig.THEMES.VOID] = {
        baseEnemyCount = 35,
        enemySpeed = 0.8,
        collectibleCount = 12,
        damageTileCount = 25,
        healthBlobCount = 3,
        immunityBlobCount = 5,
        requiredScore = 10
    },
    [LevelConfig.THEMES.ABYSS] = {
        baseEnemyCount = 40,
        enemySpeed = 1.0,
        collectibleCount = 15,
        damageTileCount = 30,
        healthBlobCount = 4,
        immunityBlobCount = 6,
        requiredScore = 10
    }
}

function LevelConfig.getColors(theme)
    local themeNames = {
        [LevelConfig.THEMES.FOREST] = "FOREST",
        [LevelConfig.THEMES.CAVE] = "CAVE", 
        [LevelConfig.THEMES.VOID] = "VOID",
        [LevelConfig.THEMES.ABYSS] = "ABYSS"
    }
    local themeName = themeNames[theme] or "FOREST"
    return LevelConfig.COLORS[themeName] or LevelConfig.COLORS.FOREST
end

function LevelConfig.getSettings(theme)
    return LevelConfig.LEVEL_SETTINGS[theme] or LevelConfig.LEVEL_SETTINGS[LevelConfig.THEMES.FOREST]
end

function LevelConfig.getEnemyCount(theme, levelProgress)
    local settings = LevelConfig.getSettings(theme)
    return settings.baseEnemyCount + (levelProgress - 1) * 2
end

function LevelConfig.getRequiredScore(theme)
    local settings = LevelConfig.getSettings(theme)
    return settings.requiredScore
end

function LevelConfig.getEnemySpeed(theme)
    local settings = LevelConfig.getSettings(theme)
    return settings.enemySpeed
end

function LevelConfig.getName(theme)
    return LevelConfig.LEVEL_NAMES[theme] or "Unknown Level"
end

function LevelConfig.getDescription(theme)
    return LevelConfig.LEVEL_DESCRIPTIONS[theme] or "A mysterious place."
end

function LevelConfig.getNextTheme(currentTheme)
    if currentTheme < LevelConfig.THEMES.ABYSS then
        return currentTheme + 1
    end
    return nil
end

function LevelConfig.isValidTheme(theme)
    return theme >= LevelConfig.THEMES.FOREST and theme <= LevelConfig.THEMES.ABYSS
end

return LevelConfig
