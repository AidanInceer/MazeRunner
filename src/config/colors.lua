-- Color definitions for the game
local Colors = {}

-- Base color palette
Colors.BASE = {
    -- Grays
    DARK_GRAY = {0.1, 0.1, 0.1, 1},
    GRAY = {0.3, 0.3, 0.3, 1},
    LIGHT_GRAY = {0.5, 0.5, 0.5, 1},
    
    -- Primary colors
    RED = {1.0, 0.0, 0.0, 1},
    GREEN = {0.0, 1.0, 0.0, 1},
    BLUE = {0.0, 0.0, 1.0, 1},
    YELLOW = {1.0, 1.0, 0.0, 1},
    PURPLE = {0.8, 0.2, 0.8, 1},
    ORANGE = {1.0, 0.5, 0.0, 1},
    CYAN = {0.0, 1.0, 1.0, 1},
    MAGENTA = {1.0, 0.0, 1.0, 1},
    
    -- Whites and blacks
    WHITE = {1.0, 1.0, 1.0, 1},
    BLACK = {0.0, 0.0, 0.0, 1},
    OFF_WHITE = {0.9, 0.9, 0.9, 1},
    DARK_BLACK = {0.05, 0.05, 0.05, 1}
}

-- Player colors
Colors.PLAYER = {
    BORDER = {0.3, 0.1, 0.1, 1},
    INNER = {0.8, 0.2, 0.2, 1},
    IMMUNE_BORDER = {0.3, 0.1, 0.3, 1},
    IMMUNE_INNER = {0.8, 0.2, 0.8, 1},
    GLOW_BLUE = {0, 0.8, 1, 0.3},
    GLOW_YELLOW = {1, 1, 0, 0.3},
    CENTER_DOT = {1, 1, 1, 1},
    IMMUNE_DOT = {1, 1, 0, 1}
}

-- Enemy colors
Colors.ENEMY = {
    BORDER = {0.3, 0.1, 0.3, 1},
    INNER = {0.8, 0.2, 0.8, 1},
    THEME_FOREST = {0.0, 1.0, 0.0},
    THEME_CAVE = {0.8, 0.4, 0.0},
    THEME_VOID = {0.0, 0.0, 1.0},
    THEME_ABYSS = {1.0, 0.0, 0.0}
}

-- Tile colors
Colors.TILE = {
    WALL_BORDER = {0.4, 0.2, 0.05, 1},
    WALL_INNER = {0.7, 0.5, 0.3, 1},
    WALL_HOVER_BORDER = {0.2, 0.1, 0.02, 1},
    WALL_HOVER_INNER = {0.4, 0.3, 0.2, 1},
    
    SPAWN_BORDER = {0.2, 0.4, 0.8, 1},
    SPAWN_HOVER = {0.1, 0.2, 0.4, 1},
    
    FINALE_BORDER = {0.0, 1.0, 0.0, 1},
    FINALE_HOVER = {0.0, 0.8, 0.0, 1},
    FINALE_GLOW = {0.0, 1.0, 0.0, 0.3},
    FINALE_ARROW = {1, 1, 1, 1},
    
    WALKABLE_BORDER = {0.2, 0.4, 0.2, 1},
    WALKABLE_INNER = {0.4, 0.7, 0.4, 1},
    WALKABLE_HOVER_BORDER = {0.1, 0.3, 0.1, 1},
    WALKABLE_HOVER_INNER = {0.3, 0.6, 0.3, 1}
}

-- Item colors
Colors.ITEMS = {
    COLLECTIBLE = {1, 1, 0, 1},  -- Yellow
    DAMAGE_TILE = {0.5, 0.5, 0.5, 1},  -- Grey
    DAMAGE_SPIKES = {0.2, 0.2, 0.2, 1},
    DAMAGE_SPIKES_INNER = {0.1, 0.1, 0.1, 1},
    HEALTH_BLOB = {0, 1, 0, 1},  -- Green
    HEALTH_CROSS = {1, 1, 1, 1},
    IMMUNITY_BLOB = {1, 0, 0, 1},  -- Red
    IMMUNITY_SHIELD = {1, 1, 1, 1},
    POISON_TILE = {0.2, 0.8, 0.2, 0.7},  -- Semi-transparent green
    POISON_ENEMY = {0.4, 0.8, 0.4, 1}  -- Light green
}

-- UI colors
Colors.UI = {
    BACKGROUND = {0.1, 0.1, 0.1, 0.8},
    TEXT = {1, 1, 1, 1},
    IMMUNE_TEXT = {1, 1, 0, 1},
    NORMAL_TEXT = {0.7, 0.7, 0.7, 1},
    BORDER = {0.8, 0.8, 0.8, 1},
    HIGHLIGHT = {1, 1, 1, 0.4},
    SHADOW = {0, 0, 0, 0.3}
}

-- Health bar colors
Colors.HEALTH = {
    BACKGROUND = {0.3, 0.1, 0.1, 1},
    BORDER = {0.8, 0.8, 0.8, 1},
    FILL = {0.8, 0.2, 0.2, 1},
    HIGHLIGHT = {1, 1, 1, 0.3}
}

-- Particle colors
Colors.PARTICLES = {
    YELLOW = {1, 1, 0, 1},
    GREEN = {0, 1, 0, 1},
    RED = {1, 0, 0, 1},
    HIT_FLASH = {1, 0, 0, 0.5},
    IMMUNITY_GLOW = {1, 1, 0, 0.3}
}

