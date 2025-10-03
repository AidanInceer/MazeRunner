-- Rendering system for maze, UI, particles, and effects
local Rendering = {}
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

function Rendering.drawMainMenu(screenWidth, screenHeight, startButton, colors)
    -- Draw animated background with gradient
    for y = 0, screenHeight do
        local gradient = y / screenHeight
        local r = colors.background[1] * (0.7 + 0.3 * gradient)
        local g = colors.background[2] * (0.7 + 0.3 * gradient)
        local b = colors.background[3] * (0.7 + 0.3 * gradient)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, y, screenWidth, 1)
    end
    
    -- Draw decorative border
    love.graphics.setColor(colors.ui_text[1], colors.ui_text[2], colors.ui_text[3], 0.2)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", 20, 20, screenWidth - 40, screenHeight - 40)
    
    -- Draw inner decorative border
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
    
    -- Draw enemies
    Rendering._drawEnemies(gameObjects.enemies, cellSize, offsetX, offsetY)
    
    -- Draw player
    Rendering._drawPlayer(playerData, cellSize, offsetX, offsetY)
    
    -- Draw effects
    Rendering._drawEffects(animationData, screenWidth, screenHeight)
end

--[[
    Renders the game UI
    
    @param playerData table Player data
    @param screenHeight number Screen height
    @param restartButton table Restart button data
]]
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
    
    -- Draw enemies killed
    love.graphics.setColor(colors.ui_text)
    love.graphics.print("Enemies Killed: " .. playerData.totalEnemiesKilled, boxX + 20, startY + lineHeight * 4)
    
    -- Draw health bar with better positioning
    Rendering._drawHealthBar(playerData.health, playerData.maxHealth, boxX + 20, startY + lineHeight * 5 + 5)
    
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

--[[
    Renders game over/win messages
    
    @param screenWidth number Screen width
    @param screenHeight number Screen height
    @param gameWon boolean Whether game is won
    @param gameOver boolean Whether game is over
]]
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

--[[
    Draws maze tiles with proper colors and hover effects
    
    @param maze table 2D maze array
    @param rows number Number of rows
    @param cols number Number of columns
    @param cellSize number Size of each cell
    @param offsetX number X offset
    @param offsetY number Y offset
    @param mouseX number Mouse X position
    @param mouseY number Mouse Y position
    @param gameObjects table Game objects
]]
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

--[[
    Draws a wall tile
    
    @param tileType string Type of wall tile
    @param x number X position
    @param y number Y position
    @param cellSize number Cell size
    @param isHovered boolean Whether mouse is hovering
]]
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
        -- Draw glow effect for finale
        love.graphics.setColor(colors.finale_glow)
        love.graphics.rectangle("fill", x - 4, y - 4, cellSize + 8, cellSize + 8)
        
        if isHovered then
            love.graphics.setColor(colors.finale_hover)
        else
            love.graphics.setColor(colors.finale_border)
        end
        
        -- Draw the tile background
        love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize - 4)
        
        -- Draw down arrow
        love.graphics.setColor(1, 1, 1, 1)  -- White arrow
        local centerX = x + cellSize / 2
        local centerY = y + cellSize / 2
        local arrowSize = cellSize * 0.3
        
        -- Draw down arrow using triangles
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

--[[
    Draws a walkable tile with items
    
    @param x number X position
    @param y number Y position
    @param cellSize number Cell size
    @param isHovered boolean Whether mouse is hovering
    @param gameObjects table Game objects
    @param r number Row position
    @param c number Column position
]]
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

