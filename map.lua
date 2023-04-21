Map = {
    GRID_SIZE = 20,
    GRID_CENTER_X = 400,
    GRID_CENTER_Y = 300,
    GRID_MAX_Z = 2,
    GRID_Z_SHADE_MIN = 0.7,
}

Map.GRID_Z_SHADE_STEP = (1.0 - Map.GRID_Z_SHADE_MIN) / Map.GRID_MAX_Z
Map.new = function()
    local newMap = {
        grid = {},
        getGridTile = function(self, x, y, z)
            x = math.floor(x)
            y = math.floor(y)
            z = math.floor(z)

            if x < 1 or x > Map.GRID_SIZE or
               y < 1 or y > Map.GRID_SIZE or
               z < 1 or z > Map.GRID_SIZE then
                return 0
            end
            
            return self.grid[z][x][y]
        end
    }

    -- Initialize the new map to all air.
    for z = 1, Map.GRID_SIZE do
        newMap.grid[z] = {}
        for x = 1, Map.GRID_SIZE do
            newMap.grid[z][x] = {}
            for y = 1, Map.GRID_SIZE do
                newMap.grid[z][x][y] = 0
            end
        end
    end

    return newMap
end