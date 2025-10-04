-- Rendering system for maze, UI, particles, and effects
local Rendering = {}
local GameConfig = require("src.config.game_config")
local LevelConfig = require("src.config.level_config")
local LevelManager = require("src.core.level_manager")
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
    love.graphics.printf("💛 Collect yellow blobs to unlock the exit", 0, textY, screenWidth, "center")
    
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
    
    -- Draw blob enemies
    Rendering._drawBlobEnemies(gameObjects.blobEnemies, cellSize, offsetX, offsetY)
    
    -- Draw lightning enemies
    Rendering._drawLightningEnemies(gameObjects.lightningEnemies, cellSize, offsetX, offsetY)
    
    -- Draw moveable crates
    Rendering._drawMoveableCrates(gameObjects.moveableCrates, cellSize, offsetX, offsetY)
    
    -- Draw grey orbs
    Rendering._drawGreyOrbs(gameObjects.greyOrbs, cellSize, offsetX, offsetY)
    
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
    local currentTheme = LevelManager.getCurrentLevel()
    local requiredScore = LevelConfig.getRequiredScore(currentTheme)
    love.graphics.print("Blobs: " .. playerData.score .. "/" .. requiredScore, boxX + 20, startY + lineHeight)
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
    
    -- Draw speed boost timer below health bar
    local speedBoostData = GameState.getSpeedBoostData()
    if speedBoostData.active then
        local speedBoostY = healthBarY + GameConfig.HEALTH_BAR_HEIGHT + 10  -- 10px spacing below health bar
        Rendering._drawSpeedBoostTimer(speedBoostData.timer, speedBoostData.multiplier, boxX + 20, speedBoostY)
    end
    
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

function Rendering.drawInventory(screenWidth, screenHeight, inventory, colors)
    -- Define grid dimensions
    local gridCols = 4
    local gridRows = 8
    local slotSize = 30
    local slotSpacing = 8
    local padding = 10
    local titleHeight = 25
    
    -- Calculate box dimensions based on slot layout
    local totalSlotWidth = (gridCols * slotSize) + ((gridCols - 1) * slotSpacing)
    local totalSlotHeight = (gridRows * slotSize) + ((gridRows - 1) * slotSpacing)
    
    local boxWidth = totalSlotWidth + (padding * 2)
    local boxHeight = totalSlotHeight + (padding * 2) + titleHeight
    
    local boxX = screenWidth - boxWidth - 20
    local boxY = screenHeight - boxHeight - 20
    
    -- Draw background box
    love.graphics.setColor(0.1, 0.1, 0.2, 0.9)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)
    
    -- Draw border
    love.graphics.setColor(colors.ui_border or {0.5, 0.5, 0.7, 1})
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight)
    
    -- Draw title
    love.graphics.setColor(colors.ui_text or {1, 1, 1, 1})
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Inventory", boxX + padding, boxY + padding)
    
    -- Draw inventory slots in 4x8 grid
    local startX = boxX + padding
    local startY = boxY + padding + titleHeight
    
    for row = 0, 7 do
        for col = 0, 3 do
            local slotIndex = row * 4 + col + 1
            local slotX = startX + col * (slotSize + slotSpacing)
            local slotY = startY + row * (slotSize + slotSpacing)
            
            -- Draw slot background
            love.graphics.setColor(0.2, 0.2, 0.3, 1)
            love.graphics.rectangle("fill", slotX, slotY, slotSize, slotSize)
            
            -- Draw slot border
            love.graphics.setColor(0.4, 0.4, 0.5, 1)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", slotX, slotY, slotSize, slotSize)
            
            -- Draw item in slot
            local slotKey = "slot" .. slotIndex
            local item = inventory[slotKey]
            if item then
                local centerX = slotX + slotSize / 2
                local centerY = slotY + slotSize / 2
                local orbRadius = slotSize * 0.3
                
                if item.type == "grey_orb" then
                    -- Draw grey orb with same style as in-game
                    -- Draw orb shadow
                    love.graphics.setColor(0.2, 0.2, 0.2, 0.6)
                    love.graphics.circle("fill", centerX + 1, centerY + 1, orbRadius)
                    
                    -- Draw main orb body (grey)
                    love.graphics.setColor(0.6, 0.6, 0.6, 1)
                    love.graphics.circle("fill", centerX, centerY, orbRadius)
                    
                    -- Draw orb highlight
                    love.graphics.setColor(0.8, 0.8, 0.8, 1)
                    love.graphics.circle("fill", centerX - orbRadius * 0.3, centerY - orbRadius * 0.3, orbRadius * 0.5)
                    
                    -- Draw orb border
                    love.graphics.setColor(0.4, 0.4, 0.4, 1)
                    love.graphics.setLineWidth(1)
                    love.graphics.circle("line", centerX, centerY, orbRadius)
                else
                    -- Draw generic item icon for other item types
                    love.graphics.setColor(0.6, 0.6, 0.6, 1)
                    love.graphics.setFont(love.graphics.newFont(16))
                    love.graphics.print(item.icon or "?", centerX - 4, centerY - 8)
                end
            else
                -- Draw empty slot indicator
                love.graphics.setColor(0.3, 0.3, 0.4, 0.5)
                love.graphics.setFont(love.graphics.newFont(12))
                love.graphics.print("-", slotX + slotSize/2 - 2, slotY + slotSize/2 - 4)
            end
        end
    end
    
    love.graphics.setLineWidth(1)
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
    local MultiTierGenerator = require("src.world.multi_tier_generator")
    
    for r = 1, rows do
        for c = 1, cols do
            local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, r, c)
            local isHovered = Helpers.isMouseHovering(mouseX, mouseY, x, y, cellSize, cellSize)
            
            -- Get floor level for this tile
            local floorLevel = MultiTierGenerator.getFloorLevel(r, c, gameObjects.elevatedZones or {})
            
            if maze[r][c] then
                Rendering._drawWallTile(maze[r][c], x, y, cellSize, isHovered, colors, floorLevel)
            else
                Rendering._drawWalkableTile(x, y, cellSize, isHovered, gameObjects, r, c, colors, floorLevel)
            end
        end
    end
