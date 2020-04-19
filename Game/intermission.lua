require("scene")
require("radio")
require("animated_object")
require("fonts")

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

    self:screenshake()

    self.msg = ""
    self.title_msg = ""
    self.title_msg_color = {1, 1, 1, 1}
    self.level_msg = "LEVEL " .. self.level
    self.center_image_idle = {}
    

    if self.result == "innocent" then
        self.msg = "you killed an innocent bystander"
        self.center_image_idle = {{"innocent_kill_image.png", "innocent_kill_image2.png"}}
        self.title_msg = "FAILURE"
        self.title_msg_color = {188/255, 45/255, 64/255}
    elseif self.result == "vip" then
        self.msg = "you killed the vip"
        self.center_image_idle = {{"vip_kill_image.png", "vip_kill_image2.png"}}
        self.title_msg = "FAILURE"
        self.title_msg_color = {188/255, 45/255, 64/255}
    elseif self.result == "stabbed" then
        self.msg = "the vip was stabbed to death"
        self.center_image_idle = {{"vip_stab_image.png", "vip_stab_image2.png"}}
        self.title_msg = "FAILURE"
        self.title_msg_color = {188/255, 45/255, 64/255}
    elseif self.result == "win" then
        self.msg = "well done you killed the assassin"
        self.center_image_idle = {{"assassin_kill_image.png", "assassin_kill_image2.png"}}
        self.title_msg = "SUCCESS"
        self.title_msg_color = {186/255, 227/255, 143/255}
    end

    self.center_image = animated_object(self.width / 2 - 150, self.height / 2 - 150, 300, 300, {
        idle = {
            images = self.center_image_idle,
            time = 0.2
        }
    })
    self.center_image:setanim("idle")
    
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

    -- screenshake
    if self.screenshake_time < self.screenshake_duration then
        self.screenshake_time = self.screenshake_time + dt
    end

    for i,v in pairs(self.bricks) do
        v:update_anim(dt)
    end

    self.center_image:update_anim(dt)
    self.radio:update(dt)

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

    love.graphics.setFont(fonts.radio_big[self.radio.current_font])
    local r, g, b = unpack(self.title_msg_color)
    love.graphics.setColor(r, g, b, 1)
    love.graphics.print(self.title_msg, self.width / 2 - fonts.radio_big[self.radio.current_font]:getWidth(self.title_msg) / 2, self.height / 10)

    
    love.graphics.setFont(fonts.radio[self.radio.current_font])
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.level_msg, self.width / 2 - fonts.radio[self.radio.current_font]:getWidth(self.level_msg) / 2, self.height / 6 + 10)

    self.center_image:draw()
    self.radio:draw_all()
    
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

