-- Rendering system for maze, UI, particles, and effects
local Rendering = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")
local GameState = require("src.core.game_state")
local SplashEnemy = require("src.entities.enemies.splash_enemy")

function Rendering.drawMainMenu(screenWidth, screenHeight, startButton, colors)
    for y = 0, screenHeight do
        local gradient = y / screenHeight
        local r = colors.background[1] * (0.7 + 0.3 * gradient)
        local g = colors.background[2] * (0.7 + 0.3 * gradient)
        local b = colors.background[3] * (0.7 + 0.3 * gradient)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, y, screenWidth, 1)
    end
    
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.2)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", 20, 20, screenWidth - 40, screenHeight - 40)
    
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 30, 30, screenWidth - 60, screenHeight - 60)
    
    -- Draw fancy retro title with multiple outline layers
    local titleText = "MAZE RUNNER"
    local titleY = screenHeight/2 - 200
    
    -- Multiple outline layers for depth
    love.graphics.setFont(love.graphics.newFont(80))
    love.graphics.setColor(0, 0, 0, 0.9)
    for i = -3, 3 do
        for j = -3, 3 do
            if i ~= 0 or j ~= 0 then
                love.graphics.printf(titleText, i, titleY + j, screenWidth, "center")
            end
        end
    end
    
    -- Main title with gradient effect
    love.graphics.setColor(1, 0.8, 0.2, 1)  -- Golden yellow
    love.graphics.printf(titleText, 0, titleY, screenWidth, "center")
    
    -- Title highlight
    love.graphics.setColor(1, 1, 0.6, 0.8)
    love.graphics.printf(titleText, 0, titleY - 2, screenWidth, "center")
    
    -- Draw animated subtitle with pulsing effect
    local time = love.timer.getTime()
    local pulse = 0.8 + 0.2 * math.sin(time * 3)
    love.graphics.setFont(love.graphics.newFont(32))
    
    -- Subtitle glow
    love.graphics.setColor(0.3, 0.3, 0.8, 0.4 * pulse)
    for i = -2, 2 do
        for j = -2, 2 do
            if i ~= 0 or j ~= 0 then
                love.graphics.printf("Navigate the labyrinth, collect treasures, survive the dangers!", 
                    i, screenHeight/2 - 120 + j, screenWidth, "center")
            end
        end
    end
    
    -- Main subtitle
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], pulse)
    love.graphics.printf("Navigate the labyrinth, collect treasures, survive the dangers!", 
        0, screenHeight/2 - 120, screenWidth, "center")
    
    -- Draw feature text without boxes
    local textY = screenHeight/2 - 60
    local textSpacing = 30
    
    -- Feature 1: Collect blobs
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.setColor(colors.ui_text)
    love.graphics.printf("💛 Collect 5 yellow blobs to unlock the exit", 0, textY, screenWidth, "center")
    
    -- Feature 2: Avoid dangers
    love.graphics.printf("⚠️ Avoid grey tiles and purple enemies", 0, textY + textSpacing, screenWidth, "center")
    
    -- Feature 3: Power-ups
    love.graphics.printf("💚💊 Use green blobs to heal, red for immunity", 0, textY + textSpacing * 2, screenWidth, "center")
    
    -- Draw controls with better styling
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.8)
    love.graphics.printf("WASD to move • Space/Enter to start • R to restart", 
        0, screenHeight/2 + 80, screenWidth, "center")
    
    -- Center and style the start button
    startButton.x = (screenWidth - 280) / 2
    startButton.y = screenHeight/2 + 120
    startButton.width = 280
    startButton.height = 60
    
    -- Draw start button with enhanced styling
    Rendering._drawEnhancedButton(startButton, "🚀 START ADVENTURE", 24, colors)
    
    -- Draw version info
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.5)
    love.graphics.printf("v1.0 • Made with LÖVE", 0, screenHeight - 30, screenWidth, "center")
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Rendering.drawGame(screenWidth, screenHeight, maze, gameObjects, playerData, animationData, colors)
    local rows, cols = GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS
    local cellSize, gridWidth, gridHeight, offsetX, offsetY = 
        Helpers.calculateGridDimensions(screenWidth, screenHeight, rows, cols)
    
    local mouseX, mouseY = love.mouse.getPosition()
    
    -- Draw maze tiles
    Rendering._drawMazeTiles(maze, rows, cols, cellSize, offsetX, offsetY, mouseX, mouseY, gameObjects, colors)
    
    -- Draw enemies (with shaders)
    Rendering._drawEnemies(gameObjects.enemies, cellSize, offsetX, offsetY)
    
    -- Draw splash tiles (fire/burn effect)
    Rendering._drawSplashTiles(gameObjects.splashTiles, cellSize, offsetX, offsetY)
    
    -- Draw poison tiles (bright green trail)
    Rendering._drawPoisonTiles(gameObjects.poisonTiles, cellSize, offsetX, offsetY)
    
    -- Draw player
    Rendering._drawPlayer(playerData, cellSize, offsetX, offsetY)
    
    -- Draw effects
    Rendering._drawEffects(animationData, screenWidth, screenHeight)
    
    -- Draw splash enemies
    Rendering._drawSplashEnemies(gameObjects.splashEnemies, cellSize, offsetX, offsetY)
    
    -- Draw poison enemies LAST - on top of everything
    Rendering._drawPoisonEnemies(gameObjects.poisonEnemies, cellSize, offsetX, offsetY)
end