end

function Rendering._drawWallTile(tileType, x, y, cellSize, isHovered, colors, floorLevel)
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

function Rendering._drawWalkableTile(x, y, cellSize, isHovered, gameObjects, r, c, colors, floorLevel)
    -- Adjust colors for elevated zones (much more distinct)
    local isElevated = floorLevel == GameConfig.FLOOR_LEVELS.ELEVATED
    local isRamp = floorLevel == "ramp"
    
    -- Draw subtle shadow for elevated tiles
    if isElevated then
        love.graphics.setColor(0, 0, 0, 0.25)
        love.graphics.rectangle("fill", x + 2, y + 2, cellSize, cellSize)
    end
    
    -- Draw border with elevation color adjustment
    if isHovered then
        love.graphics.setColor(colors.walkable_hover_border)
    else
        if isElevated then
            -- Subtle lighter shade for elevated zones (warmer tint)
            love.graphics.setColor(
                math.min(1, colors.walkable_border[1] * 1.4 + 0.1),
                math.min(1, colors.walkable_border[2] * 1.35 + 0.08),
                math.min(1, colors.walkable_border[3] * 1.3 + 0.05),
                colors.walkable_border[4]
            )
        elseif isRamp then
            -- Gold/yellow for ramps
            love.graphics.setColor(0.85, 0.75, 0.3, 1)
        else
            love.graphics.setColor(colors.walkable_border)
        end
    end
    love.graphics.rectangle("fill", x, y, cellSize, cellSize)
    
    -- Draw inner with elevation color adjustment
    if isHovered then
        love.graphics.setColor(colors.walkable_hover_inner)
    else
        if isElevated then
            -- Subtle lighter inner for elevated zones (warm tint)
            love.graphics.setColor(
                math.min(1, colors.walkable_inner[1] * 1.35 + 0.08),
                math.min(1, colors.walkable_inner[2] * 1.3 + 0.06),
                math.min(1, colors.walkable_inner[3] * 1.25 + 0.04),
                colors.walkable_inner[4]
            )
        elseif isRamp then
            -- Gold inner for ramps
            love.graphics.setColor(0.75, 0.65, 0.25, 1)
        else
            love.graphics.setColor(colors.walkable_inner)
        end
    end
    love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize - 4)
    
    -- Draw simple ramp indicator
    if isRamp then
        local centerX, centerY = x + cellSize/2, y + cellSize/2
        
        -- Draw simple up/down arrows
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.setLineWidth(2)
        
        -- Up arrow (triangle)
        love.graphics.polygon("fill", 
            centerX, centerY - 6,
            centerX - 4, centerY - 2,
            centerX + 4, centerY - 2
        )
        
        -- Down arrow (triangle)
        love.graphics.polygon("fill", 
            centerX, centerY + 6,
            centerX - 4, centerY + 2,
            centerX + 4, centerY + 2
        )
        
        love.graphics.setLineWidth(1)
    end
    
    -- Draw items
    Rendering._drawTileItems(x, y, cellSize, gameObjects, r, c)