--[[
    Draws items on a tile
    
    @param x number X position
    @param y number Y position
    @param cellSize number Cell size
    @param gameObjects table Game objects
    @param r number Row position
    @param c number Column position
]]
function Rendering._drawTileItems(x, y, cellSize, gameObjects, r, c)
    local centerX = x + cellSize / 2
    local centerY = y + cellSize / 2
    
    -- Draw collectible
    if gameObjects.collectibles[r] and gameObjects.collectibles[r][c] then
        love.graphics.setColor(GameConfig.COLORS.COLLECTIBLE)
        love.graphics.circle("fill", centerX, centerY, cellSize / 6)
    end
    
    -- Draw damage tile
    if gameObjects.damageTiles[r] and gameObjects.damageTiles[r][c] then
        love.graphics.setColor(GameConfig.COLORS.DAMAGE_TILE)
        love.graphics.rectangle("fill", x + 4, y + 4, cellSize - 8, cellSize - 8)
    end
    
    -- Draw health blob
    if gameObjects.healthBlobs[r] and gameObjects.healthBlobs[r][c] then
        love.graphics.setColor(GameConfig.COLORS.HEALTH_BLOB)
        love.graphics.circle("fill", centerX, centerY, cellSize / 5)
        -- Add cross
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", centerX - 1, centerY - 3, 2, 6)
        love.graphics.rectangle("fill", centerX - 3, centerY - 1, 6, 2)
    end
    
    -- Draw immunity blob
    if gameObjects.immunityBlobs[r] and gameObjects.immunityBlobs[r][c] then
        love.graphics.setColor(GameConfig.COLORS.IMMUNITY_BLOB)
        love.graphics.circle("fill", centerX, centerY, cellSize / 5)
        -- Add shield
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", centerX - 2, centerY - 4, 4, 6)
        love.graphics.rectangle("fill", centerX - 1, centerY - 5, 2, 2)
    end
end

--[[
    Draws enemies
    
    @param enemies table Array of enemies
    @param cellSize number Cell size
    @param offsetX number X offset
    @param offsetY number Y offset
]]
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
                local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, r, c)
                local time = love.timer.getTime()
                
                -- Apply theme-based sparky shader for enemies
                local enemyColor = {1, 0.2, 0.8}  -- Base purple/magenta
                ShaderManager.applyEnemyRetroWave(enemyColor, themeType)
                
                -- Draw enemy with full block coverage
                love.graphics.setColor(GameConfig.COLORS.ENEMY_BORDER)
                love.graphics.rectangle("fill", x, y, cellSize, cellSize)
                
                -- Draw enemy inner with sparky effect
                love.graphics.setColor(GameConfig.COLORS.ENEMY_INNER)
                love.graphics.rectangle("fill", x + 1, y + 1, cellSize - 2, cellSize - 2)
                
                -- Get theme-based colors (matching shader)
                local themeColors = {
                    {0.0, 1.0, 0.0},  -- Forest: Bright Green
                    {0.8, 0.4, 0.0},  -- Cave: Orange Brown
                    {0.0, 0.0, 1.0},  -- Void: Bright Blue
                    {1.0, 0.0, 0.0}   -- Abyss: Bright Red
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

--[[
    Draws the player
    
    @param playerData table Player data
    @param cellSize number Cell size
    @param offsetX number X offset
    @param offsetY number Y offset
]]
function Rendering._drawPlayer(playerData, cellSize, offsetX, offsetY)
    local x, y = Helpers.getScreenPosition(cellSize, offsetX, offsetY, playerData.r, playerData.c)
    local time = love.timer.getTime()
    
    -- Draw pulsing outer glow
    local pulse = 0.8 + 0.2 * math.sin(time * 4)
    if playerData.immune then
        love.graphics.setColor(1, 1, 0, 0.3 * pulse)  -- Yellow glow
    else
        love.graphics.setColor(0, 0.8, 1, 0.3 * pulse)  -- Blue glow
    end
    love.graphics.rectangle("fill", x - 3, y - 3, cellSize + 6, cellSize + 6)
    
    -- Draw outer border with highlight
    if playerData.immune then
        love.graphics.setColor(GameConfig.COLORS.PLAYER_IMMUNE_BORDER)
    else
        love.graphics.setColor(GameConfig.COLORS.PLAYER_BORDER)
    end
    love.graphics.rectangle("fill", x, y, cellSize, cellSize)
    
    -- Draw border highlight
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.rectangle("fill", x + 1, y + 1, cellSize - 2, 2)
    love.graphics.rectangle("fill", x + 1, y + 1, 2, cellSize - 2)
    
    -- Draw player inner with gradient effect
    if playerData.immune then
        love.graphics.setColor(GameConfig.COLORS.PLAYER_IMMUNE_INNER)
    else
        love.graphics.setColor(GameConfig.COLORS.PLAYER_INNER)
    end
    love.graphics.rectangle("fill", x + 2, y + 2, cellSize - 4, cellSize - 4)
    
    -- Draw inner highlight
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("fill", x + 3, y + 3, cellSize - 6, 2)
    love.graphics.rectangle("fill", x + 3, y + 3, 2, cellSize - 6)
    
    -- Draw center dot for better visibility
    local centerX = x + cellSize / 2
    local centerY = y + cellSize / 2
    local dotSize = cellSize * 0.2
    
    if playerData.immune then
        love.graphics.setColor(1, 1, 0, 1)  -- Yellow dot
    else
        love.graphics.setColor(1, 1, 1, 1)  -- White dot
    end
    love.graphics.circle("fill", centerX, centerY, dotSize)
    
    -- Draw immunity glow effect
    if playerData.immune then
        love.graphics.setColor(GameConfig.COLORS.IMMUNITY_GLOW)
        love.graphics.rectangle("fill", x - 2, y - 2, cellSize + 4, cellSize + 4)
        
        -- Draw pulsing immunity ring
        love.graphics.setColor(1, 1, 0, 0.6 * pulse)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x - 1, y - 1, cellSize + 2, cellSize + 2)
    end
