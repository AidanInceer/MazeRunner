-- Helper utilities for common game operations
local Helpers = {}

-- Creates a 2D array filled with a default value
function Helpers.create2DArray(rows, cols, defaultValue)
    local array = {}
    for r = 1, rows do
        array[r] = {}
        for c = 1, cols do
            array[r][c] = defaultValue
        end
    end
    return array
end

-- Checks if a position is within maze bounds
function Helpers.isValidPosition(r, c, rows, cols)
    return r >= 1 and r <= rows and c >= 1 and c <= cols
end

-- Calculates screen position for a grid cell
function Helpers.getScreenPosition(cellSize, offsetX, offsetY, r, c)
    local x = offsetX + (c - 1) * cellSize
    local y = offsetY + (r - 1) * cellSize
    return x, y
end

-- Calculates grid dimensions and offsets for centering
function Helpers.calculateGridDimensions(screenWidth, screenHeight, rows, cols)
    local cellSize = math.min(screenWidth / cols, screenHeight / rows)
    local gridWidth = cellSize * cols
    local gridHeight = cellSize * rows
    local offsetX = (screenWidth - gridWidth) / 2
    local offsetY = (screenHeight - gridHeight) / 2
    return cellSize, gridWidth, gridHeight, offsetX, offsetY
end

-- Checks if mouse is hovering over a rectangular area
function Helpers.isMouseHovering(mouseX, mouseY, x, y, width, height)
    return mouseX >= x and mouseX <= x + width and
           mouseY >= y and mouseY <= y + height
end

-- Creates a particle with given properties
function Helpers.createParticle(x, y, angle, speed, life, size, color)
    return {
        x = x,
        y = y,
        vx = math.cos(angle) * speed,
        vy = math.sin(angle) * speed,
        life = life,
        maxLife = life,
        size = size,
        color = color
    }
end

-- Creates particles in a circle pattern
function Helpers.createCircularParticles(centerX, centerY, count, speed, life, size, color)
    local particles = {}
    for i = 1, count do
        local angle = (i - 1) * (2 * math.pi / count)
        local particleSpeed = speed + math.random() * (speed * 0.5)
        local particleSize = size + math.random() * (size * 0.5)
        table.insert(particles, Helpers.createParticle(
            centerX, centerY, angle, particleSpeed, life, particleSize, color
        ))
    end
    return particles
end

-- Shuffles an array in place using Fisher-Yates algorithm
function Helpers.shuffleArray(array)
    for i = #array, 2, -1 do
        local j = math.random(i)
        array[i], array[j] = array[j], array[i]
    end
end

-- Calculates Manhattan distance between two points
function Helpers.manhattanDistance(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

-- Clamps a value between min and max
function Helpers.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

return Helpers
