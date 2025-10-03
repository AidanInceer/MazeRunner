-- Game configuration constants and colors
local GameConfig = {}

-- Game dimensions
GameConfig.MAZE_ROWS = 20
GameConfig.MAZE_COLS = 20

-- Game objectives
GameConfig.MAX_SCORE = 10
GameConfig.MAX_HEALTH = 100

-- Item counts
GameConfig.COLLECTIBLE_COUNT = 10
GameConfig.REQUIRED_COLLECTIBLES = 5
GameConfig.DAMAGE_TILE_COUNT = 10
GameConfig.HEALTH_BLOB_COUNT = 3
GameConfig.IMMUNITY_BLOB_COUNT = 5
GameConfig.IMMUNITY_BLOB_KILLS = 1
GameConfig.ENEMY_COUNT = 5

-- Enemy settings
GameConfig.ENEMY_MOVE_INTERVAL = 0.6  -- seconds between moves
GameConfig.ENEMY_DAMAGE = 20
GameConfig.DAMAGE_TILE_DAMAGE = 10
GameConfig.HEALTH_RESTORE = 10

-- Animation settings
GameConfig.HIT_FLASH_DURATION = 0.3
GameConfig.ENEMY_HIT_FLASH_DURATION = 0.5
GameConfig.PARTICLE_LIFE = 0.5
GameConfig.IMMUNITY_PARTICLE_LIFE = 0.8

-- UI settings
GameConfig.UI_BOX_WIDTH = 250
GameConfig.UI_BOX_HEIGHT = 180
GameConfig.HEALTH_BAR_WIDTH = 200
GameConfig.HEALTH_BAR_HEIGHT = 15

-- Colors (RGBA values 0-1)
GameConfig.COLORS = {
    -- Player colors
    PLAYER_BORDER = {0.3, 0.1, 0.1, 1},
    PLAYER_INNER = {0.8, 0.2, 0.2, 1},
    PLAYER_IMMUNE_BORDER = {0.3, 0.1, 0.3, 1},
    PLAYER_IMMUNE_INNER = {0.8, 0.2, 0.8, 1},
    
    -- Enemy colors
    ENEMY_BORDER = {0.3, 0.1, 0.3, 1},
    ENEMY_INNER = {0.8, 0.2, 0.8, 1},
    
    -- Tile colors
    WALL_BORDER = {0.4, 0.2, 0.05, 1},
    WALL_INNER = {0.7, 0.5, 0.3, 1},
    WALL_HOVER_BORDER = {0.2, 0.1, 0.02, 1},
    WALL_HOVER_INNER = {0.4, 0.3, 0.2, 1},
    
    SPAWN_BORDER = {0.2, 0.4, 0.8, 1},
    SPAWN_HOVER = {0.1, 0.2, 0.4, 1},
    FINALE_BORDER = {0.0, 1.0, 0.0, 1},  -- Bright green
    FINALE_HOVER = {0.0, 0.8, 0.0, 1},   -- Slightly darker green
    FINALE_GLOW = {0.0, 1.0, 0.0, 0.3},  -- Green glow effect
    
    -- Walkable area colors
    WALKABLE_BORDER = {0.2, 0.4, 0.2, 1},
    WALKABLE_INNER = {0.4, 0.7, 0.4, 1},
    WALKABLE_HOVER_BORDER = {0.1, 0.3, 0.1, 1},
    WALKABLE_HOVER_INNER = {0.3, 0.6, 0.3, 1},
    
    -- Item colors
    COLLECTIBLE = {1, 1, 0, 1},  -- Yellow
    DAMAGE_TILE = {0.5, 0.5, 0.5, 1},  -- Grey
    HEALTH_BLOB = {0, 1, 0, 1},  -- Green
    IMMUNITY_BLOB = {1, 0, 0, 1},  -- Red
    
    -- UI colors
    UI_BACKGROUND = {0.1, 0.1, 0.1, 0.8},
    UI_TEXT = {1, 1, 1, 1},
    UI_IMMUNE_TEXT = {1, 1, 0, 1},
    UI_NORMAL_TEXT = {0.7, 0.7, 0.7, 1},
    
    -- Health bar colors
    HEALTH_BAR_BACKGROUND = {0.3, 0.1, 0.1, 1},
    HEALTH_BAR_BORDER = {0.8, 0.8, 0.8, 1},
    
    -- Particle colors
    PARTICLE_YELLOW = {1, 1, 0, 1},
    PARTICLE_GREEN = {0, 1, 0, 1},
    PARTICLE_RED = {1, 0, 0, 1},
    
    -- Effects
    HIT_FLASH = {1, 0, 0, 0.5},
    IMMUNITY_GLOW = {1, 1, 0, 0.3}
}

-- Direction constants
GameConfig.DIRECTIONS = {
    UP = 1,
    DOWN = 2,
    LEFT = 3,
    RIGHT = 4
}

-- Game states
GameConfig.STATES = {
    MENU = "menu",
    PLAYING = "playing",
    GAME_OVER = "gameOver",
    GAME_WON = "gameWon",
    INSUFFICIENT_SCORE = "insufficientScore"
}

return GameConfig