function Rendering.drawUI(playerData, screenHeight, restartButton, colors)
    local boxX, boxY = 15, 15
    local boxWidth, boxHeight = GameConfig.UI_BOX_WIDTH, GameConfig.UI_BOX_HEIGHT
    
    -- Draw UI box with rounded corners effect (using multiple rectangles)
    love.graphics.setColor(colors.ui_background)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)
    
    -- Draw inner border for depth
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.1)
    love.graphics.rectangle("fill", boxX + 2, boxY + 2, boxWidth - 4, boxHeight - 4)
    
    -- Draw main border
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.4)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight)
    
    -- Draw inner border
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.2)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", boxX + 3, boxY + 3, boxWidth - 6, boxHeight - 6)
    
    -- Draw title
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.9)
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.print("STATUS", boxX + 15, boxY + 10)
    
    -- Draw separator line
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.3)
    love.graphics.rectangle("fill", boxX + 15, boxY + 35, boxWidth - 30, 2)
    
    -- Draw text information with better spacing
    love.graphics.setColor(colors.ui_text)
    love.graphics.setFont(love.graphics.newFont(16))
    local lineHeight = 22
    local startY = boxY + 50
    
    love.graphics.print("Level: " .. (playerData.currentLevel or 1), boxX + 20, startY)
    love.graphics.print("Blobs: " .. playerData.score .. "/" .. GameConfig.REQUIRED_COLLECTIBLES, boxX + 20, startY + lineHeight)
    love.graphics.print("Health: " .. playerData.health .. "/" .. playerData.maxHealth, boxX + 20, startY + lineHeight * 2)
    
    -- Draw immunity status with better styling
    if playerData.immune then
        love.graphics.setColor(1, 1, 0.2, 1)  -- Bright yellow for immunity
        love.graphics.print("IMMUNE! Kills: " .. playerData.immunityKills, boxX + 20, startY + lineHeight * 3)
    else
        love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.6)
        love.graphics.print("Not Immune", boxX + 20, startY + lineHeight * 3)
    end
    
    -- Draw poison status
    if GameState.isPlayerPoisoned() then
        local poisonTimer = GameState.getPoisonTimer()
        love.graphics.setColor(0.2, 0.8, 0.2, 1)  -- Green for poison
        love.graphics.print("POISONED! " .. string.format("%.1fs", poisonTimer), boxX + 20, startY + lineHeight * 4)
    end
    
    -- Draw enemies killed
    love.graphics.setColor(colors.ui_text)
    local enemiesKilledY = GameState.isPlayerPoisoned() and startY + lineHeight * 5 or startY + lineHeight * 4
    love.graphics.print("Enemies Killed: " .. playerData.totalEnemiesKilled, boxX + 20, enemiesKilledY)
    
    -- Draw health bar with better positioning
    local healthBarY = GameState.isPlayerPoisoned() and startY + lineHeight * 6 + 5 or startY + lineHeight * 5 + 5
    Rendering._drawHealthBar(playerData.health, playerData.maxHealth, boxX + 20, healthBarY)
    
    -- Draw restart button with better positioning
    restartButton.x = 15
    restartButton.y = screenHeight - restartButton.height - 15
    restartButton.width = 120
    restartButton.height = 35
    
    local mouseX, mouseY = love.mouse.getPosition()
    restartButton.hovered = Helpers.isMouseHovering(
        mouseX, mouseY, restartButton.x, restartButton.y, 
        restartButton.width, restartButton.height
    )
    Rendering._drawButton(restartButton, "Restart (R)", 16)
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Rendering.drawLevelDisplay(screenWidth, screenHeight, levelNumber, levelName, colors)
    local boxWidth, boxHeight = 250, 60
    local boxX = screenWidth - boxWidth - 20
    local boxY = 20
    
    -- Draw UI box with rounded corners effect (using multiple rectangles)
    love.graphics.setColor(colors.ui_background)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)
    
    -- Draw inner border for depth
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.1)
    love.graphics.rectangle("fill", boxX + 2, boxY + 2, boxWidth - 4, boxHeight - 4)
    
    -- Draw main border
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.4)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight)
    
    -- Draw inner border
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.2)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", boxX + 3, boxY + 3, boxWidth - 6, boxHeight - 6)
    
    -- Draw level number with larger font
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.9)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("LEVEL " .. levelNumber, boxX + 10, boxY + 8)
    
    -- Draw separator line
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.3)
    love.graphics.rectangle("fill", boxX + 10, boxY + 28, boxWidth - 20, 2)
    
    -- Draw level name with smaller font
    love.graphics.setColor(colors.ui_text)
    love.graphics.setFont(love.graphics.newFont(9))
    love.graphics.printf(levelName, boxX + 10, boxY + 35, boxWidth - 20, "left")
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Rendering.drawGameMessages(screenWidth, screenHeight, gameWon, gameOver)
    if gameWon then
        love.graphics.setColor(1, 1, 0, 1)  -- Yellow text
        love.graphics.setFont(love.graphics.newFont(48))
        love.graphics.printf("YOU WIN!", 0, screenHeight/2 - 30, screenWidth, "center")
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.printf("Press R or click Restart to play again", 0, screenHeight/2 + 20, screenWidth, "center")
    end
    
    if gameOver then
        love.graphics.setColor(1, 0, 0, 1)  -- Red text
        love.graphics.setFont(love.graphics.newFont(48))
        love.graphics.printf("GAME OVER", 0, screenHeight/2 - 30, screenWidth, "center")
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.printf("Press R or click Restart to try again", 0, screenHeight/2 + 20, screenWidth, "center")
    end
end

