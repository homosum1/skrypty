json = require("dkjson")

singleBlockSize = 20
fallTimer = 0
fallInterval = 0.5 
score = 0

boardWidth = 10
boardHeight = 20

notification = nil
notificationTimer = 0

isClearing = false
clearTimer = 0
linesToClear = {}


figureColors = {
    {1, 0, 0},
    {1, 1, 0},
    {0, 1, 1},
    {1, 0.5, 0},
    {0, 1, 0},
    {0, 0, 1},
    {0.6, 0, 1}
}

figures = {
    {3, 5, 4, 7},
    {2, 3, 4, 5},  
    {1, 3, 5, 7},
    {2, 4, 5, 7},
    {3, 5, 4, 6},
    {2, 3, 5, 7},
    {3, 5, 7, 6},
}

function table.serialize(tbl, indent)
    indent = indent or ""
    local result = "return {\n"
    for k, v in pairs(tbl) do
        local key = type(k) == "string" and string.format("[\"%s\"]", k) or "[" .. k .. "]"
        result = result .. indent .. "  " .. key .. " = "

        if type(v) == "table" then
            result = result .. table.serialize(v, indent .. "  ") .. ",\n"
        elseif type(v) == "number" then
            result = result .. v .. ",\n"
        elseif type(v) == "boolean" then
            result = result .. tostring(v) .. ",\n"
        elseif type(v) == "string" then
            result = result .. string.format("%q", v) .. ",\n"
        end
    end
    result = result .. indent .. "}"
    return result
end


function createPiece(index)
    local shape = {}

    for _, i in ipairs(figures[index]) do
        local x = i % 2
        local y = math.floor(i / 2)
        table.insert(shape, { x = x, y = y })
    end
    
    return {
        shape = shape,
        x = 4,
        y = 0,
        color = figureColors[index]
    }
end

function drawPiece(piece)
    love.graphics.setColor(piece.color)
    
    for index, block in ipairs(piece.shape) do
        local px = (piece.x + block.x) * singleBlockSize
        local py = (piece.y + block.y) * singleBlockSize
        love.graphics.rectangle("fill", px, py, singleBlockSize, singleBlockSize)
    end

    love.graphics.setColor(1, 1, 1)
end

function canMove(dx, dy)
    for index, block in ipairs(currentBlock.shape) do
        local newX = currentBlock.x + block.x + dx
        local newY = currentBlock.y + block.y + dy

        -- borders detection
        if newX < 0 or newX >= boardWidth or newY >= boardHeight then
            return false
        end

        -- occupied cell collision
        if newY >= 0 and board[newY + 1][newX + 1] ~= 0 then
            return false
        end
    end
    return true
end

function drawBoard()
    love.graphics.setColor(0.2, 0.2, 0.2)

    -- board gray shape
    for x = 0, boardWidth do
        local x_offset = x * singleBlockSize
        love.graphics.line(x_offset, 0, x_offset, boardHeight * singleBlockSize)
    end

    for y = 0, boardHeight do
        local y_offset = y * singleBlockSize
        love.graphics.line(0, y_offset, boardWidth * singleBlockSize, y_offset)
    end

    -- locked pieces
    for y = 1, boardHeight do
        for x = 1, boardWidth do
            local color = board[y][x]
            if color ~= 0 then
                if isClearing and contains(linesToClear, y) then
                    love.graphics.setColor(1, 1, 1)
                else
                    love.graphics.setColor(color)
                end
                love.graphics.rectangle("fill", (x - 1) * singleBlockSize, (y - 1) * singleBlockSize, singleBlockSize, singleBlockSize)
            end
        end
    end
end

function clearFullLines()
    linesToClear = {}

    for y = boardHeight, 1, -1 do
        local full = true
        for x = 1, boardWidth do
            if board[y][x] == 0 then
                full = false
                break
            end
        end

        if full then
            table.insert(linesToClear, y)
        end
    end

    if #linesToClear > 0 then
        isClearing = true
        clearTimer = 0.5
        love.audio.play(clearSound)
    end
end


function disablePieceMove()
    for _, block in ipairs(currentBlock.shape) do
        local x = currentBlock.x + block.x
        local y = currentBlock.y + block.y
        if y >= 0 then
            board[y + 1][x + 1] = currentBlock.color
        end
    end

    -- check wheter any rowe is eligible for deletion:
    clearFullLines()
    love.audio.play(sitSound)
    currentBlock = createPiece(love.math.random(1, 7))
end

