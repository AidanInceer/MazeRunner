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

-- Level color schemes
LevelConfig.COLORS = {
    [LevelConfig.THEMES.FOREST] = {
        -- Background
        background = {0.1, 0.3, 0.1, 1},
        
        -- Walls
        wall_border = {0.2, 0.4, 0.1, 1},
        wall_inner = {0.4, 0.6, 0.2, 1},
        wall_hover_border = {0.1, 0.3, 0.05, 1},
        wall_hover_inner = {0.3, 0.5, 0.15, 1},
        
        -- Walkable areas
        walkable_border = {0.15, 0.35, 0.15, 1},
        walkable_inner = {0.25, 0.45, 0.25, 1},
        walkable_hover_border = {0.1, 0.25, 0.1, 1},
        walkable_hover_inner = {0.2, 0.35, 0.2, 1},
        
        -- Special tiles
        spawn_border = {0.1, 0.3, 0.6, 1},
        spawn_hover = {0.05, 0.2, 0.4, 1},
        finale_border = {0.0, 0.8, 0.0, 1},
        finale_hover = {0.0, 0.6, 0.0, 1},
        finale_glow = {0.0, 1.0, 0.0, 0.4},
        
        -- UI
        ui_background = {0.05, 0.15, 0.05, 0.9},
        ui_text = {0.8, 1.0, 0.8, 1}
    },
    
    [LevelConfig.THEMES.CAVE] = {
        -- Background
        background = {0.1, 0.1, 0.2, 1},
        
        -- Walls
        wall_border = {0.3, 0.3, 0.4, 1},
        wall_inner = {0.5, 0.5, 0.6, 1},
        wall_hover_border = {0.2, 0.2, 0.3, 1},
        wall_hover_inner = {0.4, 0.4, 0.5, 1},
        
        -- Walkable areas
        walkable_border = {0.15, 0.15, 0.25, 1},
        walkable_inner = {0.25, 0.25, 0.35, 1},
        walkable_hover_border = {0.1, 0.1, 0.2, 1},
        walkable_hover_inner = {0.2, 0.2, 0.3, 1},
        
        -- Special tiles
        spawn_border = {0.2, 0.4, 0.8, 1},
        spawn_hover = {0.1, 0.2, 0.6, 1},
        finale_border = {0.0, 0.8, 1.0, 1},
        finale_hover = {0.0, 0.6, 0.8, 1},
        finale_glow = {0.0, 0.8, 1.0, 0.4},
        
        -- UI
        ui_background = {0.05, 0.05, 0.15, 0.9},
        ui_text = {0.8, 0.8, 1.0, 1}
    },
    
    [LevelConfig.THEMES.VOID] = {
        -- Background
        background = {0.05, 0.05, 0.1, 1},
        
        -- Walls
        wall_border = {0.2, 0.1, 0.3, 1},
        wall_inner = {0.4, 0.2, 0.5, 1},
        wall_hover_border = {0.1, 0.05, 0.2, 1},
        wall_hover_inner = {0.3, 0.15, 0.4, 1},
        
        -- Walkable areas
        walkable_border = {0.1, 0.05, 0.15, 1},
        walkable_inner = {0.15, 0.1, 0.2, 1},
        walkable_hover_border = {0.05, 0.02, 0.1, 1},
        walkable_hover_inner = {0.1, 0.05, 0.15, 1},
        
        -- Special tiles
        spawn_border = {0.3, 0.1, 0.6, 1},
        spawn_hover = {0.2, 0.05, 0.4, 1},
        finale_border = {0.8, 0.0, 1.0, 1},
        finale_hover = {0.6, 0.0, 0.8, 1},
        finale_glow = {0.8, 0.0, 1.0, 0.4},
        
        -- UI
        ui_background = {0.02, 0.02, 0.05, 0.9},
        ui_text = {0.9, 0.7, 1.0, 1}
    },
    
    [LevelConfig.THEMES.ABYSS] = {
        -- Background
        background = {0.2, 0.05, 0.05, 1},
        
        -- Walls
        wall_border = {0.4, 0.1, 0.1, 1},
        wall_inner = {0.6, 0.2, 0.2, 1},
        wall_hover_border = {0.3, 0.05, 0.05, 1},
        wall_hover_inner = {0.5, 0.15, 0.15, 1},
        
        -- Walkable areas
        walkable_border = {0.15, 0.05, 0.05, 1},
        walkable_inner = {0.25, 0.1, 0.1, 1},
        walkable_hover_border = {0.1, 0.02, 0.02, 1},
        walkable_hover_inner = {0.2, 0.05, 0.05, 1},
        
        -- Special tiles
        spawn_border = {0.1, 0.1, 0.6, 1},
        spawn_hover = {0.05, 0.05, 0.4, 1},
        finale_border = {1.0, 0.0, 0.0, 1},
        finale_hover = {0.8, 0.0, 0.0, 1},
        finale_glow = {1.0, 0.0, 0.0, 0.4},
        
        -- UI
        ui_background = {0.1, 0.02, 0.02, 0.9},
        ui_text = {1.0, 0.8, 0.8, 1}
    }
}

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
    return LevelConfig.COLORS[theme] or LevelConfig.COLORS[LevelConfig.THEMES.FOREST]
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