function Rendering.drawInsufficientScoreMessage(screenWidth, screenHeight, requiredBlobs)
    -- Draw semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    
    -- Draw message box
    local boxWidth = 400
    local boxHeight = 200
    local boxX = (screenWidth - boxWidth) / 2
    local boxY = (screenHeight - boxHeight) / 2
    
    love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight)
    
    -- Draw text
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("NOT ENOUGH BLOBS", boxX, boxY + 20, boxWidth, "center")
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf("You need " .. requiredBlobs .. " yellow blobs to advance!", boxX, boxY + 70, boxWidth, "center")
    
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("Collect more yellow blobs and try again", boxX, boxY + 120, boxWidth, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.printf("Press R to restart or continue playing", boxX, boxY + 150, boxWidth, "center")
end

-- Private helper functions

function Rendering._drawMazeTiles(maze, rows, cols, cellSize, offsetX, offsetY, mouseX, mouseY, gameObjects, colors)
    for r = 1, rows do
        for c = 1, cols do
            local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, r, c)
            local isHovered = Helpers.isMouseHovering(mouseX, mouseY, x, y, cellSize, cellSize)
            
            if maze[r][c] then
                Rendering._drawWallTile(maze[r][c], x, y, cellSize, isHovered, colors)
            else
                Rendering._drawWalkableTile(x, y, cellSize, isHovered, gameObjects, r, c, colors)
            end
        end
    end
end

function Rendering._drawWallTile(tileType, x, y, cellSize, isHovered, colors)
    -- Draw border
    if isHovered then
        love.graphics.setColor(colors.wall_hover_border)
    else
        love.graphics.setColor(colors.wall_border)
    end
    love.graphics.rectangle("fill", x, y, cellSize, cellSize)
    
    -- Draw inner based on type
    if tileType == "spawn" then
        if isHovered then
            love.graphics.setColor(colors.spawn_hover)
        else
            love.graphics.setColor(colors.spawn_border)
        end
    elseif tileType == "finale" then
        -- Enhanced finale tile with pulsing effect (contained within tile bounds)
        local time = love.timer.getTime()
        local pulse = 0.8 + 0.2 * math.sin(time * 4)
        
        -- Draw outer glow effect for finale (within tile bounds)
        love.graphics.setColor(colors.finale_glow[1], colors.finale_glow[2], colors.finale_glow[3], colors.finale_glow[4] * pulse)
        love.graphics.rectangle("fill", x, y, cellSize, cellSize)
        
        -- Draw inner glow (within tile bounds)
        love.graphics.setColor(1.0, 1.0, 1.0, 0.4 * pulse)
        love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize - 4)
        
        if isHovered then
            love.graphics.setColor(colors.finale_hover[1], colors.finale_hover[2], colors.finale_hover[3], 1)
        else
            love.graphics.setColor(colors.finale_border[1], colors.finale_border[2], colors.finale_border[3], 1)
        end
        
        -- Draw the tile background
        love.graphics.rectangle("fill", x + 4, y + 4, cellSize - 8, cellSize - 8)
        
        -- Draw enhanced down arrow
        local centerX = x + cellSize / 2
        local centerY = y + cellSize / 2
        local arrowSize = cellSize * 0.4
        
        -- Draw arrow shadow/outline
        love.graphics.setColor(0, 0, 0, 0.5)
        local shadowPoints = {
            centerX + 1, centerY - arrowSize/2 + 1,  -- Top point
            centerX - arrowSize/2 + 1, centerY + arrowSize/2 + 1,  -- Bottom left
            centerX + arrowSize/2 + 1, centerY + arrowSize/2 + 1   -- Bottom right
        }
        love.graphics.polygon("fill", shadowPoints)
        
        -- Draw main arrow
        love.graphics.setColor(1, 1, 1, 1)
        local arrowPoints = {
            centerX, centerY - arrowSize/2,  -- Top point
            centerX - arrowSize/2, centerY + arrowSize/2,  -- Bottom left
            centerX + arrowSize/2, centerY + arrowSize/2   -- Bottom right
        }
        love.graphics.polygon("fill", arrowPoints)
        
        return  -- Skip the default rectangle drawing
    else
        if isHovered then
            love.graphics.setColor(colors.wall_hover_inner)
        else
            love.graphics.setColor(colors.wall_inner)
        end
    end
    
    love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize - 4)
end

function Rendering._drawWalkableTile(x, y, cellSize, isHovered, gameObjects, r, c, colors)
    -- Draw border
    if isHovered then
        love.graphics.setColor(colors.walkable_hover_border)
    else
        love.graphics.setColor(colors.walkable_border)
    end
    love.graphics.rectangle("fill", x, y, cellSize, cellSize)
    
    -- Draw inner
    if isHovered then
        love.graphics.setColor(colors.walkable_hover_inner)
    else
        love.graphics.setColor(colors.walkable_inner)
    end
    love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize - 4)
    
    -- Draw items
    Rendering._drawTileItems(x, y, cellSize, gameObjects, r, c)
end

