-- Shader Manager
-- Handles loading and applying visual shaders to enhance the game

local ShaderManager = {}

-- Shader variables
local shaders = {}
local currentShader = nil
local canvas = nil
local shaderEnabled = true

-- Initialize shaders
function ShaderManager.init()
    -- Load only enemy shader
    local success, enemyRetroWaveShader = pcall(love.graphics.newShader, "src/shaders/enemy_retro_wave.frag")
    if success then
        shaders.enemyRetroWave = enemyRetroWaveShader
    else
        print("Warning: Could not load enemy retro wave shader")
    end
    
    -- No default global shader
    currentShader = nil
    canvas = nil
end

-- Update shader uniforms (no global shaders)
function ShaderManager.update(dt)
    -- No global shader updates needed
end

-- Start shader rendering (disabled)
function ShaderManager.begin()
    -- No global shader rendering
end

-- End shader rendering (disabled)
function ShaderManager.finish()
    -- No global shader rendering
end

-- Set active shader (disabled)
function ShaderManager.setShader(shaderName)
    -- No global shaders
end

-- Toggle shader effects (disabled)
function ShaderManager.toggle()
    -- No global shaders to toggle
end

-- Get shader status
function ShaderManager.isEnabled()
    return shaderEnabled
end

-- Get available shaders
function ShaderManager.getAvailableShaders()
    local available = {}
    for name, shader in pairs(shaders) do
        if shader then
            table.insert(available, name)
        end
    end
    return available
end

-- Apply enemy retro wave shader
function ShaderManager.applyEnemyRetroWave(enemyColor, themeType)
    if shaders.enemyRetroWave and shaderEnabled then
        love.graphics.setShader(shaders.enemyRetroWave)
        
        local time = love.timer.getTime()
        local screenWidth, screenHeight = love.graphics.getDimensions()
        
        shaders.enemyRetroWave:send("time", time)
        shaders.enemyRetroWave:send("resolution", {screenWidth, screenHeight})
        shaders.enemyRetroWave:send("enemyColor", enemyColor)
        shaders.enemyRetroWave:send("themeType", themeType or 0)
    end
end

-- Clear enemy shader
function ShaderManager.clearEnemyShader()
    if shaders.enemyRetroWave then
        love.graphics.setShader()
    end
end

return ShaderManager
