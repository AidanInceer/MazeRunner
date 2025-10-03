-- World generation and management system
local WorldManager = {}
local MazeGenerator = require("src.world.maze_generator")
local LevelManager = require("src.core.level_manager")
local GameConfig = require("src.config.game_config")
local Helpers = require("src.utils.helpers")

-- Place a special tile (spawn or finale) on the maze edges
function WorldManager.placeSpecialTile(maze, rows, cols, tileType, avoidR, avoidC)
    -- For finale tiles, always place on a walkable area
    if tileType == "finale" then
        -- Find all walkable positions
        local walkablePositions = {}
        for r = 1, rows do
            for c = 1, cols do
                if not maze[r][c] and not (avoidR and avoidC and r == avoidR and c == avoidC) then
                    table.insert(walkablePositions, {r, c})
                end
            end
        end
        
        if #walkablePositions > 0 then
            -- Pick a random walkable position
            local pos = walkablePositions[math.random(1, #walkablePositions)]
            maze[pos[1]][pos[2]] = tileType
            return pos[1], pos[2]
        end
    end
    
    -- For spawn tiles, try edge positions first
    local r, c
    local attempts = 0
    local maxAttempts = 100
    
    repeat
        r = math.random(1, rows)
        c = math.random(1, cols)
        attempts = attempts + 1
        
        -- If we can't find a suitable edge position, try any walkable position
        if attempts > maxAttempts then
            for r = 1, rows do
                for c = 1, cols do
                    if not maze[r][c] and not (avoidR and avoidC and r == avoidR and c == avoidC) then
                        maze[r][c] = tileType
                        return r, c
                    end
                end
            end
            -- Last resort: place on any position
            r, c = 1, 1
            break
        end
    until (r == 1 or r == rows or c == 1 or c == cols) and 
          not maze[r][c] and  -- Ensure it's on a walkable area
          not (avoidR and avoidC and r == avoidR and c == avoidC)
    
    maze[r][c] = tileType
    return r, c
end

-- Ensure there's a path from spawn to finale
function WorldManager.ensurePathToFinale(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
    if not MazeGenerator.findPath(maze, spawnR, spawnC, finaleR, finaleC, rows, cols) then
        -- Create a direct path if none exists
        local r, c = spawnR, spawnC
        while r ~= finaleR or c ~= finaleC do
            if r < finaleR then
                r = r + 1
            elseif r > finaleR then
                r = r - 1
            elseif c < finaleC then
                c = c + 1
            elseif c > finaleC then
                c = c - 1
            end
            
            if Helpers.isValidPosition(r, c, rows, cols) then
                maze[r][c] = false
            end
        end
    end
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
            enemies[r][c] = {
                r = r,
                c = c,
                direction = math.random(1, 4),
                moveTimer = 0
            }
            placed = placed + 1
        end
    end
    
    return enemies
end

-- Generate the complete game world
function WorldManager.generateGameWorld()
    local rows, cols = GameConfig.MAZE_ROWS, GameConfig.MAZE_COLS
    local settings = LevelManager.getCurrentSettings()
    
    -- Set random seed for this level generation
    math.randomseed(os.time() + LevelManager.getCurrentLevel())
    
    -- Generate procedural maze
    local maze = MazeGenerator.generateProceduralMaze(rows, cols)
    MazeGenerator.addEdgeOpenings(maze, rows, cols)
    
    -- Place spawn and finale
    local spawnR, spawnC = WorldManager.placeSpecialTile(maze, rows, cols, "spawn")
    local finaleR, finaleC = WorldManager.placeSpecialTile(maze, rows, cols, "finale", spawnR, spawnC)
    
    -- Ensure path exists from spawn to finale
    WorldManager.ensurePathToFinale(maze, spawnR, spawnC, finaleR, finaleC, rows, cols)
    
    -- Initialize visited tracking
    local visited = Helpers.create2DArray(rows, cols, false)
    visited[spawnR][spawnC] = true
    
    -- Place game items with level-specific counts
    local collectibles = WorldManager.placeItems(maze, rows, cols, settings.collectibleCount, "collectible")
    local damageTiles = WorldManager.placeItems(maze, rows, cols, settings.damageTileCount, "damage")
    local healthBlobs = WorldManager.placeItems(maze, rows, cols, settings.healthBlobCount, "health")
    local immunityBlobs = WorldManager.placeItems(maze, rows, cols, settings.immunityBlobCount, "immunity")
    
    -- Place enemies with level progression scaling
    local enemyCount = LevelManager.getEnemyCount()
    local enemies = WorldManager.placeEnemies(maze, rows, cols, enemyCount)
    
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
        enemies = enemies,
        visited = visited
    }
end

return WorldManager
