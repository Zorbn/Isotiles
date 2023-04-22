require "map"
require "player"
require "camera"

love.graphics.setDefaultFilter("nearest")
local tiles = love.graphics.newImage("tiles.png")

local BLOCK_WIDTH = 32
local BLOCK_HEIGHT = 32
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

local spriteBatch = love.graphics.newSpriteBatch(tiles)
local spritesInTexture = tiles:getWidth() / BLOCK_WIDTH
local spriteBatchQuads = {}
for i = 1, spritesInTexture do
    local texX = (i - 1) * BLOCK_WIDTH
    local quad = love.graphics.newQuad(texX, 0, BLOCK_WIDTH, BLOCK_HEIGHT, tiles)
    spriteBatchQuads[i] = quad
end

local function spriteBatchAddByIndex(i, x, y, sx, sy)
    spriteBatch:add(spriteBatchQuads[i], x, y, 0, sx, sy)
end

local function toScreenPosition(x, y, z)
    local screenX = Map.GRID_CENTER_X + ((y - x) * BLOCK_WIDTH / 2)
    local screenY = Map.GRID_CENTER_Y + ((x + y) * BLOCK_DEPTH / 2) - (BLOCK_DEPTH * Map.GRID_SIZE / 2) - BLOCK_DEPTH * z
    -- screenX = screenX * camera.scale + camera.offsetX
    -- screenY = screenY * camera.scale + camera.offsetY

    return screenX, screenY
end

local function toWorldPosition(screenX, screenY, worldZ)
    local worldX = ((screenY - Map.GRID_CENTER_Y) / BLOCK_DEPTH) - ((screenX - Map.GRID_CENTER_X) / BLOCK_WIDTH) + 11 + worldZ
    local worldY = ((screenY - Map.GRID_CENTER_Y) / BLOCK_DEPTH) + ((screenX - Map.GRID_CENTER_X) / BLOCK_WIDTH) + 10 + worldZ

    return worldX, worldY
end

-- local function toWorldPosition(screenX, screenY, worldZ)
--     -- Undo the translations done to get screenX.
--     local a = (screenX - camera.offsetX) / camera.scale
--     a = a - Map.GRID_CENTER_X
--     a = a * 2 / BLOCK_WIDTH
--     -- a = y - x

--     -- Undo the translations done to get screenY.
--     local b = (screenY - camera.offsetY) / camera.scale
--     b = b - Map.GRID_CENTER_Y
--     b = b + (BLOCK_DEPTH * Map.GRID_SIZE / 2) + BLOCK_DEPTH * worldZ
--     b = b * 2 / BLOCK_DEPTH
--     -- b = x + y

--     local worldX = (b - a) / 2
--     local worldY = (a + b) / 2

--     return worldX, worldY
-- end

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

    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()

    local mouseWorldZ = 2
    local mouseWorldX, mouseWorldY = toWorldPosition(mouseX, mouseY, mouseWorldZ)
    mouseWorldX = mouseWorldX - 0.5
    mouseWorldY = mouseWorldY - 0.5

    if love.mouse.isDown(1) then
        map:setGridTile(mouseWorldX, mouseWorldY, mouseWorldZ, 0)
    end

    if love.mouse.isDown(2) then
        -- Shift the tile up so that it feels as if it is being placed on top
        -- of the face the player clicked on.
        map:setGridTile(mouseWorldX - 1, mouseWorldY - 1, mouseWorldZ, 1)
    end
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
                        local index = 1
                        if x % 7 == 0 or y % 7 == 0 then
                            index = 3
                        end
                        spriteBatchAddByIndex(index, screenX, screenY, camera.scale, camera.scale)
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
                spriteBatchAddByIndex(2, sprite.x, sprite.y, camera.scale, camera.scale)
            end
        end
    end

    love.graphics.draw(spriteBatch, 0, 0)

    love.graphics.print(love.timer.getFPS() .. " FPS")
end