function Rendering._drawTileItems(x, y, cellSize, gameObjects, r, c)
    local centerX = x + cellSize / 2
    local centerY = y + cellSize / 2
    
    -- Draw collectible
    if gameObjects.collectibles[r] and gameObjects.collectibles[r][c] then
        love.graphics.setColor(GameConfig.COLORS.ITEMS.COLLECTIBLE)
        love.graphics.circle("fill", centerX, centerY, cellSize / 6)
    end
    
    -- Draw damage tile with enhanced spike animation
    if gameObjects.damageTiles[r] and gameObjects.damageTiles[r][c] then
        local spikeTime = GameState.getSpikeAnimationTime()
        local spikePulse = 0.6 + 0.4 * math.sin(spikeTime * 12.0 + r + c)
        local spikePulse2 = 0.5 + 0.5 * math.sin(spikeTime * 8.0 + r * 2 + c * 2)
        
        -- Draw base damage tile
        love.graphics.setColor(GameConfig.COLORS.ITEMS.DAMAGE_TILE)
        love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize - 4)
        
        -- Draw animated spikes with multiple layers
        love.graphics.setColor(GameConfig.COLORS.ITEMS.DAMAGE_SPIKES[1], GameConfig.COLORS.ITEMS.DAMAGE_SPIKES[2], GameConfig.COLORS.ITEMS.DAMAGE_SPIKES[3], spikePulse)
        local spikeSize = cellSize * 0.25 * spikePulse
        local spikeSize2 = cellSize * 0.2 * spikePulse2
        
        -- Draw 8 corner and edge spikes
        local spikes = {
            -- Corner spikes (larger)
            {x + 1, y + 1, x + 1 + spikeSize, y + 1, x + 1, y + 1 + spikeSize},  -- Top-left
            {x + cellSize - 1, y + 1, x + cellSize - 1 - spikeSize, y + 1, x + cellSize - 1, y + 1 + spikeSize},  -- Top-right
            {x + 1, y + cellSize - 1, x + 1 + spikeSize, y + cellSize - 1, x + 1, y + cellSize - 1 - spikeSize},  -- Bottom-left
            {x + cellSize - 1, y + cellSize - 1, x + cellSize - 1 - spikeSize, y + cellSize - 1, x + cellSize - 1, y + cellSize - 1 - spikeSize},  -- Bottom-right
            
            -- Edge spikes (smaller)
            {centerX, y + 1, centerX - spikeSize2/2, y + 1 + spikeSize2, centerX + spikeSize2/2, y + 1 + spikeSize2},  -- Top edge
            {centerX, y + cellSize - 1, centerX - spikeSize2/2, y + cellSize - 1 - spikeSize2, centerX + spikeSize2/2, y + cellSize - 1 - spikeSize2},  -- Bottom edge
            {x + 1, centerY, x + 1 + spikeSize2, centerY - spikeSize2/2, x + 1 + spikeSize2, centerY + spikeSize2/2},  -- Left edge
            {x + cellSize - 1, centerY, x + cellSize - 1 - spikeSize2, centerY - spikeSize2/2, x + cellSize - 1 - spikeSize2, centerY + spikeSize2/2}  -- Right edge
        }
        
        for _, spike in ipairs(spikes) do
            love.graphics.polygon("fill", spike)
        end
        
        -- Draw center spike (larger and more prominent)
        local centerSpikeSize = cellSize * 0.15 * spikePulse
        local centerSpike = {
            centerX, centerY - centerSpikeSize,
            centerX - centerSpikeSize, centerY + centerSpikeSize,
            centerX + centerSpikeSize, centerY + centerSpikeSize
        }
        love.graphics.polygon("fill", centerSpike)
        
        -- Draw additional inner spikes for more detail
        love.graphics.setColor(GameConfig.COLORS.ITEMS.DAMAGE_SPIKES_INNER[1], GameConfig.COLORS.ITEMS.DAMAGE_SPIKES_INNER[2], GameConfig.COLORS.ITEMS.DAMAGE_SPIKES_INNER[3], spikePulse2 * 0.8)
        local innerSpikeSize = cellSize * 0.08 * spikePulse2
        local innerSpikes = {
            {centerX - cellSize * 0.2, centerY - cellSize * 0.2, centerX - cellSize * 0.2 - innerSpikeSize, centerY - cellSize * 0.2, centerX - cellSize * 0.2, centerY - cellSize * 0.2 - innerSpikeSize},  -- Inner top-left
            {centerX + cellSize * 0.2, centerY - cellSize * 0.2, centerX + cellSize * 0.2 + innerSpikeSize, centerY - cellSize * 0.2, centerX + cellSize * 0.2, centerY - cellSize * 0.2 - innerSpikeSize},  -- Inner top-right
            {centerX - cellSize * 0.2, centerY + cellSize * 0.2, centerX - cellSize * 0.2 - innerSpikeSize, centerY + cellSize * 0.2, centerX - cellSize * 0.2, centerY + cellSize * 0.2 + innerSpikeSize},  -- Inner bottom-left
            {centerX + cellSize * 0.2, centerY + cellSize * 0.2, centerX + cellSize * 0.2 + innerSpikeSize, centerY + cellSize * 0.2, centerX + cellSize * 0.2, centerY + cellSize * 0.2 + innerSpikeSize}  -- Inner bottom-right
        }
        
        for _, spike in ipairs(innerSpikes) do
            love.graphics.polygon("fill", spike)
        end
    end
    
    -- Draw health blob
    if gameObjects.healthBlobs[r] and gameObjects.healthBlobs[r][c] then
        love.graphics.setColor(GameConfig.COLORS.ITEMS.HEALTH_BLOB)
        love.graphics.circle("fill", centerX, centerY, cellSize / 5)
        -- Add cross
        love.graphics.setColor(GameConfig.COLORS.ITEMS.HEALTH_CROSS)
        love.graphics.rectangle("fill", centerX - 1, centerY - 3, 2, 6)
        love.graphics.rectangle("fill", centerX - 3, centerY - 1, 6, 2)
    end
    
    -- Draw immunity blob
    if gameObjects.immunityBlobs[r] and gameObjects.immunityBlobs[r][c] then
        love.graphics.setColor(GameConfig.COLORS.ITEMS.IMMUNITY_BLOB)
        love.graphics.circle("fill", centerX, centerY, cellSize / 5)
        -- Add shield
        love.graphics.setColor(GameConfig.COLORS.ITEMS.IMMUNITY_SHIELD)
        love.graphics.rectangle("fill", centerX - 2, centerY - 4, 4, 6)
        love.graphics.rectangle("fill", centerX - 1, centerY - 5, 2, 2)
    end
end

