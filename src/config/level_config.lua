-- Level themes and progression settings
local LevelConfig = {}

-- Level themes
LevelConfig.THEMES = {
    FOREST = 1,
    CAVE = 2,
    VOID = 3,
    ABYSS = 4,
    VOLCANO = 5,
    ARCTIC = 6,
    DESERT = 7,
    NEBULA = 8
}

-- Level names
LevelConfig.LEVEL_NAMES = {
    [LevelConfig.THEMES.FOREST] = "The Withered Forest",
    [LevelConfig.THEMES.CAVE] = "The Crystal Caves",
    [LevelConfig.THEMES.VOID] = "The Empty Void",
    [LevelConfig.THEMES.ABYSS] = "The Infernal Abyss",
    [LevelConfig.THEMES.VOLCANO] = "The Molten Caldera",
    [LevelConfig.THEMES.ARCTIC] = "The Frozen Wasteland",
    [LevelConfig.THEMES.DESERT] = "The Scorching Dunes",
    [LevelConfig.THEMES.NEBULA] = "The Cosmic Storm"
}

-- Level descriptions
LevelConfig.LEVEL_DESCRIPTIONS = {
    [LevelConfig.THEMES.FOREST] = "Navigate through the twisted trees and avoid the corrupted wildlife.",
    [LevelConfig.THEMES.CAVE] = "Explore the crystalline depths and watch for falling rocks.",
    [LevelConfig.THEMES.VOID] = "Survive in the endless darkness where reality bends.",
    [LevelConfig.THEMES.ABYSS] = "Descend into the fiery depths of hell itself.",
    [LevelConfig.THEMES.VOLCANO] = "Traverse the molten landscape where lava flows and rocks explode.",
    [LevelConfig.THEMES.ARCTIC] = "Brave the frozen tundra where ice shards and blizzards await.",
    [LevelConfig.THEMES.DESERT] = "Endure the scorching sands where mirages and sandstorms deceive.",
    [LevelConfig.THEMES.NEBULA] = "Navigate the cosmic storm where gravity and reality warp."
}

-- Import colors from separate config
local Colors = require("src.config.colors")
LevelConfig.COLORS = Colors.THEMES

-- Level progression settings with gentler difficulty scaling
LevelConfig.LEVEL_SETTINGS = {
    [LevelConfig.THEMES.FOREST] = {
        -- Enemy counts (Easy - Tutorial level)
        defaultEnemyCount = 6,
        poisonEnemyCount = 0,
        splashEnemyCount = 0,
        lightningEnemyCount = 1,
        blobEnemyCount = 1,
        -- Item countsclea
        collectibleCount = 6,
        damageTileCount = 8,
        healthBlobCount = 2,
        immunityBlobCount = 2,
        requiredScore = 5
    },
    [LevelConfig.THEMES.CAVE] = {
        -- Enemy counts (Easy+)
        defaultEnemyCount = 7,
        poisonEnemyCount = 1,
        splashEnemyCount = 1,
        lightningEnemyCount = 0,
        blobEnemyCount = 0,
        -- Item counts
        collectibleCount = 7,
        damageTileCount = 10,
        healthBlobCount = 2,
        immunityBlobCount = 3,
        requiredScore = 6
    },
    [LevelConfig.THEMES.VOID] = {
        -- Enemy counts (Medium-)
        defaultEnemyCount = 11,
        poisonEnemyCount = 1,
        splashEnemyCount = 2,
        lightningEnemyCount = 1,
        blobEnemyCount = 0,
        -- Item counts
        collectibleCount = 8,
        damageTileCount = 13,
        healthBlobCount = 2,
        immunityBlobCount = 4,
        requiredScore = 8
    },
    [LevelConfig.THEMES.ABYSS] = {
        -- Enemy counts (Medium)
        defaultEnemyCount = 13,
        poisonEnemyCount = 2,
        splashEnemyCount = 2,
        -- Item counts
        collectibleCount = 9,
        damageTileCount = 16,
        healthBlobCount = 2,
        immunityBlobCount = 4,
        requiredScore = 10
    },
    [LevelConfig.THEMES.VOLCANO] = {
        -- Enemy counts (Medium+)
        defaultEnemyCount = 16,
        poisonEnemyCount = 2,
        splashEnemyCount = 3,
        lightningEnemyCount = 1,
        blobEnemyCount = 1,
        -- Item counts
        collectibleCount = 10,
        damageTileCount = 20,
        healthBlobCount = 2,
        immunityBlobCount = 5,
        requiredScore = 12
    },
    [LevelConfig.THEMES.ARCTIC] = {
        -- Enemy counts (Hard-)
        defaultEnemyCount = 18,
        poisonEnemyCount = 3,
        splashEnemyCount = 4,
        lightningEnemyCount = 1,
        blobEnemyCount = 1,
        -- Item counts
        collectibleCount = 11,
        damageTileCount = 24,
        healthBlobCount = 2,
        immunityBlobCount = 5,
        requiredScore = 14
    },
    [LevelConfig.THEMES.DESERT] = {
        -- Enemy counts (Hard)
        defaultEnemyCount = 20,
        poisonEnemyCount = 3,
        splashEnemyCount = 5,
        lightningEnemyCount = 1,
        blobEnemyCount = 1,
        -- Item counts
        collectibleCount = 12,
        damageTileCount = 28,
        healthBlobCount = 2,
        immunityBlobCount = 6,
        requiredScore = 16
    },
    [LevelConfig.THEMES.NEBULA] = {
        -- Enemy counts (Hard+)
        defaultEnemyCount = 20,
        poisonEnemyCount = 3,
        splashEnemyCount = 6,
        lightningEnemyCount = 1,
        blobEnemyCount = 1,
        -- Item counts
        collectibleCount = 13,
        damageTileCount = 32,
        healthBlobCount = 2,
        immunityBlobCount = 7,
        requiredScore = 18
    }
}

