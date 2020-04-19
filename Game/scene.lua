object = require("object")
scene = object:extend()

require("sounds")

function scene:new(width, height)
    self.width = width
    self.height = height
    self.entities = {}

    self.screenshake_time = 0
    self.screenshake_duration = -1
    self.screenshake_magnitude = 0
end

function scene:screenshake(duration, magnitude)
    self.screenshake_time = 0
    self.screenshake_duration = duration or 1
    self.screenshake_magnitude = magnitude or 5
    sounds.stab_attempt:play()
end

function scene:update(dt)
    return self
end

function scene:draw()
end

function scene:keypressed(key)
    return self
end

function scene:keyreleased(key)
    return self
end

function scene:mousepressed(x, y)
    return self
end