--[[
    Player Entity Module
    
    Handles player movement, collision detection, and state management.
    Manages player health, immunity, and interaction with game objects.
]]

local Player = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

--[[
    Creates a new player instance
    
    @param r number Starting row position
    @param c number Starting column position
    @return table Player object
]]
function Player.create(r, c)
    return {
        r = r,
        c = c,
        health = GameConfig.MAX_HEALTH,
        maxHealth = GameConfig.MAX_HEALTH,
        score = 0,
        maxScore = GameConfig.MAX_SCORE,
        immune = false,
        immunityKills = 0,
        totalEnemiesKilled = 0
    }
end

--[[
    Moves the player in the specified direction
    
    @param player table Player object
    @param direction string Movement direction ("up", "down", "left", "right")
    @param maze table 2D maze array
    @param rows number Number of maze rows
    @param cols number Number of maze columns
    @return boolean True if movement was successful
]]
function Player.move(player, direction, maze, rows, cols)
    local newR, newC = player.r, player.c
    
    if direction == "up" then
        newR = newR - 1
    elseif direction == "down" then
        newR = newR + 1
    elseif direction == "left" then
        newC = newC - 1
    elseif direction == "right" then
        newC = newC + 1
    end
    
    -- Check if move is valid
    if Helpers.isValidPosition(newR, newC, rows, cols) then
        local canMove = not maze[newR][newC] or 
                       maze[newR][newC] == "spawn" or 
                       maze[newR][newC] == "finale"
        
        if canMove then
            player.r, player.c = newR, newC
            return true
        end
    end
    
    return false
end

--[[
    Updates player health
    
    @param player table Player object
    @param amount number Amount to add/subtract
    @return boolean True if player died
]]
function Player.updateHealth(player, amount)
    player.health = Helpers.clamp(player.health + amount, 0, player.maxHealth)
    return player.health <= 0
end

--[[
    Updates player score
    
    @param player table Player object
    @param amount number Amount to add
]]
function Player.updateScore(player, amount)
    player.score = Helpers.clamp(player.score + amount, 0, player.maxScore)
end

--[[
    Sets immunity state
    
    @param player table Player object
    @param immune boolean Whether player is immune
    @param kills number Number of kills available
]]
function Player.setImmunity(player, immune, kills)
    player.immune = immune
    player.immunityKills = kills or 0
end

--[[
    Uses one immunity kill
    
    @param player table Player object
    @return boolean True if kill was used successfully
]]
function Player.useImmunityKill(player)
    if player.immune and player.immunityKills > 0 then
        player.immunityKills = player.immunityKills - 1
        player.totalEnemiesKilled = player.totalEnemiesKilled + 1
        
        if player.immunityKills <= 0 then
            player.immune = false
        end
        return true
    end
    return false
end

--[[
    Checks if player is at a specific position
    
    @param player table Player object
    @param r number Row position
    @param c number Column position
    @return boolean True if player is at position
]]
function Player.isAtPosition(player, r, c)
    return player.r == r and player.c == c
end

--[[
    Gets player data for rendering
    
    @param player table Player object
    @return table Player data for rendering
]]
function Player.getRenderData(player)
    return {
        r = player.r,
        c = player.c,
        health = player.health,
        maxHealth = player.maxHealth,
        score = player.score,
        maxScore = player.maxScore,
        immune = player.immune,
        immunityKills = player.immunityKills,
        totalEnemiesKilled = player.totalEnemiesKilled
    }
end

--[[
    Resets player to initial state
    
    @param player table Player object
    @param r number New row position
    @param c number New column position
]]
function Player.reset(player, r, c)
    player.r = r
    player.c = c
    player.health = GameConfig.MAX_HEALTH
    player.maxHealth = GameConfig.MAX_HEALTH
    player.score = 0
    player.maxScore = GameConfig.MAX_SCORE
    player.immune = false
    player.immunityKills = 0
    player.totalEnemiesKilled = 0
end

return Player
