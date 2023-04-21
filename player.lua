Player = {
    SPEED = 3,
    SIZE = 0.9,
}

Player.new = function()
    local newPlayer = {
        x = 0,
        y = 0,
        z = 2,
    }
        
    newPlayer.move = function(self, map, dx, dy, dt)
        local currentSpeed = love.keyboard.isDown("lshift") and 2 or 1
        currentSpeed = currentSpeed * Player.SPEED

        if dx ~= 0 or dy ~= 0 then
            local magnitude = math.sqrt(dx ^ 2 + dy ^ 2)
            dx, dy = dx / magnitude, dy / magnitude
            
            local nextX = self.x + currentSpeed * dt * dx
            local collisionOffsetX = dx > 0 and Player.SIZE or 0
            if map:getGridTile(nextX + collisionOffsetX, self.y, self.z) ~= 0 or
               map:getGridTile(nextX + collisionOffsetX, self.y + Player.SIZE, self.z) ~= 0 then
                nextX = self.x
            end
            self.x = nextX

            local nextY = self.y + currentSpeed * dt * dy
            local collisionOffsetY = dy > 0 and Player.SIZE or 0
            if map:getGridTile(self.x, nextY + collisionOffsetY, self.z) ~= 0 or
               map:getGridTile(self.x + Player.SIZE, nextY + collisionOffsetY, self.z) ~= 0 then
                nextY = self.y
            end
            self.y = nextY
        end
    end
    
    return newPlayer
end