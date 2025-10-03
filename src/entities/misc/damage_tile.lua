-- Damage tile entity that deals damage to the player when stepped on
local DamageTile = {}
local GameConfig = require("src.config.game_config")

function DamageTile.create(r, c)
    return {
        r = r,
        c = c,
        damage = GameConfig.DAMAGE_TILE_DAMAGE,
        color = "grey",
        active = true
    }
end

function DamageTile.isPlayerOn(tile, player)
    return tile.active and tile.r == player.r and tile.c == player.c
end

function DamageTile.applyDamage(tile, player)
    if tile.active and tile.r == player.r and tile.c == player.c then
        return {
            damage = tile.damage,
            flashDuration = GameConfig.HIT_FLASH_DURATION,
            effects = DamageTile._createDamageEffects(tile.r, tile.c)
        }
    end
    
    return nil
end

function DamageTile._createDamageEffects(r, c)
    return {
        flashColor = {1, 0, 0, 0.5},  -- Red flash
        flashDuration = GameConfig.HIT_FLASH_DURATION
    }
end

function DamageTile.placeMultiple(maze, rows, cols, count)
    local tiles = {}
    for r = 1, rows do
        tiles[r] = {}
        for c = 1, cols do
            tiles[r][c] = false
        end
    end
    
    local placed = 0
    local attempts = 0
    local maxAttempts = 500
    
    while placed < count and attempts < maxAttempts do
        attempts = attempts + 1
        local r = math.random(1, rows)
        local c = math.random(1, cols)
        
        if not maze[r][c] and not tiles[r][c] then
            tiles[r][c] = DamageTile.create(r, c)
            placed = placed + 1
        end
    end
    
    return tiles
end

function DamageTile.getRenderData(tile)
    return {
        r = tile.r,
        c = tile.c,
        active = tile.active,
        color = tile.color,
        damage = tile.damage
    }
end

function DamageTile.isActive(tile)
    return tile.active
end

function DamageTile.deactivate(tile)
    tile.active = false
end

function DamageTile.activate(tile)
    tile.active = true
end

return DamageTile