end

function Rendering._drawTileItems(x, y, cellSize, gameObjects, r, c)
    local centerX = x + cellSize / 2
    local centerY = y + cellSize / 2
    
    -- Draw collectible as gold coin with enhanced visibility and animation
    if gameObjects.collectibles[r] and gameObjects.collectibles[r][c] then
        local time = love.timer.getTime()
        local pulse = 0.6 + 0.4 * math.sin(time * 4 + r + c)
        local glowPulse = 0.3 + 0.7 * math.sin(time * 6 + r * 2 + c * 2)
        local float = math.sin(time * 3 + r + c) * 2
        local coinSize = cellSize / 4
        
        -- Draw outer glow effect (golden)
        love.graphics.setColor(1, 1, 0, 0.5 * glowPulse)
        love.graphics.circle("fill", centerX, centerY + float, coinSize)
        
        -- Draw main coin body (golden)
        love.graphics.setColor(1, 0.8, 0, pulse)
        love.graphics.circle("fill", centerX, centerY + float, coinSize * 0.8)
        
        -- Draw coin inner circle (darker gold)
        love.graphics.setColor(0.9, 0.7, 0, pulse)
        love.graphics.circle("fill", centerX, centerY + float, coinSize * 0.6)
        
        -- Draw coin center (bright gold)
        love.graphics.setColor(1, 1, 0.6, 0.9)
        love.graphics.circle("fill", centerX, centerY + float, coinSize * 0.4)
        
        -- Draw coin edge highlight
        love.graphics.setColor(1, 1, 0.8, 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", centerX, centerY + float, coinSize * 0.8)
        love.graphics.setLineWidth(1)
        
        -- Draw coin symbol ($)
        love.graphics.setColor(0.6, 0.4, 0, 1)
        love.graphics.setFont(love.graphics.newFont(coinSize * 0.6))
        love.graphics.printf("$", centerX - coinSize * 0.3, centerY - coinSize * 0.2 + float, coinSize * 0.6, "center")
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
    
    -- Draw health blob with enhanced visibility and animation
    if gameObjects.healthBlobs[r] and gameObjects.healthBlobs[r][c] then
        local time = love.timer.getTime()
        local pulse = 0.7 + 0.3 * math.sin(time * 6 + r + c)
        local glowPulse = 0.4 + 0.6 * math.sin(time * 8 + r * 2 + c * 2)
        
        -- Draw outer glow effect (larger and more prominent)
        love.graphics.setColor(0, 1, 0, 0.5 * glowPulse)
        love.graphics.circle("fill", centerX, centerY, cellSize / 2.5)
        
        -- Draw main health blob with pulsing effect (larger)
        love.graphics.setColor(GameConfig.COLORS.ITEMS.HEALTH_BLOB[1], GameConfig.COLORS.ITEMS.HEALTH_BLOB[2], GameConfig.COLORS.ITEMS.HEALTH_BLOB[3], pulse)
        love.graphics.circle("fill", centerX, centerY, cellSize / 4)
        
        -- Draw inner highlight (larger)
        love.graphics.setColor(0.8, 1, 0.8, 0.8)
        love.graphics.circle("fill", centerX - 2, centerY - 2, cellSize / 6)
        
        -- Add enhanced cross with glow (larger)
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.rectangle("fill", centerX - 1, centerY - 5, 2, 10)
        love.graphics.rectangle("fill", centerX - 5, centerY - 1, 10, 2)
        
        -- Add cross outline for better visibility (larger)
        love.graphics.setColor(0, 0.8, 0, 1)
        love.graphics.rectangle("line", centerX - 1, centerY - 5, 2, 10)
        love.graphics.rectangle("line", centerX - 5, centerY - 1, 10, 2)
    end
    
    -- Draw immunity blob with enhanced visibility and animation
    if gameObjects.immunityBlobs[r] and gameObjects.immunityBlobs[r][c] then
        local time = love.timer.getTime()
        local pulse = 0.7 + 0.3 * math.sin(time * 5 + r + c)
        local glowPulse = 0.4 + 0.6 * math.sin(time * 7 + r * 2 + c * 2)
        
        -- Draw outer glow effect (red - larger and more prominent)
        love.graphics.setColor(1, 0, 0, 0.6 * glowPulse)
        love.graphics.circle("fill", centerX, centerY, cellSize / 2.5)
        
        -- Draw main immunity blob with pulsing effect (larger)
        love.graphics.setColor(GameConfig.COLORS.ITEMS.IMMUNITY_BLOB[1], GameConfig.COLORS.ITEMS.IMMUNITY_BLOB[2], GameConfig.COLORS.ITEMS.IMMUNITY_BLOB[3], pulse)
        love.graphics.circle("fill", centerX, centerY, cellSize / 4)
        
        -- Draw inner highlight (larger)
        love.graphics.setColor(1, 0.8, 0.8, 0.8)
        love.graphics.circle("fill", centerX - 2, centerY - 2, cellSize / 6)
        
        -- Add enhanced shield with glow (larger)
        love.graphics.setColor(1, 0, 0, 0.9)
        love.graphics.rectangle("fill", centerX - 3, centerY - 5, 6, 8)
        love.graphics.rectangle("fill", centerX - 2, centerY - 6, 4, 3)
        
        -- Add shield outline for better visibility (larger)
        love.graphics.setColor(0.8, 0, 0, 1)
        love.graphics.rectangle("line", centerX - 3, centerY - 5, 6, 8)
        love.graphics.rectangle("line", centerX - 2, centerY - 6, 4, 3)
    end
    
    -- Draw speed boost orbs
    if gameObjects.speedBoostOrbs then
        for _, orb in ipairs(gameObjects.speedBoostOrbs) do
            if orb.r == r and orb.c == c and not orb.collected then
                local time = love.timer.getTime()
                local pulse = 0.6 + 0.4 * math.sin(time * 4 + r + c)
                local glowPulse = 0.3 + 0.7 * math.sin(time * 6 + r * 2 + c * 2)
                local float = math.sin(time * 3 + r + c) * 2
                
                -- Draw outer glow effect (blue)
                love.graphics.setColor(0, 0.5, 1, 0.6 * glowPulse)
                love.graphics.circle("fill", centerX, centerY + float, cellSize / 3)
                
                -- Draw main speed boost orb with pulsing effect
                love.graphics.setColor(0, 0.7, 1, pulse)
                love.graphics.circle("fill", centerX, centerY + float, cellSize / 5)
                
                -- Draw inner highlight
                love.graphics.setColor(0.8, 0.9, 1, 0.9)
                love.graphics.circle("fill", centerX - 1, centerY - 1 + float, cellSize / 8)
                
                -- Draw speed lines for visual effect
                love.graphics.setColor(0, 0.5, 1, 0.8)
                love.graphics.setLineWidth(2)
                love.graphics.line(centerX - cellSize/6, centerY + float, centerX + cellSize/6, centerY + float)
                love.graphics.line(centerX, centerY - cellSize/6 + float, centerX, centerY + cellSize/6 + float)
                love.graphics.setLineWidth(1)
            end
        end
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
    
    -- Draw outer border with enhanced visibility
    if playerData.immune then
        love.graphics.setColor(GameConfig.COLORS.PLAYER.IMMUNE_BORDER)
    else
        love.graphics.setColor(0.8, 0.1, 0.1, 1)  -- Bright red border
    end
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", x - 2, y - 2, cellSize + 4, cellSize + 4)
    
    -- Draw main player body - bright red
    if playerData.immune then
        love.graphics.setColor(GameConfig.COLORS.PLAYER.IMMUNE_INNER)
    else
        love.graphics.setColor(1, 0.2, 0.2, 1)  -- Bright red body
    end
    love.graphics.rectangle("fill", x, y, cellSize, cellSize)
    
    -- Draw inner border for depth
    love.graphics.setColor(0.6, 0.1, 0.1, 1)  -- Darker red inner border
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x + 2, y + 2, cellSize - 4, cellSize - 4)
    
    -- Draw center cross for better visibility
    local centerX = x + cellSize / 2
    local centerY = y + cellSize / 2
    local crossSize = cellSize * 0.3
    
    love.graphics.setColor(1, 1, 1, 1)  -- White cross
    love.graphics.setLineWidth(3)
    love.graphics.line(centerX - crossSize, centerY, centerX + crossSize, centerY)
    love.graphics.line(centerX, centerY - crossSize, centerX, centerY + crossSize)
    
    -- Draw corner highlights for extra visibility
    love.graphics.setColor(1, 1, 1, 0.8)  -- White corner highlights
    love.graphics.setLineWidth(2)
    local cornerSize = cellSize * 0.2
    love.graphics.line(x + 2, y + 2, x + cornerSize, y + 2)
    love.graphics.line(x + 2, y + 2, x + 2, y + cornerSize)
    love.graphics.line(x + cellSize - 2, y + 2, x + cellSize - cornerSize, y + 2)
    love.graphics.line(x + cellSize - 2, y + 2, x + cellSize - 2, y + cornerSize)
    love.graphics.line(x + 2, y + cellSize - 2, x + cornerSize, y + cellSize - 2)
    love.graphics.line(x + 2, y + cellSize - 2, x + 2, y + cellSize - cornerSize)
    love.graphics.line(x + cellSize - 2, y + cellSize - 2, x + cellSize - cornerSize, y + cellSize - 2)
    love.graphics.line(x + cellSize - 2, y + cellSize - 2, x + cellSize - 2, y + cellSize - cornerSize)
    
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

