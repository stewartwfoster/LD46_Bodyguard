require("scene")
require("radio")
require("animated_object")

intermission = scene:extend()

function intermission:new(width, height, previous_scene, menu_scene, level, gameplaytime, result)
    self.super.new(self, width, height)

    self.level = level
    self.gameplaytime = gameplaytime
    self.result = result
    self.previous_scene = previous_scene
    self.menu_scene = menu_scene

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

    -- RADIO STUFF
    self.radiobox = animated_object(20, self.height - 95, 610, 95, {
        idle = {
            images = {{"textbox.png", "textbox2.png"}},
            time = 0.2
        }
    })
    self.radiobox:setanim("idle")

    self.radio = radio(self.width - 150, self.height - 220, 150, 220, {
        idle = {
            images = {{"radio/radio.png", "radio/radio2.png"}},
            time = 0.2
        },
        transmit = {
            images = {
                {"radio/radio.png", "radio/radio2.png"},
                {"radio/radio_anim_1_1.png", "radio/radio_anim_1_2.png"},
                {"radio/radio_anim_2_1.png", "radio/radio_anim_2_2.png"},
                {"radio/radio_anim_3_1.png", "radio/radio_anim_3_2.png"},
                {"radio/radio_anim_4_1.png", "radio/radio_anim_4_2.png"},
                {"radio/radio_anim_5_1.png", "radio/radio_anim_5_2.png"},
                {"radio/radio_anim_6_1.png", "radio/radio_anim_6_2.png"},
                {"radio/radio_anim_7_1.png", "radio/radio_anim_7_2.png"},
            },
            time = 0.5
        }
    }, false, self.radiobox)
    self.radio:setanim("idle")

    love.mouse.setVisible(false)
    self.cursor = animated_object(0, 0, 0, 0, {
        idle = {
            images = {{"crosshair1.png", "crosshair2.png"}},
            time = 0.2
        }
    }, true)
    self.cursor:setanim("idle")

    self:screenshake()

    self.msg = ""
    self.center_image = nil -- set center image to a nice image depicting what happened

    if self.result == "innocent" then
        self.msg = "you killed an innocent bystander"
    elseif self.result == "vip" then
        self.msg = "you killed the vip"
    elseif self.result == "stabbed" then
        self.msg = "the vip was stabbed to death"
    elseif self.result == "win" then
        self.msg = "well done you killed the assassin"
    end
    
    self.can_click = false
    self.radio:display_message(self.msg:upper(), function(radio) 
        radio:display_message("CLICK ANYWHERE TO CONTINUE", function() end, true)
        self.can_click = true
    end)

end

function intermission:screenshake(duration, magnitude)
    self.screenshake_time = 0
    self.screenshake_duration = duration or 1
    self.screenshake_magnitude = magnitude or 5
    sounds.stab_attempt:play()
end

function intermission:update(dt)
    x, y = love.mouse.getPosition()

    -- screenshake
    if self.screenshake_time < self.screenshake_duration then
        self.screenshake_time = self.screenshake_time + dt
    end

    for i,v in pairs(self.bricks) do
        v:update_anim(dt)
    end

    self.radio:update(dt)

    self.cursor:update_anim(dt)

    return self
end

function intermission:draw()
    love.graphics.setBackgroundColor(59/255, 68/255, 89/255, 1)

    if self.screenshake_time < self.screenshake_duration then
        local dx = love.math.random(-self.screenshake_magnitude, self.screenshake_magnitude)
        local dy = love.math.random(-self.screenshake_magnitude, self.screenshake_magnitude)
        love.graphics.translate(dx, dy)
    end

    for i,v in pairs(self.bricks) do
        v:draw()
    end

    self.radio:draw_all()

    self.cursor:draw()
    
    return self
end

function intermission:mousepressed(x, y)
    if self.can_click then
        if self.result == "win" then
            local game_scene = self.previous_scene
            self.previous_scene:new(game_scene.width, game_scene.height, self.menu_scene, game_scene.level + 1)
            return self.previous_scene
        else
            self.menu_scene:screenshake(0.5, 3)
            return self.menu_scene
        end
    end
    return self
end

function intermission:key_pressed(key)
    return self
end

function intermission:key_released(key)
    return self
end

