require("animated_object")
require("sounds")
require("fonts")

radio = animated_object:extend()
radio.prefixes = {
    "OUR SOURCES TELL US",
    "OUR INFORMANT TELLS US",
    "SOURCES SAY",
    "IT SEEMS LIKE",
    "IM HEARING THAT",
    "HEAD OFFICE TELLS ME",
    "OUR MAN ON THE INSIDE SAYS",
    "A FRIENDLY SPY HAS REPORTED",
    "AN ANONYMOUS TIP SAYS",
    "THE FEDS TELL ME"
}



function radio:new(x, y, width, height, animations, ismouse, radiobox)
    self.super.new(self, x, y, width, height, animations, ismouse)

    self.radiobox = radiobox

    self.text = ""
    self.goal_text = ""
    self.displaying_text = false
    self.waiting_for_text = false
    self.erase_timer = 0
    self.erase_time = 3
    self.dont_erase = true
    self.text_callback = nil

    self.text_bobble_time = 0
    self.text_bobble_interval = 0.2

    self.radio_disabled_time = 0
    self.radio_disabled_goal = 0
    self.radio_disabled = false
    self.radio_disable_callback = nil

    self.text_display_time = 0
    self.text_display_interval = 0.05
    self.chars_displayed = 0

    
    self.current_font = 1
end

function radio:create_message(text)
    return radio.prefixes[math.random(#radio.prefixes)] .. " " .. text
end

function radio:disable(time, callback)
    self.radio_disabled_goal = time
    self.radio_disabled_time = 0
    self.radio_disabled = true
    self.radio_disabled_callback = callback
    self.displaying_text = false
    self:setanim("idle")
end

function radio:display_message(text, callback, dont_erase)
    -- display a voice message above the radio
    self.chars_displayed = 0
    self.text = ""
    self.goal_text = text
    self.displaying_text = true
    self.dont_erase = dont_erase or false
    self:setanim("transmit")
    --sounds.radio_static:play()
    
    self.text_callback = callback
end

function radio:update(dt)
    self:update_anim(dt)
    self.radiobox:update_anim(dt)

    -- font bobble timer
    self.text_bobble_time = self.text_bobble_time + dt
    if self.text_bobble_time >= self.text_bobble_interval then
        self.text_bobble_time = 0
        self.current_font = self.current_font % #fonts.radio + 1
    end

    if self.radio_disabled then
        self.radio_disabled_time = self.radio_disabled_time + dt
        if self.radio_disabled_time >= self.radio_disabled_goal then
            self.radio_disabled = false
            self.radio_disabled_time = 0
            if self.radio_disabled_callback then
                self.radio_disabled_callback(self)
            end
        end
    else
        -- text display timer
        if self.goal_text then
            if self.text ~= self.goal_text then
                self.text_display_time = self.text_display_time + dt
                if self.text_display_time >= self.text_display_interval then
                    sounds.radio_beep:play()
                    self.text_display_time = 0
                    self.chars_displayed = self.chars_displayed + 1
                    self.text = self.goal_text:sub(1, self.chars_displayed)
                    -- do we need to make a newline?
                    if (not self.goal_text:match("\n")) and fonts.radio[self.current_font]:getWidth(self.text) > 540 then
                        -- add it to the text and goal text
                        self.chars_displayed = self.chars_displayed + 1
                        self.goal_text = self.goal_text:sub(1, self.chars_displayed - 2) .. "\n" .. self.goal_text:sub(self.chars_displayed-1)
                    end
                end

                if self.text == self.goal_text then
                    -- we just finished displaying the message
                    self.waiting_for_text = true
                    self.erase_timer = 0
                end
            end
        end

        -- erase the text after `erase_time`
        if self.waiting_for_text and not self.dont_erase then
            self.erase_timer = self.erase_timer + dt
            if self.erase_timer >= self.erase_time then
                self.text = ""
                self.goal_text = ""
                self.displaying_text = false
                self.waiting_for_text = false
                self.erase_timer = 0
                self:setanim("idle")
                self.text_callback(self)
            end
        end

    end
end

function radio:draw_all()
    self:draw()
    if self.displaying_text then
        self.radiobox:draw()
    end

    love.graphics.setFont(fonts.radio[self.current_font])
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.text .. " aaaa", 40, 600 - fonts.radio[self.current_font]:getHeight(msg) - 60)
end