function Rendering._drawEnemies(enemies, cellSize, offsetX, offsetY)
    local ShaderManager = require("src.shaders.shader_manager")
    local LevelManager = require("src.core.level_manager")
    
    -- Get current level theme
    local currentLevel = LevelManager.getCurrentLevel()
    local themeType = 0  -- Default to Forest (0)
    
    -- Map level number to theme type (subtract 1 to get 0-based index)
    if currentLevel == 1 then  -- FOREST
        themeType = 0
    elseif currentLevel == 2 then  -- CAVE
        themeType = 1
    elseif currentLevel == 3 then  -- VOID
        themeType = 2
    elseif currentLevel == 4 then  -- ABYSS
        themeType = 3
    end
    
    -- Theme mapping complete
    
    -- Handle 2D array structure
    for r = 1, #enemies do
        for c = 1, #enemies[r] do
            if enemies[r][c] then
                local enemy = enemies[r][c]
                -- Use animated position for smooth movement
                local animR = enemy.animR or enemy.r
                local animC = enemy.animC or enemy.c
                local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, animR, animC)
                local time = love.timer.getTime()
                
                -- Apply theme-based sparky shader for enemies
                local enemyColor = {1, 0.2, 0.8}  -- Base purple/magenta
                ShaderManager.applyEnemyRetroWave(enemyColor, themeType)
                
                -- Draw enemy with full block coverage
                love.graphics.setColor(GameConfig.COLORS.ENEMY.BORDER)
                love.graphics.rectangle("fill", x, y, cellSize, cellSize)
                
                -- Draw enemy inner with sparky effect
                love.graphics.setColor(GameConfig.COLORS.ENEMY.INNER)
                love.graphics.rectangle("fill", x + 1, y + 1, cellSize - 2, cellSize - 2)
                
                -- Get theme-based colors (matching shader)
                local themeColors = {
                    GameConfig.COLORS.ENEMY.THEME_FOREST,
                    GameConfig.COLORS.ENEMY.THEME_CAVE,
                    GameConfig.COLORS.ENEMY.THEME_VOID,
                    GameConfig.COLORS.ENEMY.THEME_ABYSS
                }
                local themeColor = themeColors[themeType + 1] or {1, 0.2, 0.8}
                
                -- Draw multiple theme-based sparky layers
                local sparkPulse1 = 0.7 + 0.3 * math.sin(time * 15.0)
                local sparkPulse2 = 0.6 + 0.4 * math.sin(time * 22.0)
                local sparkPulse3 = 0.8 + 0.2 * math.sin(time * 8.0)
                
                -- Layer 1: Main theme sparky effect
                love.graphics.setColor(themeColor[1], themeColor[2], themeColor[3], sparkPulse1 * 0.8)
                love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize - 4)
                
                -- Layer 2: Secondary theme sparky effect
                love.graphics.setColor(themeColor[1] * 1.2, themeColor[2] * 1.2, themeColor[3] * 1.2, sparkPulse2 * 0.6)
                love.graphics.rectangle("fill", x + 3, y + 3, cellSize - 6, cellSize - 6)
                
                -- Layer 3: Core theme sparky effect
                love.graphics.setColor(themeColor[1] * 1.4, themeColor[2] * 1.4, themeColor[3] * 1.4, sparkPulse3 * 0.9)
                love.graphics.rectangle("fill", x + 4, y + 4, cellSize - 8, cellSize - 8)
                
                -- Draw theme-based electric spark center
                local centerX = x + cellSize / 2
                local centerY = y + cellSize / 2
                local sparkSize = cellSize * 0.2 * sparkPulse1
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.circle("fill", centerX, centerY, sparkSize)
                
                -- Draw additional theme-based spark dots
                local sparkOffset1 = math.sin(time * 12.0 + r + c) * 3
                local sparkOffset2 = math.cos(time * 8.0 + r + c) * 2
                love.graphics.setColor(themeColor[1], themeColor[2], themeColor[3], 0.8)
                love.graphics.circle("fill", centerX + sparkOffset1, centerY + sparkOffset2, sparkSize * 0.5)
                love.graphics.circle("fill", centerX - sparkOffset2, centerY - sparkOffset1, sparkSize * 0.3)
                
                -- Draw theme-based aggressive sparky border
                love.graphics.setColor(themeColor[1], themeColor[2], themeColor[3], 0.9)
                love.graphics.setLineWidth(3)
                local waveOffset1 = math.sin(time * 6.0 + r + c) * 4
                local waveOffset2 = math.cos(time * 4.0 + r + c) * 3
                love.graphics.rectangle("line", x + waveOffset1, y + waveOffset2, cellSize, cellSize)
                
                -- Draw secondary theme-based sparky border
                love.graphics.setColor(themeColor[1] * 1.2, themeColor[2] * 1.2, themeColor[3] * 1.2, 0.7)
                love.graphics.setLineWidth(2)
                local waveOffset3 = math.sin(time * 8.0 + r + c) * 2
                local waveOffset4 = math.cos(time * 5.0 + r + c) * 2
                love.graphics.rectangle("line", x + waveOffset3, y + waveOffset4, cellSize - 2, cellSize - 2)
                
                -- Clear enemy shader
                ShaderManager.clearEnemyShader()
            end
        end
    end
end

