

local Player = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

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

function Player.updateHealth(player, amount)
    player.health = Helpers.clamp(player.health + amount, 0, player.maxHealth)
    return player.health <= 0
end

function Player.updateScore(player, amount)
    player.score = Helpers.clamp(player.score + amount, 0, player.maxScore)
end

function Player.setImmunity(player, immune, kills)
    player.immune = immune
    player.immunityKills = kills or 0
end

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

function Player.isAtPosition(player, r, c)
    return player.r == r and player.c == c
end

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
