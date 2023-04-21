require "camera"

function love.conf(t)
    t.window.width = Camera.VIEW_WIDTH
    t.window.height = Camera.VIEW_HEIGHT
    t.window.vsync = false
    t.window.resizable = true
end