function Rendering._drawPlayer(playerData, cellSize, offsetX, offsetY)
    local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, playerData.r, playerData.c)
    local time = love.timer.getTime()
    
    -- Draw pulsing outer glow
    local pulse = 0.8 + 0.2 * math.sin(time * 4)
    if playerData.immune then
        love.graphics.setColor(GameConfig.COLORS.PLAYER.GLOW_YELLOW[1], GameConfig.COLORS.PLAYER.GLOW_YELLOW[2], GameConfig.COLORS.PLAYER.GLOW_YELLOW[3], GameConfig.COLORS.PLAYER.GLOW_YELLOW[4] * pulse)
    else
        love.graphics.setColor(GameConfig.COLORS.PLAYER.GLOW_BLUE[1], GameConfig.COLORS.PLAYER.GLOW_BLUE[2], GameConfig.COLORS.PLAYER.GLOW_BLUE[3], GameConfig.COLORS.PLAYER.GLOW_BLUE[4] * pulse)
    end
    love.graphics.rectangle("fill", x - 3, y - 3, cellSize + 6, cellSize + 6)
    
    -- Draw outer border with highlight
    if playerData.immune then
        love.graphics.setColor(GameConfig.COLORS.PLAYER.IMMUNE_BORDER)
    else
        love.graphics.setColor(GameConfig.COLORS.PLAYER.BORDER)
    end
    love.graphics.rectangle("fill", x, y, cellSize, cellSize)
    
    -- Draw border highlight
    love.graphics.setColor(GameConfig.COLORS.UI.HIGHLIGHT)
    love.graphics.rectangle("fill", x + 1, y + 1, cellSize - 2, 2)
    love.graphics.rectangle("fill", x + 1, y + 1, 2, cellSize - 2)
    
    -- Draw player inner with gradient effect
    if playerData.immune then
        love.graphics.setColor(GameConfig.COLORS.PLAYER.IMMUNE_INNER)
    else
        love.graphics.setColor(GameConfig.COLORS.PLAYER.INNER)
    end
    love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize - 4)
    
    -- Draw inner highlight
    love.graphics.setColor(GameConfig.COLORS.UI.HIGHLIGHT[1], GameConfig.COLORS.UI.HIGHLIGHT[2], GameConfig.COLORS.UI.HIGHLIGHT[3], 0.3)
    love.graphics.rectangle("fill", x + 3, y + 3, cellSize - 6, 2)
    love.graphics.rectangle("fill", x + 3, y + 3, 2, cellSize - 6)
    
    -- Draw center dot for better visibility
    local centerX = x + cellSize / 2
    local centerY = y + cellSize / 2
    local dotSize = cellSize * 0.2
    
    if playerData.immune then
        love.graphics.setColor(GameConfig.COLORS.PLAYER.IMMUNE_DOT)
    else
        love.graphics.setColor(GameConfig.COLORS.PLAYER.CENTER_DOT)
    end
    love.graphics.circle("fill", centerX, centerY, dotSize)
    
    -- Draw immunity glow effect
    if playerData.immune then
        love.graphics.setColor(GameConfig.COLORS.PARTICLES.IMMUNITY_GLOW)
        love.graphics.rectangle("fill", x - 2, y - 2, cellSize + 4, cellSize + 4)
        
        -- Draw pulsing immunity ring
        love.graphics.setColor(GameConfig.COLORS.PLAYER.IMMUNE_DOT[1], GameConfig.COLORS.PLAYER.IMMUNE_DOT[2], GameConfig.COLORS.PLAYER.IMMUNE_DOT[3], 0.6 * pulse)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x - 1, y - 1, cellSize + 2, cellSize + 2)
    end
end

function Rendering._drawEffects(animationData, screenWidth, screenHeight)
    -- Draw hit flash
    if animationData.hitFlashTimer > 0 then
        local alpha = animationData.hitFlashTimer / GameConfig.HIT_FLASH_DURATION
        love.graphics.setColor(GameConfig.COLORS.PARTICLES.HIT_FLASH[1], GameConfig.COLORS.PARTICLES.HIT_FLASH[2], 
                             GameConfig.COLORS.PARTICLES.HIT_FLASH[3], GameConfig.COLORS.PARTICLES.HIT_FLASH[4] * alpha)
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    end
    
    -- Draw particles
    for _, particle in ipairs(animationData.collectParticles) do
        local alpha = particle.life / particle.maxLife
        if particle.color == "green" then
            love.graphics.setColor(GameConfig.COLORS.PARTICLES.GREEN[1], GameConfig.COLORS.PARTICLES.GREEN[2], 
                                 GameConfig.COLORS.PARTICLES.GREEN[3], GameConfig.COLORS.PARTICLES.GREEN[4] * alpha)
        elseif particle.color == "red" then
            love.graphics.setColor(GameConfig.COLORS.PARTICLES.RED[1], GameConfig.COLORS.PARTICLES.RED[2], 
                                 GameConfig.COLORS.PARTICLES.RED[3], GameConfig.COLORS.PARTICLES.RED[4] * alpha)
        else
            love.graphics.setColor(GameConfig.COLORS.PARTICLES.YELLOW[1], GameConfig.COLORS.PARTICLES.YELLOW[2], 
                                 GameConfig.COLORS.PARTICLES.YELLOW[3], GameConfig.COLORS.PARTICLES.YELLOW[4] * alpha)
        end
        love.graphics.circle("fill", particle.x, particle.y, particle.size * alpha)
    end
end

function Rendering._drawButton(button, text, fontSize)
    -- Draw button background
    if button.hovered then
        love.graphics.setColor(0.3, 0.3, 0.3, 0.9)
    else
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    end
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
    
    -- Draw button border
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
    
    -- Draw button text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(fontSize))
    local textWidth = love.graphics.getFont():getWidth(text)
    local textHeight = love.graphics.getFont():getHeight()
    love.graphics.print(text, 
        button.x + (button.width - textWidth) / 2,
        button.y + (button.height - textHeight) / 2)
end

function Rendering._drawHealthBar(health, maxHealth, x, y)
    local barWidth = GameConfig.HEALTH_BAR_WIDTH
    local barHeight = GameConfig.HEALTH_BAR_HEIGHT
    
    -- Health bar background with inner shadow
    love.graphics.setColor(GameConfig.COLORS.HEALTH.BACKGROUND)
    love.graphics.rectangle("fill", x, y, barWidth, barHeight)
    
    love.graphics.setColor(GameConfig.COLORS.HEALTH.BACKGROUND[1] * 0.8, GameConfig.COLORS.HEALTH.BACKGROUND[2] * 0.8, GameConfig.COLORS.HEALTH.BACKGROUND[3] * 0.8, 1)
    love.graphics.rectangle("fill", x + 1, y + 1, barWidth - 2, barHeight - 2)
    
    -- Health bar fill with gradient
    local healthPercent = health / maxHealth
    local healthWidth = (barWidth - 2) * healthPercent
    
    if healthWidth > 0 then
        -- Gradient from red to yellow to green
        if healthPercent > 0.6 then
            -- Green to yellow
            local greenAmount = (healthPercent - 0.6) / 0.4
            love.graphics.setColor(1 - greenAmount, 1, 0, 1)
        elseif healthPercent > 0.3 then
            -- Yellow to orange
            local yellowAmount = (healthPercent - 0.3) / 0.3
            love.graphics.setColor(1, 1 - yellowAmount * 0.5, 0, 1)
        else
            -- Red to orange
            local redAmount = healthPercent / 0.3
            love.graphics.setColor(1, redAmount * 0.5, 0, 1)
        end
        
        love.graphics.rectangle("fill", x + 1, y + 1, healthWidth, barHeight - 2)
        
        -- Health bar highlight
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle("fill", x + 1, y + 1, healthWidth, 2)
    end
    
    -- Health bar border with double border effect
    love.graphics.setColor(GameConfig.COLORS.UI.SHADOW)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, barWidth, barHeight)
    
    love.graphics.setColor(GameConfig.COLORS.HEALTH.BORDER)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 1, y + 1, barWidth - 2, barHeight - 2)
