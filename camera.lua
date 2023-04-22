Camera = {
    VIEW_WIDTH = 800,
    VIEW_HEIGHT = 500,
}

Camera.new = function()
    local newCamera = {
        scale = 1,
        offsetX = 0,
        offsetY = 0,
    }

    newCamera.resize = function(self, width, height)
        local widthScale = width / Camera.VIEW_WIDTH
        local heightScale = height / Camera.VIEW_HEIGHT
        self.scale = math.min(widthScale, heightScale)

        self.scale = math.max(math.floor(self.scale), 1)

        self.offsetX = math.floor((width - self.scale * Camera.VIEW_WIDTH) / 2)
        self.offsetY = math.floor((height - self.scale * Camera.VIEW_HEIGHT) / 2)
    end

    return newCamera
end