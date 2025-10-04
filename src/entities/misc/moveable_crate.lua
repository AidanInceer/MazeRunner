-- Moveable Crate - Brown crate that acts as a moveable wall
local MoveableCrate = {}
local Helpers = require("src.utils.helpers")

function MoveableCrate.create(r, c)
    local crate = {
        r = r,
        c = c,
        type = "moveable_crate",
        -- Visual properties
        color = "brown",
        size = 1.0,
        -- Animation properties
        pulseTimer = 0,
        pulseSpeed = 2,
        glowIntensity = 0.3
    }
    
    -- Add methods to the crate instance
    crate.update = function(self, dt)
        -- Update pulse animation
        self.pulseTimer = self.pulseTimer + dt * self.pulseSpeed
        self.glowIntensity = 0.3 + 0.2 * math.sin(self.pulseTimer)
    end
    
    crate.getAnimationData = function(self)
        return {
            pulseTimer = self.pulseTimer,
            glowIntensity = self.glowIntensity,
            size = self.size
        }
    end
    
    crate.canBePushed = function(self, newR, newC, maze, rows, cols, gameObjects)
        -- Check if the new position is valid and not blocked
        if not Helpers.isValidPosition(newR, newC, rows, cols) then
            return false
        end
        
        -- Check if new position is walkable (not a wall)
        if maze[newR][newC] then
            return false
        end
        
        -- Check if there's an enemy at the new position
        if gameObjects then
            -- Check default enemies
            if gameObjects.enemies then
                for _, enemy in ipairs(gameObjects.enemies) do
                    if enemy.r == newR and enemy.c == newC then
                        return false
                    end
                end
            end
            
            -- Check poison enemies
            if gameObjects.poisonEnemies then
                for _, enemy in ipairs(gameObjects.poisonEnemies) do
                    if enemy.r == newR and enemy.c == newC then
                        return false
                    end
                end
            end
            
            -- Check splash enemies
            if gameObjects.splashEnemies then
                for _, enemy in ipairs(gameObjects.splashEnemies) do
                    if enemy.r == newR and enemy.c == newC then
                        return false
                    end
                end
            end
            
            -- Check blob enemies (2x2 collision)
            if gameObjects.blobEnemies then
                for _, enemy in ipairs(gameObjects.blobEnemies) do
                    local blobR1, blobC1 = enemy.r, enemy.c
                    local blobR2, blobC2 = enemy.r + 1, enemy.c
                    local blobR3, blobC3 = enemy.r, enemy.c + 1
                    local blobR4, blobC4 = enemy.r + 1, enemy.c + 1
                    
                    if (newR == blobR1 and newC == blobC1) or
                       (newR == blobR2 and newC == blobC2) or
                       (newR == blobR3 and newC == blobC3) or
                       (newR == blobR4 and newC == blobC4) then
                        return false
                    end
                end
            end
            
            -- Check lightning enemies
            if gameObjects.lightningEnemies then
                for _, enemy in ipairs(gameObjects.lightningEnemies) do
                    if enemy.r == newR and enemy.c == newC then
                        return false
                    end
                end
            end
        end
        
        -- Check if there's another crate at the new position
        -- This will be handled by the game logic checking for crate collisions
        
        return true
    end
    
    crate.push = function(self, newR, newC)
        self.r = newR
        self.c = newC
        return true
    end
    
    return crate
end

return MoveableCrate
