local MazeGenerator = {}
local Helpers = require("src.utils.helpers")
local GameConfig = require("src.config.game_config")

function MazeGenerator.generateProceduralMaze(rows, cols)
    local maze = Helpers.create2DArray(rows, cols, true)  -- Start with all walls
    
    -- Create random rooms
    local rooms = MazeGenerator._createRooms(maze, rows, cols)
    
    -- Connect rooms with corridors
    MazeGenerator._connectRooms(maze, rooms)
    
    -- Add random corridors
    MazeGenerator._addRandomCorridors(maze, rows, cols)
    
    -- Add scattered open areas
    MazeGenerator._addScatteredAreas(maze, rows, cols)
    
    -- Ensure connectivity
    MazeGenerator._ensureConnectivity(maze, rows, cols)
    
    -- Final safety check - ensure minimum walkable spaces
    local walkableCount = 0
    for r = 1, rows do
        for c = 1, cols do
            if not maze[r][c] then
                walkableCount = walkableCount + 1
            end
        end
    end
    
    local minWalkable = math.max(200, (rows * cols) * 0.35)  -- At least 35% walkable or 200 spaces (increased for finale tile reliability)
    if walkableCount < minWalkable then
        print("WARNING: Maze generator created too few walkable spaces (" .. walkableCount .. "), adding more...")
        MazeGenerator._addMoreWalkableSpaces(maze, rows, cols, minWalkable - walkableCount)
    end
    
    return maze
end

function MazeGenerator._createRooms(maze, rows, cols)
    local numRooms = math.random(4, 7)  -- More rooms for less walls
    local rooms = {}
    
    for i = 1, numRooms do
        local roomWidth = math.random(3, 6)
        local roomHeight = math.random(3, 6)
        local roomR = math.random(3, rows - roomHeight - 2)  -- Keep away from edges
        local roomC = math.random(3, cols - roomWidth - 2)
        
        -- Carve out the room
        for r = roomR, roomR + roomHeight - 1 do
            for c = roomC, roomC + roomWidth - 1 do
                if Helpers.isValidPosition(r, c, rows, cols) then
                    maze[r][c] = false
                end
            end
        end
        
        table.insert(rooms, {
            r = roomR,
            c = roomC,
            w = roomWidth,
            h = roomHeight
        })
    end
    
    return rooms
end