end

function Rendering._drawFeatureBox(x, y, width, height, text, colors)
    -- Box background with gradient
    love.graphics.setColor(colors.ui_background[1], colors.ui_background[2], colors.ui_background[3], 0.8)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Inner highlight
    love.graphics.setColor(1, 1, 1, 0.1)
    love.graphics.rectangle("fill", x + 2, y + 2, width - 4, height - 4)
    
    -- Box border
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.4)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Inner border
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.2)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 2, y + 2, width - 4, height - 4)
    
    -- Text
    love.graphics.setColor(colors.ui_text)
    love.graphics.setFont(love.graphics.newFont(18))
    local textWidth = love.graphics.getFont():getWidth(text)
    local textHeight = love.graphics.getFont():getHeight()
    love.graphics.print(text, 
        x + (width - textWidth) / 2,
        y + (height - textHeight) / 2)
end

function Rendering._drawEnhancedButton(button, text, fontSize, colors)
    -- Button shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", button.x + 3, button.y + 3, button.width, button.height)
    
    -- Button background with gradient
    if button.hovered then
        love.graphics.setColor(0.4, 0.4, 0.4, 0.9)
    else
        love.graphics.setColor(0.3, 0.3, 0.3, 0.9)
    end
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
    
    -- Button highlight
    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.rectangle("fill", button.x + 2, button.y + 2, button.width - 4, button.height - 4)
    
    -- Button border
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
    
    -- Inner border
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", button.x + 3, button.y + 3, button.width - 6, button.height - 6)
    
    -- Button text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(fontSize))
    local textWidth = love.graphics.getFont():getWidth(text)
    local textHeight = love.graphics.getFont():getHeight()
    love.graphics.print(text, 
        button.x + (button.width - textWidth) / 2,
        button.y + (button.height - textHeight) / 2)
end

-- Draw poison enemies
function Rendering._drawPoisonEnemies(poisonEnemies, cellSize, offsetX, offsetY)
    if not poisonEnemies then
        return
    end
    
    for _, enemy in ipairs(poisonEnemies) do
        -- Use animated position for smooth movement
        local animR = enemy.animR or enemy.r
        local animC = enemy.animC or enemy.c
        local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, animR, animC)
        
        -- Draw poison enemy with pulsing effect
        local pulse = 0.8 + 0.2 * math.sin(love.timer.getTime() * 4)
        
        -- Outer glow (bright purple)
        love.graphics.setColor(0.8, 0.2, 0.8, 0.9 * pulse)
        love.graphics.rectangle("fill", x - 10, y - 10, cellSize + 20, cellSize + 20)
        
        -- Main body (bright purple)
        love.graphics.setColor(0.8, 0.2, 0.8, 1)
        love.graphics.rectangle("fill", x - 2, y - 2, cellSize + 4, cellSize + 4)
        
        -- Center dot (bright yellow)
        love.graphics.setColor(1, 1, 0, 1)
        local centerX, centerY = x + cellSize/2, y + cellSize/2
        love.graphics.circle("fill", centerX, centerY, 8)
        
        -- Border for visibility (black)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x - 2, y - 2, cellSize + 4, cellSize + 4)
        love.graphics.setLineWidth(1)
    end
end

