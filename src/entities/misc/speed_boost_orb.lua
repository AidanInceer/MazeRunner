-- Speed Boost Orb - Blue orb that increases player movement speed
local SpeedBoostOrb = {}

function SpeedBoostOrb.create(r, c)
    local orb = {
        r = r,
        c = c,
        type = "speed_boost",
        collected = false,
        -- Visual properties
        color = "blue",
        size = 0.8,
        -- Animation properties
        pulseTimer = 0,
        pulseSpeed = 4,
        glowIntensity = 0.5
    }
    
    -- Add methods to the orb instance
    orb.collect = function(self)
        self.collected = true
        return {
            type = "speed_boost",
            duration = 5.0,  -- 5 seconds
            speedMultiplier = 1.8  -- 1.8x speed
        }
    end
    
    orb.update = function(self, dt)
        if self.collected then
            return
        end
        
        -- Update pulse animation
        self.pulseTimer = self.pulseTimer + dt * self.pulseSpeed
        self.glowIntensity = 0.5 + 0.3 * math.sin(self.pulseTimer)
    end
    
    orb.getAnimationData = function(self)
        return {
            pulseTimer = self.pulseTimer,
            glowIntensity = self.glowIntensity,
            size = self.size
        }
    end
    
    return orb
end

return SpeedBoostOrb
