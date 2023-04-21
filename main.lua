require "map"
require "player"
require "camera"

love.graphics.setDefaultFilter("nearest")
local grass = love.graphics.newImage("blank.png")

local BLOCK_WIDTH = grass:getWidth()
local BLOCK_HEIGHT = grass:getHeight()
local BLOCK_DEPTH = BLOCK_HEIGHT / 2

local camera = Camera.new()
local player = Player.new()
local map = Map.new()

for x = 1, Map.GRID_SIZE do
    for y = 1, Map.GRID_SIZE do
        map.grid[1][x][y] = 1
    end
end

for x = 2, Map.GRID_SIZE / 2 do
    for y = 2, Map.GRID_SIZE / 2 do
        map.grid[2][x][y] = 1
    end
end

map.grid[2][3][3] = 0
map.grid[2][9][3] = 0

map.grid[2][3][7] = 0
map.grid[2][9][7] = 0

map.grid[2][4][8] = 0
map.grid[2][5][8] = 0
map.grid[2][6][8] = 0
map.grid[2][7][8] = 0
map.grid[2][8][8] = 0

local spriteBatch = love.graphics.newSpriteBatch(grass)

local function toScreenPosition(x, y, z)
    local screenX = Map.GRID_CENTER_X + ((y - x) * BLOCK_WIDTH / 2)
    local screenY = Map.GRID_CENTER_Y + ((x + y) * BLOCK_DEPTH / 2) - (BLOCK_DEPTH * Map.GRID_SIZE / 2) - BLOCK_DEPTH * z
    screenX = screenX * camera.scale + camera.offsetX
    screenY = screenY * camera.scale + camera.offsetY

    return screenX, screenY
end

local function ysort(a, b)
    return a.y < b.y
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

function love.resize(width, height)
    camera:resize(width, height)
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

    player:move(map, dx, dy, dt)
end

function love.draw()
    spriteBatch:clear()
    for z = 1, Map.GRID_SIZE do
        local zShade = Map.GRID_Z_SHADE_MIN + Map.GRID_Z_SHADE_STEP * z
        spriteBatch:setColor(zShade, zShade, zShade, 1)

        if z ~= player.z then
            for x = 1, Map.GRID_SIZE do
                for y = 1, Map.GRID_SIZE do
                    if map.grid[z][x][y] == 1 then
                        local screenX, screenY = toScreenPosition(x, y, z)
                        spriteBatch:add(screenX, screenY, 0, camera.scale, camera.scale)
                    end
                end
            end
        else
            local sortingTable = {}

            for x = 1, Map.GRID_SIZE do
                for y = 1, Map.GRID_SIZE do
                    if map.grid[z][x][y] == 1 then
                        local screenX, screenY = toScreenPosition(x, y, z)
                        table.insert(sortingTable, {
                            x = screenX,
                            y = screenY
                        })
                    end
                end
            end

            local playerScreenX, playerScreenY = toScreenPosition(player.x, player.y, player.z)
            table.insert(sortingTable, {
                x = playerScreenX,
                y = playerScreenY
            })

            table.sort(sortingTable, ysort)

            for _, sprite in ipairs(sortingTable) do
                spriteBatch:add(sprite.x, sprite.y, 0, camera.scale, camera.scale)
            end
        end
    end

    love.graphics.draw(spriteBatch, 0, 0)

    love.graphics.print(love.timer.getFPS() .. " FPS")
end
