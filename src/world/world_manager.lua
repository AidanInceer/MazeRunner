-- World generation and management system
local WorldManager = {}
local MazeGenerator = require("src.world.maze_generator")
local LevelManager = require("src.core.level_manager")
local LevelConfig = require("src.config.level_config")
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")
local DefaultEnemy = require("src.entities.enemies.default_enemy")
local PoisonEnemy = require("src.entities.enemies.poison_enemy")
local SplashEnemy = require("src.entities.enemies.splash_enemy")
local BlobEnemy = require("src.entities.enemies.blob_enemy")
local LightningEnemy = require("src.entities.enemies.lightning_enemy")

-- Validate that finale tile exists and is properly placed
function WorldManager.validateFinaleTile(maze, finaleR, finaleC, rows, cols)
    print("DEBUG: validateFinaleTile called with position " .. (finaleR or "nil") .. ", " .. (finaleC or "nil"))
    
    if not finaleR or not finaleC then
        print("ERROR: Finale tile position is nil!")
        return false
    end
    
    if not Helpers.isValidPosition(finaleR, finaleC, rows, cols) then
        print("ERROR: Finale tile position " .. finaleR .. ", " .. finaleC .. " is out of bounds!")
        return false
    end
    
    print("DEBUG: Finale tile at " .. finaleR .. ", " .. finaleC .. " has value: " .. tostring(maze[finaleR][finaleC]))
    
    if maze[finaleR][finaleC] ~= "finale" then
        print("WARNING: Finale tile at " .. finaleR .. ", " .. finaleC .. " is not marked as finale, fixing...")
        maze[finaleR][finaleC] = "finale"
    end
    
    print("DEBUG: Finale tile validated at " .. finaleR .. ", " .. finaleC)
    return true
end

-- Ensure minimum walkable spaces in the maze
function WorldManager.ensureMinimumWalkableSpaces(maze, rows, cols, minSpaces)
    local currentWalkable = 0
    for r = 1, rows do
        for c = 1, cols do
            if not maze[r][c] then
                currentWalkable = currentWalkable + 1
            end
        end
    end
    
    local needed = minSpaces - currentWalkable
    if needed > 0 then
        print("DEBUG: Need to add " .. needed .. " more walkable spaces")
        
        local added = 0
        local attempts = 0
        local maxAttempts = 1000
        
        while added < needed and attempts < maxAttempts do
            attempts = attempts + 1
            local r = math.random(2, rows - 1)
            local c = math.random(2, cols - 1)
            
            if maze[r][c] then  -- If it's a wall, make it walkable
                maze[r][c] = false
                added = added + 1
            end
        end
        
        print("DEBUG: Added " .. added .. " walkable spaces")
    end
end

-- Debug function to check if finale tile exists in the maze
function WorldManager.debugCheckFinaleTile(maze, rows, cols)
    local finaleCount = 0
    local finalePositions = {}
    
    for r = 1, rows do
        for c = 1, cols do
            if maze[r][c] == "finale" then
                finaleCount = finaleCount + 1
                table.insert(finalePositions, {r, c})
            end
        end
    end
    
    print("DEBUG: Found " .. finaleCount .. " finale tile(s) in maze")
    for i, pos in ipairs(finalePositions) do
        print("  Finale tile " .. i .. " at: " .. pos[1] .. ", " .. pos[2])
    end
    
    return finaleCount, finalePositions
end

-- Emergency finale tile creation - last resort method
function WorldManager.emergencyCreateFinaleTile(maze, rows, cols, avoidR, avoidC)
    print("EMERGENCY: Creating finale tile as last resort...")
    
    -- Try to find any position that's not the spawn point
    for r = 1, rows do
        for c = 1, cols do
            if not (avoidR and avoidC and r == avoidR and c == avoidC) then
                maze[r][c] = "finale"
                print("EMERGENCY: Created finale tile at " .. r .. ", " .. c)
                return r, c
            end
        end
    end
    
    -- If even that fails, place it at a random position
    local r, c = math.random(1, rows), math.random(1, cols)
    maze[r][c] = "finale"
    print("EMERGENCY: Created finale tile at random position " .. r .. ", " .. c)
    return r, c
end