-- Draw blob enemies
function Rendering._drawBlobEnemies(blobEnemies, cellSize, offsetX, offsetY)
    if not blobEnemies then
        return
    end
    
    print("DEBUG: Drawing " .. #blobEnemies .. " blob enemies")
    
    for _, enemy in ipairs(blobEnemies) do
        -- Use animated position for smooth movement
        local animR = enemy.animR or enemy.r
        local animC = enemy.animC or enemy.c
        local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, animR, animC)
        
        -- Get animation data
        local animData = enemy.getAnimationData and enemy.getAnimationData(enemy) or {}
        local pulse = animData.blobPulse or 1.0
        
        -- Draw 2x2 blob enemy with pulsing effect
        local time = love.timer.getTime()
        local glowPulse = 0.8 + 0.2 * math.sin(time * 3)
        
        -- Outer glow effect (dark gray)
        love.graphics.setColor(0.2, 0.2, 0.2, 0.6 * glowPulse)
        love.graphics.rectangle("fill", x - 2, y - 2, cellSize * 2 + 4, cellSize * 2 + 4)
        
        -- Main blob body (black)
        love.graphics.setColor(0, 0, 0, pulse)
        love.graphics.rectangle("fill", x, y, cellSize * 2, cellSize * 2)
        
        -- Inner highlight (dark gray)
        love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
        love.graphics.rectangle("fill", x + 2, y + 2, cellSize * 2 - 4, cellSize * 2 - 4)
        
        -- Center core (slightly lighter black)
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        local centerX = x + cellSize
        local centerY = y + cellSize
        love.graphics.circle("fill", centerX, centerY, cellSize * 0.3)
        
        -- Border for visibility
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, cellSize * 2, cellSize * 2)
        love.graphics.setLineWidth(1)
    end