-- Level theme colors
Colors.THEMES = {
    FOREST = {
        background = {0.1, 0.3, 0.1, 1},
        wall_border = {0.2, 0.4, 0.1, 1},
        wall_inner = {0.4, 0.6, 0.2, 1},
        wall_hover_border = {0.1, 0.3, 0.05, 1},
        wall_hover_inner = {0.3, 0.5, 0.15, 1},
        walkable_border = {0.15, 0.35, 0.15, 1},
        walkable_inner = {0.25, 0.45, 0.25, 1},
        walkable_hover_border = {0.1, 0.25, 0.1, 1},
        walkable_hover_inner = {0.2, 0.35, 0.2, 1},
        spawn_border = {0.1, 0.3, 0.6, 1},
        spawn_hover = {0.05, 0.2, 0.4, 1},
        finale_border = {0.0, 0.8, 0.0, 1},
        finale_hover = {0.0, 0.6, 0.0, 1},
        finale_glow = {0.0, 1.0, 0.0, 0.4},
        ui_background = {0.05, 0.15, 0.05, 0.9},
        ui_text = {0.8, 1.0, 0.8, 1}
    },
    
    CAVE = {
        background = {0.1, 0.1, 0.2, 1},
        wall_border = {0.3, 0.3, 0.4, 1},
        wall_inner = {0.5, 0.5, 0.6, 1},
        wall_hover_border = {0.2, 0.2, 0.3, 1},
        wall_hover_inner = {0.4, 0.4, 0.5, 1},
        walkable_border = {0.15, 0.15, 0.25, 1},
        walkable_inner = {0.25, 0.25, 0.35, 1},
        walkable_hover_border = {0.1, 0.1, 0.2, 1},
        walkable_hover_inner = {0.2, 0.2, 0.3, 1},
        spawn_border = {0.2, 0.4, 0.8, 1},
        spawn_hover = {0.1, 0.2, 0.6, 1},
        finale_border = {0.0, 0.8, 1.0, 1},
        finale_hover = {0.0, 0.6, 0.8, 1},
        finale_glow = {0.0, 0.8, 1.0, 0.4},
        ui_background = {0.05, 0.05, 0.15, 0.9},
        ui_text = {0.8, 0.8, 1.0, 1}
    },
    
    VOID = {
        background = {0.05, 0.05, 0.1, 1},
        wall_border = {0.2, 0.1, 0.3, 1},
        wall_inner = {0.4, 0.2, 0.5, 1},
        wall_hover_border = {0.1, 0.05, 0.2, 1},
        wall_hover_inner = {0.3, 0.15, 0.4, 1},
        walkable_border = {0.1, 0.05, 0.15, 1},
        walkable_inner = {0.15, 0.1, 0.2, 1},
        walkable_hover_border = {0.05, 0.02, 0.1, 1},
        walkable_hover_inner = {0.1, 0.05, 0.15, 1},
        spawn_border = {0.3, 0.1, 0.6, 1},
        spawn_hover = {0.2, 0.05, 0.4, 1},
        finale_border = {0.8, 0.0, 1.0, 1},
        finale_hover = {0.6, 0.0, 0.8, 1},
        finale_glow = {0.8, 0.0, 1.0, 0.4},
        ui_background = {0.02, 0.02, 0.05, 0.9},
        ui_text = {0.9, 0.7, 1.0, 1}
    },
    
    ABYSS = {
        background = {0.2, 0.05, 0.05, 1},
        wall_border = {0.4, 0.1, 0.1, 1},
        wall_inner = {0.6, 0.2, 0.2, 1},
        wall_hover_border = {0.3, 0.05, 0.05, 1},
        wall_hover_inner = {0.5, 0.15, 0.15, 1},
        walkable_border = {0.15, 0.05, 0.05, 1},
        walkable_inner = {0.25, 0.1, 0.1, 1},
        walkable_hover_border = {0.1, 0.02, 0.02, 1},
        walkable_hover_inner = {0.2, 0.05, 0.05, 1},
        spawn_border = {0.1, 0.1, 0.6, 1},
        spawn_hover = {0.05, 0.05, 0.4, 1},
        finale_border = {1.0, 0.0, 0.0, 1},
        finale_hover = {0.8, 0.0, 0.0, 1},
        finale_glow = {1.0, 0.0, 0.0, 0.4},
        ui_background = {0.1, 0.02, 0.02, 0.9},
        ui_text = {1.0, 0.8, 0.8, 1}
    }
}

-- Helper function to get theme colors
function Colors.getThemeColors(theme)
    return Colors.THEMES[theme] or Colors.THEMES.FOREST
end

-- Helper function to get base colors
function Colors.getBase()
    return Colors.BASE
end

-- Helper function to get player colors
function Colors.getPlayer()
    return Colors.PLAYER
end

-- Helper function to get enemy colors
function Colors.getEnemy()
    return Colors.ENEMY
end

-- Helper function to get tile colors
function Colors.getTile()
    return Colors.TILE
end

-- Helper function to get item colors
function Colors.getItems()
    return Colors.ITEMS
end

-- Helper function to get UI colors
function Colors.getUI()
    return Colors.UI
end

-- Helper function to get health colors
function Colors.getHealth()
    return Colors.HEALTH
end

-- Helper function to get particle colors
function Colors.getParticles()
    return Colors.PARTICLES
end

return Colors
