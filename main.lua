function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end

		-- if love.timer then love.timer.sleep(0.001) end
	end
end


grass = love.graphics.newImage("grass.png")

love.window.setVSync(0)

blockWidth = grass:getWidth()
blockHeight = grass:getHeight()
blockDepth = blockHeight / 2

gridSize = 20
grid = {}
for z = 1, gridSize do
    grid[z] = {}
    for x = 1, gridSize do
        grid[z][x] = {}
        for y = 1, gridSize do
            grid[z][x][y] = 0
        end
    end
end

for x = 1, gridSize do
    for y = 1, gridSize do
        grid[1][x][y] = 1
    end
end

for x = 1, gridSize/2 do
    for y = 1, gridSize/2 do
        grid[2][x][y] = 1
    end
end

gridCenterX = 400
gridCenterY = 300

grid[2][2][4] = 0
grid[2][6][5] = 0

spriteBatch = love.graphics.newSpriteBatch(grass)

playerX = 0
playerY = 0
playerZ = 2
playerSpeed = 20

function ysort(a, b)
    return a.y < b.y
end

function love.update(dt)
    dx = 0
    dy = 0
    if love.keyboard.isDown("up") then
        dy = dy - 1
    end

    if love.keyboard.isDown("down") then
        dy = dy + 1
    end

    if love.keyboard.isDown("left") then
        dx = dx - 1
    end

    if love.keyboard.isDown("right") then
        dx = dx + 1
    end
    
    if dx ~= 0 or dy ~= 0 then
        dy = dy/2
        magnitude = math.sqrt(dx^2 + dy^2)
        dx, dy = dx/magnitude, dy/magnitude
        playerX = playerX + playerSpeed * dt * dx
        playerY = playerY + playerSpeed * dt * dy
    end
end

function love.draw()
    -- love.graphics.draw(grass, 0, 0)

    spriteBatch:clear()
    for z = 1, gridSize do
        if z ~= playerZ then
            for x = 1, gridSize do
                for y = 1, gridSize do
                    if grid[z][x][y] == 1 then
                        -- love.graphics.draw(
                        spriteBatch:add(
                            gridCenterX + ((y-x) * (blockWidth / 2)),
                            gridCenterY + ((x+y) * (blockDepth / 2)) - (blockDepth * (gridSize / 2)) - blockDepth * z
                        )
                    end
                end
            end
        else
            
        sortingTable = {}
        
        for x = 1, gridSize do
            for y = 1, gridSize do
                if grid[z][x][y] == 1 then
                    table.insert(sortingTable, {
                        x=gridCenterX + ((y-x) * (blockWidth / 2)),
                        y=gridCenterY + ((x+y) * (blockDepth / 2)) - (blockDepth * (gridSize / 2)) - blockDepth * z})
                end
            end
        end

        table.insert(sortingTable, {
            x=playerX,
            y=playerY - blockDepth * z})
        
        table.sort(sortingTable, ysort)
        
        for _, sprite in ipairs(sortingTable) do
            spriteBatch:add(sprite.x, sprite.y)
        end

        end
    end
 
    love.graphics.draw(spriteBatch, 0, 0)
    
    love.graphics.print(love.timer.getFPS() .. " FPS")
end