end

-- Draw lightning enemies
function Rendering._drawLightningEnemies(lightningEnemies, cellSize, offsetX, offsetY)
    if not lightningEnemies then
        return
    end
    
    print("DEBUG: Drawing " .. #lightningEnemies .. " lightning enemies")
    
    for _, enemy in ipairs(lightningEnemies) do
        -- Use animated position for smooth movement
        local animR = enemy.animR or enemy.r
        local animC = enemy.animC or enemy.c
        local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, animR, animC)
        
        -- Draw lightning enemy with electric effect
        local time = love.timer.getTime()
        local electricPulse = 0.7 + 0.3 * math.sin(time * 8)
        local sparkPulse = 0.5 + 0.5 * math.sin(time * 12)
        
        -- Outer electric glow (light blue)
        love.graphics.setColor(0.3, 0.7, 1, 0.7 * electricPulse)
        love.graphics.rectangle("fill", x - 3, y - 3, cellSize + 6, cellSize + 6)
        
        -- Main body (light blue)
        love.graphics.setColor(0.2, 0.6, 1, electricPulse)
        love.graphics.rectangle("fill", x, y, cellSize, cellSize)
        
        -- Electric spark center
        love.graphics.setColor(1, 1, 1, sparkPulse)
        local centerX = x + cellSize / 2
        local centerY = y + cellSize / 2
        love.graphics.circle("fill", centerX, centerY, cellSize * 0.2)
        
        -- Lightning bolts
        love.graphics.setColor(1, 1, 0.8, 0.9)
        love.graphics.setLineWidth(2)
        -- Draw lightning bolt pattern
        local boltOffset = math.sin(time * 6) * 2
        love.graphics.line(centerX - 5, centerY - 5 + boltOffset, centerX + 5, centerY + 5 - boltOffset)
        love.graphics.line(centerX - 5, centerY + 5 - boltOffset, centerX + 5, centerY - 5 + boltOffset)
        love.graphics.setLineWidth(1)
        
        -- Border for visibility
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, cellSize, cellSize)
        love.graphics.setLineWidth(1)
    end