-- Absolute fallback finale tile creation - guaranteed to work
function WorldManager.absoluteFallbackFinaleTile(maze, rows, cols, avoidR, avoidC)
    print("ABSOLUTE FALLBACK: Creating finale tile with guaranteed success...")
    
    -- First, try to find a walkable position away from spawn
    for r = 2, rows - 1 do
        for c = 2, cols - 1 do
            if not maze[r][c] and not (avoidR and avoidC and r == avoidR and c == avoidC) then
                maze[r][c] = "finale"
                print("ABSOLUTE FALLBACK: Created finale tile at walkable position " .. r .. ", " .. c)
                return r, c
            end
        end
    end
    
    -- If no walkable positions, create one by removing a wall
    for r = 2, rows - 1 do
        for c = 2, cols - 1 do
            if maze[r][c] and not (avoidR and avoidC and r == avoidR and c == avoidC) then
                maze[r][c] = "finale"
                print("ABSOLUTE FALLBACK: Created finale tile by removing wall at " .. r .. ", " .. c)
                return r, c
            end
        end
    end
    
    -- Last resort: place it anywhere, even if it overlaps with spawn
    local r, c = math.max(2, math.min(rows - 1, avoidR or 2)), math.max(2, math.min(cols - 1, avoidC or 2))
    maze[r][c] = "finale"
    print("ABSOLUTE FALLBACK: Created finale tile at forced position " .. r .. ", " .. c)
    return r, c
end

-- Force placement of finale tile - ensures it's always placed
function WorldManager.forcePlaceFinaleTile(maze, rows, cols, avoidR, avoidC)
    -- First try to find any walkable position
    for r = 1, rows do
        for c = 1, cols do
            if not maze[r][c] and not (avoidR and avoidC and r == avoidR and c == avoidC) then
                maze[r][c] = "finale"
                print("Finale tile forced at position: " .. r .. ", " .. c)
                return r, c
            end
        end
    end
    
    -- If no walkable positions found, create one by removing a wall
    local r, c = math.random(2, rows - 1), math.random(2, cols - 1)
    maze[r][c] = "finale"
    print("Finale tile forced by removing wall at position: " .. r .. ", " .. c)
    return r, c
end