function LevelConfig.getColors(theme)
    local themeNames = {
        [LevelConfig.THEMES.FOREST] = "FOREST",
        [LevelConfig.THEMES.CAVE] = "CAVE", 
        [LevelConfig.THEMES.VOID] = "VOID",
        [LevelConfig.THEMES.ABYSS] = "ABYSS",
        [LevelConfig.THEMES.VOLCANO] = "VOLCANO",
        [LevelConfig.THEMES.ARCTIC] = "ARCTIC",
        [LevelConfig.THEMES.DESERT] = "DESERT",
        [LevelConfig.THEMES.NEBULA] = "NEBULA"
    }
    local themeName = themeNames[theme] or "FOREST"
    return LevelConfig.COLORS[themeName] or LevelConfig.COLORS.FOREST
end

function LevelConfig.getSettings(theme)
    return LevelConfig.LEVEL_SETTINGS[theme] or LevelConfig.LEVEL_SETTINGS[LevelConfig.THEMES.FOREST]
end

function LevelConfig.getEnemyCount(theme, levelProgress)
    local settings = LevelConfig.getSettings(theme)
    return settings.defaultEnemyCount + (levelProgress - 1) * 2
end

function LevelConfig.getDefaultEnemyCount(theme, levelProgress)
    local settings = LevelConfig.getSettings(theme)
    return settings.defaultEnemyCount + (levelProgress - 1) * 2
end

function LevelConfig.getPoisonEnemyCount(theme, levelProgress)
    local settings = LevelConfig.getSettings(theme)
    return settings.poisonEnemyCount + math.floor((levelProgress - 1) / 2)
end

function LevelConfig.getSplashEnemyCount(theme, levelProgress)
    local settings = LevelConfig.getSettings(theme)
    return settings.splashEnemyCount + math.floor((levelProgress - 1) / 2)
end

function LevelConfig.getLightningEnemyCount(theme, levelProgress)
    local settings = LevelConfig.getSettings(theme)
    return settings.lightningEnemyCount or 0
end

function LevelConfig.getBlobEnemyCount(theme, levelProgress)
    local settings = LevelConfig.getSettings(theme)
    return settings.blobEnemyCount or 0
end

function LevelConfig.getRequiredScore(theme)
    local settings = LevelConfig.getSettings(theme)
    return settings.requiredScore
end

function LevelConfig.getName(theme)
    return LevelConfig.LEVEL_NAMES[theme] or "Unknown Level"
end

function LevelConfig.getDescription(theme)
    return LevelConfig.LEVEL_DESCRIPTIONS[theme] or "A mysterious place."
end

function LevelConfig.getNextTheme(currentTheme)
    if currentTheme < LevelConfig.THEMES.NEBULA then
        return currentTheme + 1
    end
    return nil
end

function LevelConfig.isValidTheme(theme)
    return theme >= LevelConfig.THEMES.FOREST and theme <= LevelConfig.THEMES.NEBULA
end

-- Helper function to create a new level easily
function LevelConfig.createLevel(themeId, name, description, settings)
    LevelConfig.THEMES[themeId] = themeId
    LevelConfig.LEVEL_NAMES[themeId] = name
    LevelConfig.LEVEL_DESCRIPTIONS[themeId] = description
    LevelConfig.LEVEL_SETTINGS[themeId] = settings
end

-- Helper function to get total number of levels
function LevelConfig.getTotalLevels()
    return LevelConfig.THEMES.NEBULA
end

-- Helper function to get all level themes in order
function LevelConfig.getAllThemes()
    local themes = {}
    for i = LevelConfig.THEMES.FOREST, LevelConfig.THEMES.NEBULA do
        table.insert(themes, i)
    end
    return themes
end

return LevelConfig