end

function Rendering._drawSpeedBoostTimer(timer, multiplier, x, y)
    local barWidth = 200
    local barHeight = 25
    local maxDuration = 5.0  -- 5 seconds max duration
    
    -- Speed boost timer background with inner shadow
    love.graphics.setColor(0.1, 0.1, 0.2, 0.9)  -- Dark blue background
    love.graphics.rectangle("fill", x, y, barWidth, barHeight)
    
    love.graphics.setColor(0.05, 0.05, 0.15, 1)  -- Darker inner shadow
    love.graphics.rectangle("fill", x + 1, y + 1, barWidth - 2, barHeight - 2)
    
    -- Speed boost timer fill with blue gradient
    local timePercent = timer / maxDuration
    local timerWidth = (barWidth - 2) * timePercent
    
    if timerWidth > 0 then
        -- Blue gradient from light to dark
        local blueIntensity = 0.3 + (timePercent * 0.7)  -- 0.3 to 1.0
        love.graphics.setColor(0, 0.5 * blueIntensity, 1 * blueIntensity, 1)
        love.graphics.rectangle("fill", x + 1, y + 1, timerWidth, barHeight - 2)
        
        -- Speed boost timer highlight
        love.graphics.setColor(0.8, 0.9, 1, 0.4)
        love.graphics.rectangle("fill", x + 1, y + 1, timerWidth, 3)
    end
    
    -- Speed boost timer border with double border effect
    love.graphics.setColor(0, 0, 0, 0.8)  -- Dark border
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, barWidth, barHeight)
    
    love.graphics.setColor(0, 0.7, 1, 1)  -- Blue border
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 1, y + 1, barWidth - 2, barHeight - 2)
    
    -- Speed boost text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    local text = string.format("SPEED BOOST %.1fx - %.1fs", multiplier, timer)
    love.graphics.print(text, x + 5, y + 5)