end

--[[
    Draws visual effects
    
    @param animationData table Animation data
    @param screenWidth number Screen width
    @param screenHeight number Screen height
]]
function Rendering._drawEffects(animationData, screenWidth, screenHeight)
    -- Draw hit flash
    if animationData.hitFlashTimer > 0 then
        local alpha = animationData.hitFlashTimer / GameConfig.HIT_FLASH_DURATION
        love.graphics.setColor(GameConfig.COLORS.HIT_FLASH[1], GameConfig.COLORS.HIT_FLASH[2], 
                             GameConfig.COLORS.HIT_FLASH[3], GameConfig.COLORS.HIT_FLASH[4] * alpha)
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    end
    
    -- Draw particles
    for _, particle in ipairs(animationData.collectParticles) do
        local alpha = particle.life / particle.maxLife
        if particle.color == "green" then
            love.graphics.setColor(GameConfig.COLORS.PARTICLE_GREEN[1], GameConfig.COLORS.PARTICLE_GREEN[2], 
                                 GameConfig.COLORS.PARTICLE_GREEN[3], GameConfig.COLORS.PARTICLE_GREEN[4] * alpha)
        elseif particle.color == "red" then
            love.graphics.setColor(GameConfig.COLORS.PARTICLE_RED[1], GameConfig.COLORS.PARTICLE_RED[2], 
                                 GameConfig.COLORS.PARTICLE_RED[3], GameConfig.COLORS.PARTICLE_RED[4] * alpha)
        else
            love.graphics.setColor(GameConfig.COLORS.PARTICLE_YELLOW[1], GameConfig.COLORS.PARTICLE_YELLOW[2], 
                                 GameConfig.COLORS.PARTICLE_YELLOW[3], GameConfig.COLORS.PARTICLE_YELLOW[4] * alpha)
        end
        love.graphics.circle("fill", particle.x, particle.y, particle.size * alpha)
    end
end

--[[
    Draws a button
    
    @param button table Button data
    @param text string Button text
    @param fontSize number Font size
]]
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

--[[
    Draws the health bar
    
    @param health number Current health
    @param maxHealth number Maximum health
    @param x number X position
    @param y number Y position
]]
function Rendering._drawHealthBar(health, maxHealth, x, y)
    local barWidth = GameConfig.HEALTH_BAR_WIDTH
    local barHeight = GameConfig.HEALTH_BAR_HEIGHT
    
    -- Health bar background with inner shadow
    love.graphics.setColor(0.2, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", x, y, barWidth, barHeight)
    
    love.graphics.setColor(GameConfig.COLORS.HEALTH_BAR_BACKGROUND)
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
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, barWidth, barHeight)
    
    love.graphics.setColor(GameConfig.COLORS.HEALTH_BAR_BORDER)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 1, y + 1, barWidth - 2, barHeight - 2)
end

--[[
    Draws a feature box for the main menu
    
    @param x number X position
    @param y number Y position
    @param width number Box width
    @param height number Box height
    @param text string Text to display
    @param colors table Color scheme
]]
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

--[[
    Draws an enhanced button with better styling
    
    @param button table Button data
    @param text string Button text
    @param fontSize number Font size
    @param colors table Color scheme
]]
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

return Rendering
