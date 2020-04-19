require("scene")
require("game")
require("animated_object")

main_menu = scene:extend()

function main_menu:new(width, height)
    self.super.new(self, width, height)

    self.title = animated_object(self.width / 2 - 275, self.height / 15, 550, 140, {
        idle = {
            images = {{"title1.png", "title2.png"}},
            time = 0.2
        }
    })
    self.title:setanim("idle")

    self.subtitle = animated_object(self.width / 2 - 100, self.height - 80, 280, 60, {
        idle = {
            images = {{"subtitle.png", "subtitle2.png"}},
            time = 0.2
        }
    })
    self.subtitle:setanim("idle")

    self.title_image = animated_object(self.width / 2 - 150, self.height / 2 - 150, 300, 300, {
        idle = {
            images = {{"title_image1_v2.png", "title_image2.png"}},
            time = 0.2
        }
    })
    self.title_image:setanim("idle")

    self.click = animated_object(self.width / 2 - 275, self.height - 160, 550, 70, {
        idle = {
            images = {{"anywhere1.png", "anywhere2.png"}},
            time = 0.2
        }
    })
    self.click:setanim("idle")

    self.bricks = {
        animated_object(100, 200, 90, 50, {
            idle = {
                images = {{"bricks1_1.png", "bricks1_2.png"}},
                time = 0.2
            }
        }),
        animated_object(600, 400, 90, 50, {
            idle = {
                images = {{"bricks1_1.png", "bricks1_2.png"}},
                time = 0.2
            }
        })
    }

    for i,v in pairs(self.bricks) do
        v:setanim("idle")
    end


    love.mouse.setVisible(false)
    self.cursor = animated_object(0, 0, 0, 0, {
        idle = {
            images = {{"crosshair1.png", "crosshair2.png"}},
            time = 0.2
        }
    }, true)
    self.cursor:setanim("idle")

end

function main_menu:update(dt)
    x, y = love.mouse.getPosition()

    -- screenshake
    if self.screenshake_time < self.screenshake_duration then
        self.screenshake_time = self.screenshake_time + dt
    end

    self.title:update_anim(dt)
    self.subtitle:update_anim(dt)
    self.title_image:update_anim(dt)
    self.click:update_anim(dt)

    for i,v in pairs(self.bricks) do
        v:update_anim(dt)
    end

    self.cursor:update_anim(dt)

    return self
end

function main_menu:draw()
    love.graphics.setBackgroundColor(59/255, 68/255, 89/255, 1)

    if self.screenshake_time < self.screenshake_duration then
        local dx = love.math.random(-self.screenshake_magnitude, self.screenshake_magnitude)
        local dy = love.math.random(-self.screenshake_magnitude, self.screenshake_magnitude)
        love.graphics.translate(dx, dy)
    end

    self.title:draw()
    self.subtitle:draw()
    self.title_image:draw()
    self.click:draw()

    for i,v in pairs(self.bricks) do
        v:draw()
    end

    self.cursor:draw()
    
    return self
end

function main_menu:mousepressed(x, y)
    return game(self.width, self.height, self, 1)
end

function main_menu:key_pressed(key)
    return self
end

function main_menu:key_released(key)
    return self
end