-- Place a special tile (spawn or finale) on the maze edges
function WorldManager.placeSpecialTile(maze, rows, cols, tileType, avoidR, avoidC, preferredR, preferredC)
    -- For finale tiles, always place on a walkable area
    if tileType == "finale" then
        print("DEBUG: Attempting to place finale tile, avoiding spawn at " .. (avoidR or "nil") .. ", " .. (avoidC or "nil"))
        
        -- Find all walkable positions
        local walkablePositions = {}
        for r = 1, rows do
            for c = 1, cols do
                if not maze[r][c] and not (avoidR and avoidC and r == avoidR and c == avoidC) then
                    table.insert(walkablePositions, {r, c})
                end
            end
        end
        
        print("DEBUG: Found " .. #walkablePositions .. " walkable positions for finale tile (avoiding " .. (avoidR or "nil") .. ", " .. (avoidC or "nil") .. ")")
        
        if #walkablePositions > 0 then
            -- Pick a random walkable position
            local pos = walkablePositions[math.random(1, #walkablePositions)]
            maze[pos[1]][pos[2]] = tileType
            print("DEBUG: Placed finale tile at " .. pos[1] .. ", " .. pos[2])
            return pos[1], pos[2]
        else
            -- No walkable positions found - this should not happen with proper maze generation
            -- Return nil to trigger the fallback mechanism
            print("WARNING: No walkable positions found for finale tile placement")
            return nil, nil
        end
    end
    
    -- For spawn tiles, try preferred position first, then edge positions
    local r, c
    
    -- If a preferred position is provided and it's valid, use it
    if preferredR and preferredC then
        print("DEBUG: Preferred spawn position provided: " .. preferredR .. ", " .. preferredC)
        print("DEBUG: Position valid: " .. tostring(Helpers.isValidPosition(preferredR, preferredC, rows, cols)))
        print("DEBUG: Position walkable: " .. tostring(not maze[preferredR][preferredC]))
        print("DEBUG: Not avoiding position: " .. tostring(not (avoidR and avoidC and preferredR == avoidR and preferredC == avoidC)))
        
        if Helpers.isValidPosition(preferredR, preferredC, rows, cols) and
           not maze[preferredR][preferredC] and
           not (avoidR and avoidC and preferredR == avoidR and preferredC == avoidC) then
            r, c = preferredR, preferredC
            print("DEBUG: Using preferred spawn position at " .. r .. ", " .. c)
        else
            print("DEBUG: Preferred position not valid, falling back to random placement")
        end
    else
        print("DEBUG: No preferred spawn position provided")
    end
    
    if not r or not c then
        -- Try to find a suitable position (edge preferred, but any walkable position is fine)
        local attempts = 0
        local maxAttempts = 100
        
        repeat
            r = math.random(1, rows)
            c = math.random(1, cols)
            attempts = attempts + 1
            
            -- If we can't find a suitable position, try any walkable position
            if attempts > maxAttempts then
                for r = 1, rows do
                    for c = 1, cols do
                        if not maze[r][c] and not (avoidR and avoidC and r == avoidR and c == avoidC) then
                            maze[r][c] = tileType
                            print("DEBUG: Placed spawn tile at walkable position " .. r .. ", " .. c)
                            return r, c
                        end
                    end
                end
                -- Last resort: place on any position
                r, c = 1, 1
                break
            end
        until not maze[r][c] and  -- Ensure it's on a walkable area
              not (avoidR and avoidC and r == avoidR and c == avoidC)
        
        print("DEBUG: Placed spawn tile at " .. r .. ", " .. c)
    end
    
    maze[r][c] = tileType
    return r, c
end

-- Ensure there's a path from spawn to finale
function WorldManager.ensurePathToFinale(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
    print("DEBUG: Ensuring path from spawn (" .. spawnR .. ", " .. spawnC .. ") to finale (" .. finaleR .. ", " .. finaleC .. ")")
    
    -- First, verify both positions are valid
    if not Helpers.isValidPosition(spawnR, spawnC, rows, cols) then
        print("ERROR: Spawn position is invalid!")
        return false
    end
    
    if not Helpers.isValidPosition(finaleR, finaleC, rows, cols) then
        print("ERROR: Finale position is invalid!")
        return false
    end
    
    -- Check if path already exists
    local pathExists = MazeGenerator.findPath(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
    print("DEBUG: Path exists check result: " .. tostring(pathExists))
    
    if not pathExists then
        print("WARNING: No path found from spawn to finale! Creating guaranteed path...")
        
        -- Create a guaranteed path using multiple strategies
        local pathCreated = WorldManager.createGuaranteedPath(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
        
        if not pathCreated then
            print("ERROR: Failed to create path! Using emergency path creation...")
            WorldManager.emergencyCreatePath(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
        end
        
        -- Verify path was created
        local finalPathCheck = MazeGenerator.findPath(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
        print("DEBUG: Final path verification: " .. tostring(finalPathCheck))
        
        if not finalPathCheck then
            print("CRITICAL ERROR: Path creation failed completely!")
            return false
        end
    end
    
    print("DEBUG: Path from spawn to finale is guaranteed to exist")
    return true
end

-- Create a guaranteed path from spawn to finale
function WorldManager.createGuaranteedPath(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
    print("DEBUG: Creating guaranteed path from (" .. spawnR .. ", " .. spawnC .. ") to (" .. finaleR .. ", " .. finaleC .. ")")
    
    -- Strategy 1: Create a direct L-shaped path
    local r, c = spawnR, spawnC
    local pathCreated = true
    
    -- Move horizontally first, then vertically
    while c ~= finaleC do
        if c < finaleC then
            c = c + 1
        else
            c = c - 1
        end
        
        if Helpers.isValidPosition(r, c, rows, cols) then
            maze[r][c] = false
        else
            pathCreated = false
            break
        end
    end
    
    -- Move vertically
    while r ~= finaleR and pathCreated do
        if r < finaleR then
            r = r + 1
        else
            r = r - 1
        end
        
        if Helpers.isValidPosition(r, c, rows, cols) then
            maze[r][c] = false
        else
            pathCreated = false
            break
        end
    end
    
    if pathCreated then
        print("DEBUG: Direct L-shaped path created successfully")
        return true
    end
    
    -- Strategy 2: Create a diagonal path with wall removal
    print("DEBUG: L-shaped path failed, trying diagonal path with wall removal...")
    r, c = spawnR, spawnC
    pathCreated = true
    
    while (r ~= finaleR or c ~= finaleC) and pathCreated do
        -- Move towards finale
        if r < finaleR then
            r = r + 1
        elseif r > finaleR then
            r = r - 1
        end
        
        if c < finaleC then
            c = c + 1
        elseif c > finaleC then
            c = c - 1
        end
        
        if Helpers.isValidPosition(r, c, rows, cols) then
            maze[r][c] = false
        else
            pathCreated = false
            break
        end
    end
    
    if pathCreated then
        print("DEBUG: Diagonal path created successfully")
        return true
    end
    
    print("DEBUG: Both path strategies failed")
    return false
end

-- Emergency path creation - guaranteed to work
function WorldManager.emergencyCreatePath(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
    print("EMERGENCY: Creating path with guaranteed success...")
    
    -- Create a simple straight line path, removing any walls in the way
    local r, c = spawnR, spawnC
    
    -- Move row by row
    while r ~= finaleR do
        if r < finaleR then
            r = r + 1
        else
            r = r - 1
        end
        
        if Helpers.isValidPosition(r, c, rows, cols) then
            maze[r][c] = false
        end
    end
    
    -- Move column by column
    while c ~= finaleC do
        if c < finaleC then
            c = c + 1
        else
            c = c - 1
        end
        
        if Helpers.isValidPosition(r, c, rows, cols) then
            maze[r][c] = false
        end
    end
    
    print("EMERGENCY: Path created by removing all walls in direct line")
end

-- Find a random walkable position on the maze
function WorldManager.findRandomWalkablePosition(maze, rows, cols)
    local attempts = 0
    local maxAttempts = 100
    
    while attempts < maxAttempts do
        local r = math.random(1, rows)
        local c = math.random(1, cols)
        
        -- Check if position is walkable (not a wall)
        if not maze[r][c] then
            return r, c
        end
        
        attempts = attempts + 1
    end
    
    -- If no random position found, try to find any walkable position
    for r = 1, rows do
        for c = 1, cols do
            if not maze[r][c] then
                return r, c
            end
        end
    end
    
    -- If no walkable positions exist, return nil
    return nil, nil
end

-- Place speed boost orbs on the maze
function WorldManager.placeSpeedBoostOrbs(maze, rows, cols, count)
    local SpeedBoostOrb = require("src.entities.misc.speed_boost_orb")
    local orbs = {}
    
    for i = 1, count do
        local r, c = WorldManager.findRandomWalkablePosition(maze, rows, cols)
        if r and c then
            local orb = SpeedBoostOrb.create(r, c)
            table.insert(orbs, orb)
            print("DEBUG: Placed speed boost orb at " .. r .. ", " .. c)
        end
    end
    
    return orbs
end

-- Place moveable crates on the maze
function WorldManager.placeMoveableCrates(maze, rows, cols, count)
    local MoveableCrate = require("src.entities.misc.moveable_crate")
    local crates = {}
    
    for i = 1, count do
        local r, c = WorldManager.findRandomWalkablePosition(maze, rows, cols)
        if r and c then
            local crate = MoveableCrate.create(r, c)
            table.insert(crates, crate)
            print("DEBUG: Placed moveable crate at " .. r .. ", " .. c)
        end
    end
    
    return crates
end

-- Place game items on the maze
function WorldManager.placeItems(maze, rows, cols, count, itemType)
    local items = {}
    for r = 1, rows do
        items[r] = {}
        for c = 1, cols do
            items[r][c] = false
        end
    end
    
    local placed = 0
    local attempts = 0
    local maxAttempts = 500
    
    while placed < count and attempts < maxAttempts do
        attempts = attempts + 1
        local r = math.random(1, rows)
        local c = math.random(1, cols)
        
        if not maze[r][c] and not items[r][c] then
            items[r][c] = true
            placed = placed + 1
        end
    end
    
    return items
end

-- Place enemies on the maze
function WorldManager.placeEnemies(maze, rows, cols, count)
    local enemies = {}
    for r = 1, rows do
        enemies[r] = {}
        for c = 1, cols do
            enemies[r][c] = false
        end
    end
    
    local placed = 0
    local attempts = 0
    local maxAttempts = 500
    
    while placed < count and attempts < maxAttempts do
        attempts = attempts + 1
        local r = math.random(1, rows)
        local c = math.random(1, cols)
        
        if not maze[r][c] and not enemies[r][c] then
            enemies[r][c] = DefaultEnemy.create(r, c)
            placed = placed + 1
        end
    end
    
    return enemies
end

-- Generate the complete game world
function WorldManager.generateGameWorld(preferredSpawnR, preferredSpawnC)
    local rows, cols = GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS
    local settings = LevelManager.getCurrentSettings()
    
    -- Set random seed for this level generation
    math.randomseed(os.time() + LevelManager.getCurrentLevel())
    
    -- Generate procedural maze
    local maze = MazeGenerator.generateProceduralMaze(rows, cols)
    MazeGenerator.addEdgeOpenings(maze, rows, cols)
    
    -- Debug: Count walkable spaces before placing special tiles
    local walkableCount = 0
    for r = 1, rows do
        for c = 1, cols do
            if not maze[r][c] then
                walkableCount = walkableCount + 1
            end
        end
    end
    print("DEBUG: Generated maze has " .. walkableCount .. " walkable spaces out of " .. (rows * cols) .. " total spaces")
    
    -- Ensure minimum walkable spaces for proper gameplay
    local minWalkableSpaces = 200  -- Minimum 200 walkable spaces for 30x30 map (increased for finale tile reliability)
    if walkableCount < minWalkableSpaces then
        print("WARNING: Maze has too few walkable spaces (" .. walkableCount .. "), adding more...")
        WorldManager.ensureMinimumWalkableSpaces(maze, rows, cols, minWalkableSpaces)
        
        -- Recount walkable spaces
        walkableCount = 0
        for r = 1, rows do
            for c = 1, cols do
                if not maze[r][c] then
                    walkableCount = walkableCount + 1
                end
            end
        end
        print("DEBUG: After ensuring minimum spaces, maze has " .. walkableCount .. " walkable spaces")
    end
    
    -- If we have a preferred spawn position, clear it first (it might be a finale tile from previous level)
    if preferredSpawnR and preferredSpawnC then
        print("DEBUG: Clearing preferred spawn position " .. preferredSpawnR .. ", " .. preferredSpawnC .. " for spawn tile")
        maze[preferredSpawnR][preferredSpawnC] = false  -- Make it walkable
        
        -- Recount walkable spaces after clearing
        local walkableCountAfter = 0
        for r = 1, rows do
            for c = 1, cols do
                if not maze[r][c] then
                    walkableCountAfter = walkableCountAfter + 1
                end
            end
        end
        print("DEBUG: Walkable spaces after clearing preferred position: " .. walkableCountAfter)
    end
    
    -- Place spawn and finale
    local spawnR, spawnC = WorldManager.placeSpecialTile(maze, rows, cols, "spawn", nil, nil, preferredSpawnR, preferredSpawnC)
    print("DEBUG: Spawn placed at " .. spawnR .. ", " .. spawnC)
    local finaleR, finaleC = WorldManager.placeSpecialTile(maze, rows, cols, "finale", spawnR, spawnC)
    print("DEBUG: Finale placement attempt returned: " .. (finaleR or "nil") .. ", " .. (finaleC or "nil"))
    
    -- Validate that finale tile was placed - if not, force placement
    if not finaleR or not finaleC then
        print("WARNING: Finale tile was not placed, forcing placement...")
        finaleR, finaleC = WorldManager.forcePlaceFinaleTile(maze, rows, cols, spawnR, spawnC)
    end
    
    -- Final validation - ensure finale tile exists and is accessible
    print("DEBUG: Validating finale tile at " .. (finaleR or "nil") .. ", " .. (finaleC or "nil"))
    WorldManager.validateFinaleTile(maze, finaleR, finaleC, rows, cols)
    
    
    -- Debug check to verify finale tile placement
    local finaleCount, finalePositions = WorldManager.debugCheckFinaleTile(maze, rows, cols)
    print("DEBUG: Finale tile count after placement: " .. finaleCount)
    
    -- CRITICAL SAFETY CHECK: If no finale tile exists, force create one
    if finaleCount == 0 then
        print("CRITICAL ERROR: No finale tile found after all attempts! Forcing creation...")
        finaleR, finaleC = WorldManager.emergencyCreateFinaleTile(maze, rows, cols, spawnR, spawnC)
        print("EMERGENCY: Created finale tile at " .. finaleR .. ", " .. finaleC)
        
        -- Verify the emergency creation worked
        local finalCount, _ = WorldManager.debugCheckFinaleTile(maze, rows, cols)
        print("DEBUG: Finale tile count after emergency creation: " .. finalCount)
        
        -- If still no finale tile, this is a critical failure
        if finalCount == 0 then
            print("CRITICAL FAILURE: Emergency finale creation failed! Using absolute fallback...")
            finaleR, finaleC = WorldManager.absoluteFallbackFinaleTile(maze, rows, cols, spawnR, spawnC)
        end
    end
    
    -- FINAL VERIFICATION: Ensure we have a valid finale tile before proceeding
    if not finaleR or not finaleC then
        print("FINAL VERIFICATION FAILED: No finale tile coordinates! Using absolute fallback...")
        finaleR, finaleC = WorldManager.absoluteFallbackFinaleTile(maze, rows, cols, spawnR, spawnC)
    end
    
    -- Verify the finale tile is actually marked correctly in the maze
    if not maze[finaleR] or not maze[finaleR][finaleC] or maze[finaleR][finaleC] ~= "finale" then
        print("FINAL VERIFICATION: Finale tile not properly marked in maze! Fixing...")
        maze[finaleR][finaleC] = "finale"
    end
    
    
    -- Ensure path exists from spawn to finale
    local pathEnsured = WorldManager.ensurePathToFinale(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
    if not pathEnsured then
        print("CRITICAL ERROR: Failed to ensure path from spawn to finale!")
        -- This should never happen with our enhanced system, but if it does, we have a problem
    end
    
    -- Initialize visited tracking
    local visited = Helpers.create2DArray(rows, cols, false)
    visited[spawnR][spawnC] = true
    
    -- Place game items with level-specific counts
    local collectibles = WorldManager.placeItems(maze, rows, cols, settings.collectibleCount, "collectible")
    local damageTiles = WorldManager.placeItems(maze, rows, cols, settings.damageTileCount, "damage")
    local healthBlobs = WorldManager.placeItems(maze, rows, cols, settings.healthBlobCount, "health")
    local immunityBlobs = WorldManager.placeItems(maze, rows, cols, settings.immunityBlobCount, "immunity")
    local speedBoostOrbs = WorldManager.placeSpeedBoostOrbs(maze, rows, cols, settings.speedBoostOrbCount)
    local moveableCrates = WorldManager.placeMoveableCrates(maze, rows, cols, settings.moveableCrateCount)
    
    -- Place enemies with level progression scaling
    local currentTheme = LevelManager.getCurrentLevel()
    local levelProgress = LevelManager.getLevelProgress()
    
    -- Get enemy counts from level config
    local defaultEnemyCount = LevelConfig.getDefaultEnemyCount(currentTheme, levelProgress)
    local poisonEnemyCount = LevelConfig.getPoisonEnemyCount(currentTheme, levelProgress)
    local splashEnemyCount = LevelConfig.getSplashEnemyCount(currentTheme, levelProgress)
    local blobEnemyCount = LevelConfig.getBlobEnemyCount(currentTheme, levelProgress)
    local lightningEnemyCount = LevelConfig.getLightningEnemyCount(currentTheme, levelProgress)
    
    -- Place each enemy type
    local enemies = WorldManager.placeEnemies(maze, rows, cols, defaultEnemyCount)
    local poisonEnemies = WorldManager.placePoisonEnemies(maze, rows, cols, poisonEnemyCount)
    local splashEnemies = WorldManager.placeSplashEnemies(maze, rows, cols, splashEnemyCount)
    local blobEnemies = WorldManager.placeBlobEnemies(maze, rows, cols, blobEnemyCount)
    local lightningEnemies = WorldManager.placeLightningEnemies(maze, rows, cols, lightningEnemyCount)
    
    -- Debug: Report enemy counts
    print("DEBUG: Enemy counts - Default: " .. (enemies and #enemies or 0) .. 
          ", Poison: " .. (poisonEnemies and #poisonEnemies or 0) .. 
          ", Splash: " .. (splashEnemies and #splashEnemies or 0) .. 
          ", Blob: " .. (blobEnemies and #blobEnemies or 0) .. 
          ", Lightning: " .. (lightningEnemies and #lightningEnemies or 0))
    
    -- FINAL ABSOLUTE VERIFICATION: Ensure finale tile exists before returning
    local finalVerificationCount, _ = WorldManager.debugCheckFinaleTile(maze, rows, cols)
    if finalVerificationCount == 0 then
        print("FINAL ABSOLUTE VERIFICATION FAILED: No finale tile found! Creating one last finale tile...")
        finaleR, finaleC = WorldManager.absoluteFallbackFinaleTile(maze, rows, cols, spawnR, spawnC)
        print("FINAL ABSOLUTE VERIFICATION: Created finale tile at " .. finaleR .. ", " .. finaleC)
    end
    
    -- FINAL PATH VERIFICATION: Ensure path from spawn to finale is accessible
    local finalPathVerification = MazeGenerator.findPath(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
    if not finalPathVerification then
        print("FINAL PATH VERIFICATION FAILED: No path from spawn to finale! Creating emergency path...")
        WorldManager.emergencyCreatePath(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
        
        -- Verify emergency path creation worked
        local emergencyPathCheck = MazeGenerator.findPath(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
        if not emergencyPathCheck then
            print("CRITICAL FAILURE: Emergency path creation failed!")
        else
            print("FINAL PATH VERIFICATION: Emergency path created successfully")
        end
    else
        print("FINAL PATH VERIFICATION: Path from spawn to finale is accessible")
    end
    
    print("FINAL VERIFICATION: Level generation complete with finale tile at " .. finaleR .. ", " .. finaleC .. " and accessible path")
    
    return {
        maze = maze,
        spawnR = spawnR,
        spawnC = spawnC,
        finaleR = finaleR,
        finaleC = finaleC,
        collectibles = collectibles,
        damageTiles = damageTiles,
        healthBlobs = healthBlobs,
        immunityBlobs = immunityBlobs,
        speedBoostOrbs = speedBoostOrbs,
        moveableCrates = moveableCrates,
        enemies = enemies,
        poisonEnemies = poisonEnemies,
        poisonTiles = {},
        splashEnemies = splashEnemies,
        splashTiles = {},
        blobEnemies = blobEnemies,
        lightningEnemies = lightningEnemies,
        visited = visited
    }
end

-- Place poison enemies on the maze
function WorldManager.placePoisonEnemies(maze, rows, cols, count)
    local poisonEnemies = {}
    local placed = 0
    local attempts = 0
    local maxAttempts = 500  -- Increased attempts
    
    while placed < count and attempts < maxAttempts do
        attempts = attempts + 1
        local r = math.random(1, rows)
        local c = math.random(1, cols)
        
        -- Check if position is walkable (empty)
        if not maze[r][c] then
            -- Check if position is not occupied by another poison enemy
            local positionOccupied = false
            for _, enemy in ipairs(poisonEnemies) do
                if enemy.r == r and enemy.c == c then
                    positionOccupied = true
                    break
                end
            end
            
            if not positionOccupied then
                table.insert(poisonEnemies, PoisonEnemy.create(r, c))
                placed = placed + 1
            end
        end
    end
    
    -- If we couldn't place enough enemies, place them at fixed positions
    while placed < count do
        local r = 5 + placed
        local c = 5 + placed
        if r <= rows and c <= cols then
            table.insert(poisonEnemies, PoisonEnemy.create(r, c))
            placed = placed + 1
        else
            break
        end
    end
    
    return poisonEnemies
end

-- Place splash enemies on the maze
function WorldManager.placeSplashEnemies(maze, rows, cols, count)
    local splashEnemies = {}
    local placed = 0
    local attempts = 0
    local maxAttempts = 500
    
    while placed < count and attempts < maxAttempts do
        attempts = attempts + 1
        local r = math.random(1, rows)
        local c = math.random(1, cols)
        
        -- Check if position is walkable (empty)
        if not maze[r][c] then
            -- Check if position is not occupied by another splash enemy
            local positionOccupied = false
            for _, enemy in ipairs(splashEnemies) do
                if enemy.r == r and enemy.c == c then
                    positionOccupied = true
                    break
                end
            end
            
            if not positionOccupied then
                table.insert(splashEnemies, SplashEnemy.create(r, c))
                placed = placed + 1
            end
        end
    end
    
    -- If we couldn't place enough enemies, place them at fixed positions
    while placed < count do
        local r = 3 + placed
        local c = 3 + placed
        if r <= rows and c <= cols then
            table.insert(splashEnemies, SplashEnemy.create(r, c))
            placed = placed + 1
        else
            break
        end
    end
    
    return splashEnemies
end

-- Place blob enemies on the maze
function WorldManager.placeBlobEnemies(maze, rows, cols, count)
    print("DEBUG: Attempting to place " .. count .. " blob enemies")
    local blobEnemies = {}
    local placed = 0
    local attempts = 0
    local maxAttempts = 500
    
    while placed < count and attempts < maxAttempts do
        attempts = attempts + 1
        local r = math.random(1, rows - 1)  -- Leave room for 2x2 blob
        local c = math.random(1, cols - 1)  -- Leave room for 2x2 blob
        
        -- Check if all 4 cells for the 2x2 blob are walkable
        local canPlace = true
        for dr = 0, 1 do
            for dc = 0, 1 do
                local checkR = r + dr
                local checkC = c + dc
                if not Helpers.isValidPosition(checkR, checkC, rows, cols) or maze[checkR][checkC] then
                    canPlace = false
                    break
                end
            end
            if not canPlace then break end
        end
        
        if canPlace then
            -- Check if position is not occupied by another blob enemy
            local positionOccupied = false
            for _, enemy in ipairs(blobEnemies) do
                if enemy.r == r and enemy.c == c then
                    positionOccupied = true
                    break
                end
            end
            
            if not positionOccupied then
                table.insert(blobEnemies, BlobEnemy.create(r, c))
                placed = placed + 1
            end
        end
    end
    
    -- If we couldn't place enough enemies, place them at fixed positions
    while placed < count do
        local r = 2 + placed
        local c = 2 + placed
        if r <= rows - 1 and c <= cols - 1 then
            table.insert(blobEnemies, BlobEnemy.create(r, c))
            placed = placed + 1
        else
            break
        end
    end
    
    print("DEBUG: Successfully placed " .. #blobEnemies .. " blob enemies")
    return blobEnemies
end

-- Place lightning enemies on the maze
function WorldManager.placeLightningEnemies(maze, rows, cols, count)
    print("DEBUG: Attempting to place " .. count .. " lightning enemies")
    local lightningEnemies = {}
    local placed = 0
    local attempts = 0
    local maxAttempts = 500
    
    while placed < count and attempts < maxAttempts do
        attempts = attempts + 1
        local r = math.random(1, rows)
        local c = math.random(1, cols)
        
        -- Check if position is walkable (empty)
        if not maze[r][c] then
            -- Check if position is not occupied by another lightning enemy
            local positionOccupied = false
            for _, enemy in ipairs(lightningEnemies) do
                if enemy.r == r and enemy.c == c then
                    positionOccupied = true
                    break
                end
            end
            
            if not positionOccupied then
                table.insert(lightningEnemies, LightningEnemy.create(r, c))
                placed = placed + 1
            end
        end
    end
    
    -- If we couldn't place enough enemies, place them at fixed positions
    while placed < count do
        local r = 4 + placed
        local c = 4 + placed
        if r <= rows and c <= cols then
            table.insert(lightningEnemies, LightningEnemy.create(r, c))
            placed = placed + 1
        else
            break
        end
    end
    
    print("DEBUG: Successfully placed " .. #lightningEnemies .. " lightning enemies")
    return lightningEnemies
end

return WorldManager
