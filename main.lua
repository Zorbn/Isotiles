local grass = love.graphics.newImage("grass.png")

local GRID_SIZE = 20
local GRID_CENTER_X = 400
local GRID_CENTER_Y = 300

local BLOCK_WIDTH = grass:getWidth()
local BLOCK_HEIGHT = grass:getHeight()
local BLOCK_DEPTH = BLOCK_HEIGHT / 2

local function toScreenPosition(x, y, z)
    local screenX = GRID_CENTER_X + ((y - x) * BLOCK_WIDTH / 2)
    local screenY = GRID_CENTER_Y + ((x + y) * BLOCK_DEPTH / 2) - (BLOCK_DEPTH * GRID_SIZE / 2) - BLOCK_DEPTH * z
    
    return screenX, screenY
end

function love.run()
    if love.load then
        love.load(love.arg.parseGameArguments(arg), arg)
    end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then
        love.timer.step()
    end

    local dt = 0

    -- Main loop time.
    return function()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            dt = love.timer.step()
        end

        -- Call update and draw
        if love.update then
            love.update(dt)
        end -- will pass 0 if love.timer is disabled

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            if love.draw then
                love.draw()
            end

            love.graphics.present()
        end

        -- if love.timer then love.timer.sleep(0.001) end
    end
end

love.window.setVSync(0)

local grid = {}
for z = 1, GRID_SIZE do
    grid[z] = {}
    for x = 1, GRID_SIZE do
        grid[z][x] = {}
        for y = 1, GRID_SIZE do
            grid[z][x][y] = 0
        end
    end
end

for x = 1, GRID_SIZE do
    for y = 1, GRID_SIZE do
        grid[1][x][y] = 1
    end
end

for x = 1, GRID_SIZE / 2 do
    for y = 1, GRID_SIZE / 2 do
        grid[2][x][y] = 1
    end
end

grid[2][2][4] = 0
grid[2][6][5] = 0

local spriteBatch = love.graphics.newSpriteBatch(grass)

local playerX = 0
local playerY = 0
local playerZ = 2
local playerSpeed = 3

local function ysort(a, b)
    return a.y < b.y
end

function love.update(dt)
    local dx = 0
    local dy = 0

    if love.keyboard.isDown("w") then
        dy = dy - 1
        dx = dx - 1
    end

    if love.keyboard.isDown("s") then
        dy = dy + 1
        dx = dx + 1
    end

    if love.keyboard.isDown("a") then
        dx = dx + 1
        dy = dy - 1
    end

    if love.keyboard.isDown("d") then
        dx = dx - 1
        dy = dy + 1
    end
    
    local currentSpeed = love.keyboard.isDown("lshift") and 2 or 1
    currentSpeed = currentSpeed * playerSpeed

    if dx ~= 0 or dy ~= 0 then
        local magnitude = math.sqrt(dx ^ 2 + dy ^ 2)
        dx, dy = dx / magnitude, dy / magnitude
        playerX = playerX + currentSpeed * dt * dx
        playerY = playerY + currentSpeed * dt * dy
    end
end

function love.draw()
    -- love.graphics.draw(grass, 0, 0)

    spriteBatch:clear()
    for z = 1, GRID_SIZE do
        if z ~= playerZ then
            for x = 1, GRID_SIZE do
                for y = 1, GRID_SIZE do
                    if grid[z][x][y] == 1 then
                        -- love.graphics.draw(
                        -- spriteBatch:add(gridCenterX + ((y - x) * blockWidth / 2), gridCenterY +
                        --     ((x + y) * blockDepth / 2) - (blockDepth * gridSize / 2) - blockDepth * z)
                        local screenX, screenY = toScreenPosition(x, y, z)
                        spriteBatch:add(screenX, screenY)
                    end
                end
            end
        else
            local sortingTable = {}

            for x = 1, GRID_SIZE do
                for y = 1, GRID_SIZE do
                    if grid[z][x][y] == 1 then
                        local screenX, screenY = toScreenPosition(x, y, z)
                        table.insert(sortingTable, {
                            x = screenX,
                            y = screenY,
                        })
                    end
                end
            end

            local playerScreenX, playerScreenY = toScreenPosition(playerX, playerY, playerZ)
            table.insert(sortingTable, {
                x = playerScreenX,
                y = playerScreenY,
            })

            -- table.insert(sortingTable, {
            --     x = playerX,
            --     y = playerY - blockDepth * z
            -- })

            table.sort(sortingTable, ysort)

            for _, sprite in ipairs(sortingTable) do
                spriteBatch:add(sprite.x, sprite.y)
            end
            
            
            -- spriteBatch:add(drawPlayerTileX, drawPlayerTileY)
        end
    end

    love.graphics.draw(spriteBatch, 0, 0)

    love.graphics.print(love.timer.getFPS() .. " FPS")
end