end

function Rendering._drawMoveableCrates(crates, cellSize, offsetX, offsetY)
    if not crates then
        return
    end
    
    for _, crate in ipairs(crates) do
        local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, crate.r, crate.c)
        local centerX = x + cellSize / 2
        local centerY = y + cellSize / 2
        
        -- Get animation data
        local animData = crate.getAnimationData and crate.getAnimationData(crate) or {}
        local pulse = animData.glowIntensity or 1.0
        
        -- Draw crate shadow
        love.graphics.setColor(0.2, 0.1, 0.1, 0.6)
        love.graphics.rectangle("fill", x + 2, y + 2, cellSize, cellSize)
        
        -- Draw main crate body (brown)
        love.graphics.setColor(0.6, 0.4, 0.2, pulse)
        love.graphics.rectangle("fill", x, y, cellSize, cellSize)
        
        -- Draw crate top (lighter brown)
        love.graphics.setColor(0.7, 0.5, 0.3, pulse)
        love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize / 3)
        
        -- Draw crate sides (darker brown)
        love.graphics.setColor(0.4, 0.3, 0.1, pulse)
        love.graphics.rectangle("fill", x + 2, y + cellSize / 3 + 2, cellSize / 6, cellSize * 2 / 3 - 4)
        love.graphics.rectangle("fill", x + cellSize * 5 / 6 - 2, y + cellSize / 3 + 2, cellSize / 6, cellSize * 2 / 3 - 4)
        
        -- Draw crate front (medium brown)
        love.graphics.setColor(0.5, 0.35, 0.15, pulse)
        love.graphics.rectangle("fill", x + cellSize / 6 + 2, y + cellSize / 3 + 2, cellSize * 2 / 3 - 4, cellSize * 2 / 3 - 4)
        
        -- Draw crate border
        love.graphics.setColor(0.3, 0.2, 0.1, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, cellSize, cellSize)
        love.graphics.setLineWidth(1)
        
        -- Draw crate details (wood grain effect)
        love.graphics.setColor(0.4, 0.3, 0.1, 0.8)
        love.graphics.setLineWidth(1)
        for i = 1, 3 do
            local grainY = y + cellSize / 3 + 2 + (i * cellSize / 6)
            love.graphics.line(x + cellSize / 6 + 2, grainY, x + cellSize * 5 / 6 - 2, grainY)
        end
        love.graphics.setLineWidth(1)
    end
end