function MazeGenerator._connectRooms(maze, rooms)
    for i = 1, #rooms - 1 do
        local room1 = rooms[i]
        local room2 = rooms[i + 1]
        
        -- Connect room centers
        local center1R = room1.r + math.floor(room1.h / 2)
        local center1C = room1.c + math.floor(room1.w / 2)
        local center2R = room2.r + math.floor(room2.h / 2)
        local center2C = room2.c + math.floor(room2.w / 2)
        
        -- Create L-shaped corridor
        local r, c = center1R, center1C
        while r ~= center2R do
            if Helpers.isValidPosition(r, c, #maze, #maze[1]) then
                maze[r][c] = false
            end
            if r < center2R then
                r = r + 1
            else
                r = r - 1
            end
        end
        while c ~= center2C do
            if Helpers.isValidPosition(r, c, #maze, #maze[1]) then
                maze[r][c] = false
            end
            if c < center2C then
                c = c + 1
            else
                c = c - 1
            end
        end
        if Helpers.isValidPosition(r, c, #maze, #maze[1]) then
            maze[r][c] = false
        end
    end
end

function MazeGenerator._addRandomCorridors(maze, rows, cols)
    for i = 1, 30 do  -- More corridors for less walls
        local r = math.random(2, rows - 1)
        local c = math.random(2, cols - 1)
        local length = math.random(3, 8)
        local direction = math.random(1, 4)
        
        for j = 1, length do
            if Helpers.isValidPosition(r, c, rows, cols) then
                maze[r][c] = false
                
                if direction == GameConfig.DIRECTIONS.UP then
                    r = r - 1
                elseif direction == GameConfig.DIRECTIONS.DOWN then
                    r = r + 1
                elseif direction == GameConfig.DIRECTIONS.LEFT then
                    c = c - 1
                elseif direction == GameConfig.DIRECTIONS.RIGHT then
                    c = c + 1
                end
            else
                break
            end
        end
    end
end

function MazeGenerator._addScatteredAreas(maze, rows, cols)
    for i = 1, 30 do  -- More scattered areas for less walls
        local r = math.random(2, rows - 1)
        local c = math.random(2, cols - 1)
        local size = math.random(1, 3)  -- Increased max size from 2 to 3
        
        for dr = -size, size do
            for dc = -size, size do
                local newR, newC = r + dr, c + dc
                if Helpers.isValidPosition(newR, newC, rows, cols) and
                   math.random() > 0.3 then  -- Increased from 50% to 70% chance
                    maze[newR][newC] = false
                end
            end
        end
    end
end

function MazeGenerator._ensureConnectivity(maze, rows, cols)
    -- Count total walkable cells
    local totalWalkable = 0
    for r = 1, rows do
        for c = 1, cols do
            if not maze[r][c] then
                totalWalkable = totalWalkable + 1
            end
        end
    end
    
    -- Find a walkable cell to start flood fill from
    local startR, startC = 1, 1
    for r = 1, rows do
        for c = 1, cols do
            if not maze[r][c] then
                startR, startC = r, c
                break
            end
        end
        if not maze[startR][startC] then break end
    end
    
    -- Verify connectivity
    local reachableCount = MazeGenerator._floodFill(maze, startR, startC, rows, cols)
    if reachableCount < totalWalkable * 0.8 then  -- If less than 80% reachable
        -- Add more connections
        for i = 1, 10 do
            local r = math.random(2, rows - 1)
            local c = math.random(2, cols - 1)
            if maze[r][c] then  -- If it's a wall, make it a path
                maze[r][c] = false
            end
        end
    end
end

function MazeGenerator._floodFill(maze, startR, startC, rows, cols)
    local visited = Helpers.create2DArray(rows, cols, false)
    local stack = {{startR, startC}}
    local reachableCount = 0
    
    while #stack > 0 do
        local current = table.remove(stack)
        local r, c = current[1], current[2]
        
        if not visited[r][c] and not maze[r][c] then
            visited[r][c] = true
            reachableCount = reachableCount + 1
            
            -- Add adjacent cells to stack
            local directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
            for _, dir in ipairs(directions) do
                local newR, newC = r + dir[1], c + dir[2]
                if Helpers.isValidPosition(newR, newC, rows, cols) and not visited[newR][newC] then
                    table.insert(stack, {newR, newC})
                end
            end
        end
    end
    
    return reachableCount
end

function MazeGenerator._addMoreWalkableSpaces(maze, rows, cols, needed)
    local added = 0
    local attempts = 0
    local maxAttempts = 500
    
    while added < needed and attempts < maxAttempts do
        attempts = attempts + 1
        local r = math.random(2, rows - 1)
        local c = math.random(2, cols - 1)
        
        if maze[r][c] then  -- If it's a wall, make it walkable
            maze[r][c] = false
            added = added + 1
        end
    end
    
    print("DEBUG: Added " .. added .. " more walkable spaces to maze")
end

function MazeGenerator.addEdgeOpenings(maze, rows, cols)
    local numOpenings = math.random(2, 4)
    for i = 1, numOpenings do
        local edge = math.random(1, 4)
        local pos = math.random(1, math.max(rows, cols))
        
        if edge == 1 and pos <= cols then  -- Top edge
            maze[1][pos] = false
        elseif edge == 2 and pos <= rows then  -- Right edge
            maze[pos][cols] = false
        elseif edge == 3 and pos <= cols then  -- Bottom edge
            maze[rows][pos] = false
        elseif edge == 4 and pos <= rows then  -- Left edge
            maze[pos][1] = false
        end
    end
end

function MazeGenerator.findPath(maze, startR, startC, goalR, goalC, rows, cols)
    local openSet = {{startR, startC, 0, 0, nil}}  -- {r, c, g, f, parent}
    local closedSet = {}
    
    while #openSet > 0 do
        -- Find node with lowest f score
        local currentIndex = 1
        for i = 2, #openSet do
            if openSet[i][4] < openSet[currentIndex][4] then
                currentIndex = i
            end
        end
        
        local current = table.remove(openSet, currentIndex)
        local r, c = current[1], current[2]
        
        -- Check if we reached the goal
        if r == goalR and c == goalC then
            return true
        end
        
        -- Add to closed set
        closedSet[r .. "," .. c] = true
        
        -- Check neighbors
        local directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
        for _, dir in ipairs(directions) do
            local newR, newC = r + dir[1], c + dir[2]
            local key = newR .. "," .. newC
            
            -- Check if valid and not in closed set
            if Helpers.isValidPosition(newR, newC, rows, cols) and
               not closedSet[key] and
               (not maze[newR][newC] or maze[newR][newC] == "spawn" or maze[newR][newC] == "finale") then
                
                local tentativeG = current[3] + 1
                local h = Helpers.manhattanDistance(newR, newC, goalR, goalC)
                local f = tentativeG + h
                
                -- Check if this path to neighbor is better
                local inOpenSet = false
                for i, node in ipairs(openSet) do
                    if node[1] == newR and node[2] == newC then
                        inOpenSet = true
                        if tentativeG < node[3] then
                            openSet[i] = {newR, newC, tentativeG, f, current}
                        end
                        break
                    end
                end
                
                if not inOpenSet then
                    table.insert(openSet, {newR, newC, tentativeG, f, current})
                end
            end
        end
    end
    
    return false
end

return MazeGenerator
