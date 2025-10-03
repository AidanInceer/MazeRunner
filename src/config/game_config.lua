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
GameConfig.POISON_ENEMY_COUNT = 2

-- Enemy settings
GameConfig.ENEMY_MOVE_INTERVAL = 0.6  -- seconds between moves
GameConfig.ENEMY_DAMAGE = 20
GameConfig.DAMAGE_TILE_DAMAGE = 10
GameConfig.HEALTH_RESTORE = 10

-- Poison settings
GameConfig.POISON_DAMAGE = 3
GameConfig.POISON_DURATION = 3  -- seconds of poison effect on player
GameConfig.POISON_TILE_DURATION = 2  -- seconds poison tile lasts
GameConfig.POISON_TRAIL_LENGTH = 4  -- number of previous positions to poison

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

-- Import colors from separate config
local Colors = require("src.config.colors")
GameConfig.COLORS = Colors

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