function Rendering._drawGreyOrbs(orbs, cellSize, offsetX, offsetY)
    if not orbs then
        return
    end
    
    for _, orb in ipairs(orbs) do
        if not orb.collected then
            local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, orb.r, orb.c)
            local centerX = x + cellSize / 2
            local centerY = y + cellSize / 2
            
            -- Get animation data
            local animData = orb.getAnimationData and orb.getAnimationData(orb) or {}
            local pulse = animData.glowIntensity or 1.0
            
            -- Draw orb shadow
            love.graphics.setColor(0.2, 0.2, 0.2, 0.6)
            love.graphics.circle("fill", centerX + 2, centerY + 2, cellSize * 0.3)
            
            -- Draw main orb body (grey)
            love.graphics.setColor(0.6, 0.6, 0.6, pulse)
            love.graphics.circle("fill", centerX, centerY, cellSize * 0.3)
            
            -- Draw orb highlight
            love.graphics.setColor(0.8, 0.8, 0.8, pulse)
            love.graphics.circle("fill", centerX - cellSize * 0.1, centerY - cellSize * 0.1, cellSize * 0.15)
            
            -- Draw orb border
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
            love.graphics.setLineWidth(2)
            love.graphics.circle("line", centerX, centerY, cellSize * 0.3)
            love.graphics.setLineWidth(1)
        end
    end
end

function Rendering.drawPauseMenu(screenWidth, screenHeight, colors)
    -- Draw semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    
    -- Draw pause menu box
    local boxWidth = 400
    local boxHeight = 300
    local boxX = (screenWidth - boxWidth) / 2
    local boxY = (screenHeight - boxHeight) / 2
    
    -- Draw box background with gradient effect
    love.graphics.setColor(0.1, 0.1, 0.2, 0.95)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)
    
    -- Draw box border with inner shadow
    love.graphics.setColor(0.05, 0.05, 0.15, 1)
    love.graphics.rectangle("fill", boxX + 2, boxY + 2, boxWidth - 4, boxHeight - 4)
    
    -- Draw outer border
    love.graphics.setColor(0.3, 0.3, 0.5, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight)
    
    -- Draw inner border
    love.graphics.setColor(0.5, 0.5, 0.7, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", boxX + 3, boxY + 3, boxWidth - 6, boxHeight - 6)
    
    -- Draw title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(36))
    local titleText = "PAUSED"
    local titleWidth = love.graphics.getFont():getWidth(titleText)
    love.graphics.print(titleText, boxX + (boxWidth - titleWidth) / 2, boxY + 40)
    
    -- Draw instructions
    love.graphics.setFont(love.graphics.newFont(18))
    local instructionText = "Press P or ESC to resume"
    local instructionWidth = love.graphics.getFont():getWidth(instructionText)
    love.graphics.print(instructionText, boxX + (boxWidth - instructionWidth) / 2, boxY + 120)
    
    -- Draw additional info
    love.graphics.setFont(love.graphics.newFont(14))
    local infoText = "Game is paused - all timers and movement stopped"
    local infoWidth = love.graphics.getFont():getWidth(infoText)
    love.graphics.print(infoText, boxX + (boxWidth - infoWidth) / 2, boxY + 160)
    
    -- Draw decorative elements
    love.graphics.setColor(0.7, 0.7, 0.9, 0.5)
    love.graphics.setLineWidth(2)
    
    -- Draw corner decorations
    local cornerSize = 20
    love.graphics.line(boxX + 10, boxY + 10, boxX + cornerSize, boxY + 10)
    love.graphics.line(boxX + 10, boxY + 10, boxX + 10, boxY + cornerSize)
    
    love.graphics.line(boxX + boxWidth - 10, boxY + 10, boxX + boxWidth - cornerSize, boxY + 10)
    love.graphics.line(boxX + boxWidth - 10, boxY + 10, boxX + boxWidth - 10, boxY + cornerSize)
    
    love.graphics.line(boxX + 10, boxY + boxHeight - 10, boxX + cornerSize, boxY + boxHeight - 10)
    love.graphics.line(boxX + 10, boxY + boxHeight - 10, boxX + 10, boxY + boxHeight - cornerSize)
    
    love.graphics.line(boxX + boxWidth - 10, boxY + boxHeight - 10, boxX + boxWidth - cornerSize, boxY + boxHeight - 10)
    love.graphics.line(boxX + boxWidth - 10, boxY + boxHeight - 10, boxX + boxWidth - 10, boxY + boxHeight - cornerSize)
    
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
end

return Rendering
