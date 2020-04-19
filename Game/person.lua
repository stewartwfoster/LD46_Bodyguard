require("animated_object")
require("bodyparts")
require("utils")

person = animated_object:extend()

function person:new(x, y, width, height, animations, ismouse, type, assassin)
    self.super.new(self, x, y, width, height, animations, ismouse)

    self.walkspeed = math.random(70, 120)
    self.threshold = 5

    self.type = type -- type is vip, assassin, or random

    self.bodypart_types = {"head", "face", "torso", "legs", "hands", "special"}
    self.bodypart_message_types = {"head", "face", "torso", "legs"}
    self.bodypart_message_types_remaining = {}
    self.bodyparts = {}

    self:generate_bodyparts()
    if self.type == "civilian" then
        while (self:is_same_person(assassin)) do
            self:generate_bodyparts()
        end
    end

    self.goal = nil
    self:setanim("idle")

    self.standing_timer = 0
    self.standing_time = 0
    self.standing_callback = nil
end

function person:stand(time, callback)
    self.standing_timer = 0
    self.standing_time = time
    self.standing_callback = callback
end

function person:random_position(minx, maxx, miny, maxy)
    self.x = love.math.random() * (maxx - minx) + minx
    self.y = love.math.random() * (maxy - miny) + miny
end

function person:generate_bodyparts()
    self.bodyparts = {
        hat = nil,
        head = bodyparts.head[math.random(#bodyparts.head)],
        face = bodyparts.face[math.random(#bodyparts.face)],
        torso = bodyparts.torso[math.random(#bodyparts.torso)],
        legs = bodyparts.legs[math.random(#bodyparts.legs)],
        hands = bodyparts.hands[math.random(#bodyparts.hands)]
    }

    if self.type == "vip" then
        self.bodyparts.special = bodyparts.special[1]
    elseif self.type == "assassin" then
        --self.bodyparts.special = bodyparts.special[2]
    end
end

function person:generate_radio_message()
    -- generate a radio message describing this person
    if #self.bodypart_message_types_remaining == 0 then
        self.bodypart_message_types_remaining = shuffle(deepcopy(self.bodypart_message_types))
    end

    local type_num = math.random(#self.bodypart_message_types_remaining)
    local type = self.bodypart_message_types_remaining[type_num]
    table.remove(self.bodypart_message_types_remaining, type_num)

    local message = "the assassin "
    local bodypart_message = self.bodyparts[type].messages[math.random(#self.bodyparts[type].messages)]
    if type == "head" then
        message = message .. "has " .. bodypart_message
    elseif type == "face" then
        message = message .. "is feeling " .. bodypart_message
    elseif type == "torso" then
        message = message .. "is wearing a " .. bodypart_message
    elseif type == "legs" then
        message = message .. "is wearing " .. bodypart_message
    end

    return message
end

function person:setgoal(x, y, callback)
    self.goal = {x = x, y = y, callback = callback}

end

function person:removegoal()
    self.goal = nil
end

function person:update(dt)
    -- move towards goal
    if self.goal then
        if self.current_anim_name == "idle" then
            self:setanim("walk")
        end

        if math.abs(self.goal.x - self.x) > self.threshold then
            if self.goal.x > self.x then
                self.x = self.x + self.walkspeed * dt
                if self.isflipped then self:flip() end
            elseif self.goal.x < self.x then
                self.x = self.x - self.walkspeed * dt
                if not self.isflipped then self:flip() end
            end
        end

        if math.abs(self.goal.y - self.y) > self.threshold then
            if self.goal.y > self.y then
                self.y = self.y + self.walkspeed * dt
            elseif self.goal.y < self.y then
                self.y = self.y - self.walkspeed * dt
            end
        end


        if (math.abs(self.goal.x - self.x) <= self.threshold) and (math.abs(self.goal.y - self.y) <= self.threshold) then
            -- we have to remove the goal before calling the callback, just in case the callback makes a new goal
            local callback = self.goal.callback
            self:removegoal()
            callback(self)
        end
    end

    if not self.goal then
        if self.current_anim_name == "walk" then
            self:setanim("idle")
        end

        self.standing_timer = self.standing_timer + dt
        if self.standing_timer >= self.standing_time then
           self.standing_timer = 0
           self.standing_time = 0
            if self.standing_callback then
                self.standing_callback(self) 
            end
        end
    end

    self:update_anim(dt)
end

function person:is_same_person(other_person)
    local same = true
    for i,v in pairs(self.bodypart_message_types) do
        if self.bodyparts[v] ~= other_person.bodyparts[v] then
            same = false
        end
    end

    return same
end

function person:draw()
    -- draw the body parts
    if self.current_anim then
        local scale_x, scale_y = 1, 1
        local x_offset = 0
        if self.isflipped then
            scale_x, scale_y = -1, 1
            x_offset = self.width
        end

        -- draw each bodypart
        for i,v in pairs(self.bodypart_types) do
            if self.bodyparts[v] then
                local bodypart_color = self.bodyparts[v].color
                local bodypart_img = self.bodyparts[v].animation[self.current_anim_name].real_images[self.current_image][self.current_bobble]
                love.graphics.setColor(bodypart_color[1], bodypart_color[2], bodypart_color[3])
                love.graphics.draw(bodypart_img, self.x + x_offset, self.y, 0, scale_x, scale_y)
            end
        end
    end
end

function person:intersect(x, y)
    return x >= self.x+16 and x <= self.x-24 + self.width and y >= self.y+8 and y <= self.y + self.height-7
end