-- Grey Orb - Collectible item that goes into inventory
local GreyOrb = {}

function GreyOrb.create(r, c)
    local orb = {
        r = r,
        c = c,
        type = "grey_orb",
        collected = false,
        -- Visual properties
        color = "grey",
        size = 1, -- 1x1 orb
        -- Animation properties
        pulseTimer = 0,
        pulseSpeed = 2,
        glowIntensity = 0.7
    }
    
    -- Add methods to the orb instance
    orb.collect = function(self)
        self.collected = true
        return {
            type = "grey_orb",
            name = "Grey Orb",
            icon = "●"
        }
    end
    
    orb.update = function(self, dt)
        -- Update pulse animation
        self.pulseTimer = self.pulseTimer + dt * self.pulseSpeed
        self.glowIntensity = 0.7 + 0.3 * math.sin(self.pulseTimer)
    end
    
    orb.getAnimationData = function(self)
        return {
            glowIntensity = self.glowIntensity,
            size = self.size
        }
    end
    
    return orb
end

return GreyOrb