function canRotate(newShape)
    for index, block in ipairs(newShape) do

        local newX = currentBlock.x + block.x
        local newY = currentBlock.y + block.y

        if newX < 0 or newX >= boardWidth or newY >= boardHeight then
            return false
        end

        if newY >= 0 and board[newY + 1][newX + 1] ~= 0 then
            return false
        end
    end

    return true
end

function rotate(shape, rightRotation)
    local newShape = {}
    local pivot = shape[2]

    for _, block in ipairs(shape) do
        local relX = block.x - pivot.x
        local relY = block.y - pivot.y

        local newX, newY
        if clockwise then
            newX = pivot.x - relY
            newY = pivot.y + relX
        else
            newX = pivot.x + relY
            newY = pivot.y - relX
        end

        table.insert(newShape, { x = newX, y = newY })
    end

    return newShape
end


function saveGame()
    local saveData = {
        board = board,
        currentBlock = currentBlock,
        score = score
    }

    local encoded = json.encode(saveData, { indent = true })
    love.filesystem.write("savegame.json", encoded)

    showNotification("Game saved", 2)
end

function loadGame()
    if not love.filesystem.getInfo("savegame.json") then
        showNotification("No save avaiable", 2)
        return
    end

    local contents = love.filesystem.read("savegame.json")
    local decoded, _, err = json.decode(contents)


    board = decoded.board
    currentBlock = decoded.currentBlock
    score = decoded.score

    showNotification("Game loaded", 2)
end

function showNotification(text, duration)
    notification = text
    notificationTimer = duration 
end

function contains(t, val)
    for _, v in ipairs(t) do
        if v == val then return true end
    end
    return false
end


function love.load()
    clickSound = love.audio.newSource("sounds/click.mp3", "static")
    clearSound = love.audio.newSource("sounds/explosion.mp3", "static")
    sitSound = love.audio.newSource("sounds/sit.mp3", "static")

    currentBlock = createPiece(love.math.random(1, 7))
    fallTimer = 0
    fallInterval = 0.5
    score = 0

    -- create game board:
    board = {}
    for y = 1, boardHeight do
        board[y] = {}
        for x = 1, boardWidth do
            board[y][x] = 0
        end
    end

end

function love.update(dt)
    -- timer update
    fallTimer = fallTimer + dt
    if fallTimer >= fallInterval then
        fallTimer = 0

        -- check wheter piece can still move
        if canMove(0, 1) then
            currentBlock.y = currentBlock.y + 1
        else
            disablePieceMove()
        end
    end

    -- notification display
    if notification then
        notificationTimer = notificationTimer - dt
        if notificationTimer <= 0 then
            notification = nil
        end
    end

    if isClearing then
        clearTimer = clearTimer - dt
        if clearTimer <= 0 then
            table.sort(linesToClear)

            for i = #linesToClear, 1, -1 do
            
                local y = linesToClear[i]
                table.remove(board, y)
                local newRow = {}
            
                for x = 1, boardWidth do
                    newRow[x] = 0
                end
                table.insert(board, 1, newRow)
            end
            score = score + #linesToClear
            linesToClear = {}
            isClearing = false
        end
    end
    
end

function love.draw()
    drawBoard()
    drawPiece(currentBlock)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Total score: " .. score, boardWidth * singleBlockSize + 20, 20)

    if notification then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(notification, boardWidth * singleBlockSize + 20, 50)
    end

    love.graphics.setColor(1, 1, 1)
    local baseY = boardHeight * singleBlockSize + 10

    love.graphics.print("Z - Save game", 0, baseY)
    love.graphics.print("X - Load game", 0, baseY + 20)
    love.graphics.print("A/D - Move left/right", 0, baseY + 40)
    love.graphics.print("S - Down", 0, baseY + 60)
    love.graphics.print("Q/E - Rotation left/right", 0, baseY + 80)

end

function love.keypressed(key)
    -- love.audio.play(clickSound)


    if key == "a" and canMove(-1, 0) then
        currentBlock.x = currentBlock.x - 1
    elseif key == "d" and canMove(1, 0) then
        currentBlock.x = currentBlock.x + 1
    elseif key == "s" and canMove(0, 1) then
        currentBlock.y = currentBlock.y + 1
    elseif key == "q" then
        local newShape = rotate(currentBlock.shape, false)
        
        if canRotate(newShape) then
            currentBlock.shape = newShape
        end
    elseif key == "e" then
        local newShape = rotate(currentBlock.shape, true)

        if canRotate(newShape) then
            currentBlock.shape = newShape
        end
    end

    if key == "z" then
        saveGame()
    elseif key == "x" then
        loadGame()
    end
end