-- Draw splash enemies
function Rendering._drawSplashEnemies(splashEnemies, cellSize, offsetX, offsetY)
    if not splashEnemies then
        return
    end
    
    for _, enemy in ipairs(splashEnemies) do
        -- Use animated position for smooth movement
        local animR = enemy.animR or enemy.r
        local animC = enemy.animC or enemy.c
        local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, animR, animC)
        
        -- Get animation data
        local animData = SplashEnemy.getAnimationData(enemy)
        local jumpOffset = 0
        local flashIntensity = 0
        
        -- Apply jump animation
        if animData.phase == 1 then
            local jumpProgress = animData.timer / 0.2
            jumpOffset = math.sin(jumpProgress * math.pi) * 15
        end
        
        -- Apply flash effect
        if animData.phase == 2 then
            flashIntensity = math.sin(animData.timer * 20) * 0.5 + 0.5
        end
        
        -- Adjust position for jump
        y = y - jumpOffset
        
        -- Base fire colors - brighter and more intense
        local baseColor = {1.0, 0.5, 0.0}  -- Bright orange
        local fireColor = {1.0, 0.8, 0.0}  -- Golden orange
        
        if animData.isSplashing then
            -- Fire effect during splash
            local time = love.timer.getTime()
            local pulse = 0.8 + 0.2 * math.sin(time * 6)
            
            -- Outer fire glow - brighter
            love.graphics.setColor(1.0, 0.6, 0.0, 0.8 * pulse)
            love.graphics.rectangle("fill", x - 10, y - 10, cellSize + 20, cellSize + 20)
            
            -- Middle fire layer
            love.graphics.setColor(1.0, 0.7, 0.0, 0.9 * pulse)
            love.graphics.rectangle("fill", x - 6, y - 6, cellSize + 12, cellSize + 12)
            
            -- Main fire body - brighter
            love.graphics.setColor(fireColor[1], fireColor[2], fireColor[3], 1)
            love.graphics.rectangle("fill", x - 2, y - 2, cellSize + 4, cellSize + 4)
            
            -- Flash effect - more intense
            if flashIntensity > 0 then
                love.graphics.setColor(1, 1, 0.3, flashIntensity * 0.9)
                love.graphics.rectangle("fill", x - 2, y - 2, cellSize + 4, cellSize + 4)
                -- Add white flash
                love.graphics.setColor(1, 1, 1, flashIntensity * 0.4)
                love.graphics.rectangle("fill", x - 1, y - 1, cellSize + 2, cellSize + 2)
            end
            
            -- Center fire core - brighter
            love.graphics.setColor(1, 1, 0.2, 1)
            local centerX, centerY = x + cellSize/2, y + cellSize/2
            love.graphics.circle("fill", centerX, centerY, 7)
            
            -- Inner white-hot core
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.circle("fill", centerX, centerY, 3)
        else
            -- Normal state - brighter with subtle glow
            -- Outer glow
            love.graphics.setColor(baseColor[1], baseColor[2], baseColor[3], 0.3)
            love.graphics.rectangle("fill", x - 4, y - 4, cellSize + 8, cellSize + 8)
            
            -- Main body
            love.graphics.setColor(baseColor[1], baseColor[2], baseColor[3], 1)
            love.graphics.rectangle("fill", x - 2, y - 2, cellSize + 4, cellSize + 4)
            
            -- Center dot - brighter
            love.graphics.setColor(1, 0.9, 0, 1)
            local centerX, centerY = x + cellSize/2, y + cellSize/2
            love.graphics.circle("fill", centerX, centerY, 5)
            
            -- Inner bright core
            love.graphics.setColor(1, 1, 0.3, 1)
            love.graphics.circle("fill", centerX, centerY, 2)
        end
        
        -- Border for visibility
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x - 2, y - 2, cellSize + 4, cellSize + 4)
        love.graphics.setLineWidth(1)
    end
end

-- Draw splash tiles
function Rendering._drawSplashTiles(splashTiles, cellSize, offsetX, offsetY)
    if not splashTiles then
        return
    end
    
    for r = 1, GameConfig.MAZE_ROWS do
        if splashTiles[r] then
            for c = 1, GameConfig.MAZE_COLS do
                if splashTiles[r][c] then
                    local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, r, c)
                    local splashTile = splashTiles[r][c]
                    
                    -- Calculate intensity based on remaining time
                    local intensity = splashTile.timer / 2.0  -- 2 seconds duration
                    local alpha = 0.3 + 0.7 * intensity
                    
                    -- Enhanced fire effect with pulsing
                    local time = love.timer.getTime()
                    local pulse = 0.8 + 0.2 * math.sin(time * 10)
                    
                    -- Outer fire glow - brighter
                    love.graphics.setColor(1.0, 0.5, 0.0, alpha * 0.6 * pulse)
                    love.graphics.rectangle("fill", x - 6, y - 6, cellSize + 12, cellSize + 12)
                    
                    -- Middle fire layer
                    love.graphics.setColor(1.0, 0.7, 0.0, alpha * 0.8 * pulse)
                    love.graphics.rectangle("fill", x - 2, y - 2, cellSize + 4, cellSize + 4)
                    
                    -- Main fire - brighter
                    love.graphics.setColor(1.0, 0.8, 0.0, alpha * pulse)
                    love.graphics.rectangle("fill", x, y, cellSize, cellSize)
                    
                    -- Bright center - more intense
                    love.graphics.setColor(1.0, 1.0, 0.2, alpha)
                    love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize - 4)
                    
                    -- Inner white-hot core
                    love.graphics.setColor(1.0, 1.0, 1.0, alpha * 0.6)
                    love.graphics.rectangle("fill", x + 6, y + 6, cellSize - 12, cellSize - 12)
                end
            end
        end
    end
end

-- Draw poison tiles
function Rendering._drawPoisonTiles(poisonTiles, cellSize, offsetX, offsetY)
    if not poisonTiles then
        return
    end
    
    for r = 1, GameConfig.MAZE_ROWS do
        if poisonTiles[r] then
            for c = 1, GameConfig.MAZE_COLS do
                if poisonTiles[r][c] then
                    local poisonTile = poisonTiles[r][c]
                    local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, r, c)
                    
                    -- Calculate fade based on remaining time
                    local fade = poisonTile.timer / GameConfig.POISON_TILE_DURATION
                    local alpha = 0.6 + 0.4 * fade  -- More visible
                    
                    -- Draw poison tile with pulsing effect
                    local pulse = 0.8 + 0.2 * math.sin(love.timer.getTime() * 8)
                    
                    -- Draw poison tile (bright pink/magenta)
                    love.graphics.setColor(1, 0.4, 1, alpha * pulse)
                    love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize - 4)
                    
                    -- Draw poison symbol (skull) - more visible
                    love.graphics.setColor(1, 1, 1, alpha * 0.9)
                    local centerX, centerY = x + cellSize/2, y + cellSize/2
                    love.graphics.circle("fill", centerX, centerY - 3, 3)
                    love.graphics.circle("fill", centerX - 3, centerY + 2, 2)
                    love.graphics.circle("fill", centerX + 3, centerY + 2, 2)
                    
                    -- Draw border for visibility
                    love.graphics.setColor(0, 0, 0, alpha * 0.5)
                    love.graphics.rectangle("line", x + 2, y + 2, cellSize - 4, cellSize - 4)
                end
            end
        end
    end
end

return Rendering
