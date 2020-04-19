require("scene")
require("person")
require("radio")
require("sounds")
require("intermission")
require("fonts")

game = scene:extend()

function game:new(width, height, previous_scene, level)
    self.super.new(self, width, height)

    self.previous_scene = previous_scene

    self.level = level
    print("starting level", self.level)

    self.num_civilians = math.floor(get_num_civilians(self.level))
    self.gameplaytime = 0
    self.game_started = false

    self.canstabtime = 35 -- can stab after 35 seconds
    self.stab_cooldown = 5
    self.stab_cooldown_timer = 0
    self.stab_attempt_time = 120 -- attempts a stab after 120 seconds
    self.on_stab_cooldown = false
    self.can_shoot = false

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


    -- person stuff here

    -- either find a new goal or stand still
    local function setnextgoal(person)
        local stand = love.math.random() > 0.7
        if stand then
            if person.type == "assassin" and self.gameplaytime > self.stab_attempt_time then
                person:stand(1, setnextgoal) -- assassin stands for less time
            else
                person:stand(math.random(1, 4), setnextgoal)
            end
        else
            if person.type == "assassin" and self.gameplaytime > self.stab_attempt_time then
                person:setgoal(self.vip.x, self.vip.y, setnextgoal) -- assassin targets vip
            else
                person:setgoal(math.random(0, 720), math.random(0, 400), setnextgoal)
            end
        end
    end


    self.people = {}

    -- create an assassin
    self.assassin = person(self.width/2 - 40, self.height/2 - 60, 80, 120, {
        idle = {
            images = {{"person1.png", "person2.png"}},
            time = 0.2
        },
        walk = {
            images = {
                {"person1_walk1_1.png", "person1_walk1_2.png"}, 
                {"person1_walk3_1.png", "person1_walk3_2.png"}, 
                {"person1_walk2_1.png", "person1_walk2_2.png"}, 
                {"person1_walk3_1.png", "person1_walk3_2.png"}
            }, 
            time = 0.2
        }
    }, false, "assassin")
    self.assassin:random_position(0, 720, 0, 400)
    


    -- create a VIP
    self.vip = person(self.width/2 - 40, self.height/2 - 60, 80, 120, {
        idle = {
            images = {{"person1.png", "person2.png"}},
            time = 0.2
        },
        walk = {
            images = {
                {"person1_walk1_1.png", "person1_walk1_2.png"}, 
                {"person1_walk3_1.png", "person1_walk3_2.png"}, 
                {"person1_walk2_1.png", "person1_walk2_2.png"}, 
                {"person1_walk3_1.png", "person1_walk3_2.png"}
            }, 
            time = 0.2
        }
    }, false, "vip")
    self.vip:random_position(0, 720, 0, 400)
    


    -- create civilians
    for i = 1, self.num_civilians do
        table.insert(self.people, 
        person(self.width/2 - 40, self.height/2 - 60, 80, 120, {
            idle = {
                images = {{"person1.png", "person2.png"}},
                time = 0.2
            },
            walk = {
                images = {
                    {"person1_walk1_1.png", "person1_walk1_2.png"}, 
                    {"person1_walk3_1.png", "person1_walk3_2.png"}, 
                    {"person1_walk2_1.png", "person1_walk2_2.png"}, 
                    {"person1_walk3_1.png", "person1_walk3_2.png"}
                }, 
                time = 0.2
            }
        }, false, "civilian", self.assassin))
        self.people[i]:random_position(0, 720, 0, 400)
    end
    
    table.insert(self.people, self.assassin)
    table.insert(self.people, self.vip)
    


    -- generate radio help messages
    
    local function give_new_message(radio)
        -- wait a random amount of time then display message
        function display_new_message(radio)
            local assassin_message = self.assassin:generate_radio_message()
            radio:display_message(radio:create_message(assassin_message:upper()), give_new_message)
        end

        radio:disable(love.math.random()*3+1, display_new_message)
    end


    local function start_game(radio)
        self.can_shoot = true
        radio.text_display_interval = 0.05
        radio.erase_time = 3

        for i,v in pairs(self.people) do
            setnextgoal(v)
        end

        give_new_message(radio)
        self.game_started = true
    end

    self:screenshake(0.7, 3)

    -- lets speed up the intro text
    if level > 1 then
        self.radio.text_display_interval = 0.01
        self.radio.erase_time = 1
    end

    self.radio:display_message("AN ASSASSIN IS HERE TO KILL THE VIP", function(radio)
        radio:display_message("YOUR JOB IS TO KILL THE ASSASSIN AT ALL COSTS AND KEEP THE VIP ALIVE", start_game)
    end)

end

function game:update(dt)
    if self.game_started then
        self.gameplaytime = self.gameplaytime + dt
    end

    -- screenshake
    if self.screenshake_time < self.screenshake_duration then
        self.screenshake_time = self.screenshake_time + dt
    end

    -- stab cooldown
    if self.on_stab_cooldown then
        self.stab_cooldown_timer = self.stab_cooldown_timer + dt
        if self.stab_cooldown_timer >= self.stab_cooldown then
            self.on_stab_cooldown = false
            self.stab_cooldown_timer = 0
        end
    end

    self.radio:update(dt)

    for i,v in pairs(self.people) do
        v:update(dt)
    end
    table.sort(self.people, function(a, b)
        return a.y < b.y
    end)

    -- check if the assassin is touching the VIP here
    if (not self.on_stab_cooldown) and (self.vip:intersect(self.assassin.x + self.assassin.width / 2, self.assassin.y + self.assassin.height / 2)) then
        -- stab after a certain amount of time, and bad luck
        local canstab = self.gameplaytime > self.canstabtime
        if canstab then
            local stabchance = chancetostab(self.gameplaytime, self.canstabtime)
            local willstab = love.math.random() < stabchance

            self:screenshake(0.5, 0.5)

            print("stab chance:", stabchance, ", success?", willstab)
            self.on_stab_cooldown = true
            self.stab_cooldown_timer = 0

            if willstab then
                sounds.stab:play()
                return intermission(self.width, self.height, self, self.previous_scene, self.level, self.gameplaytime, "stabbed")
            end
        else
            --print("tried to stab too early")
        end
    end

    return self
end

function game:draw()
    love.graphics.setBackgroundColor(59/255, 68/255, 89/255, 1)

    if self.screenshake_time < self.screenshake_duration then
        local dx = love.math.random(-self.screenshake_magnitude, self.screenshake_magnitude)
        local dy = love.math.random(-self.screenshake_magnitude, self.screenshake_magnitude)
        love.graphics.translate(dx, dy)
    end
   
    for i,v in pairs(self.people) do
        v:draw()
    end
    self.radio:draw_all()


    love.graphics.setFont(fonts.radio[self.radio.current_font])
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.print("LEVEL " .. self.level, 10, 10)
    local civilians_msg = (self.num_civilians + 1) .. " CIVILIANS"
    love.graphics.print(civilians_msg, self.width - fonts.radio[self.radio.current_font]:getWidth(civilians_msg) - 10, 10)

    local time_msg = math.floor(self.gameplaytime)
    if self.gameplaytime < self.canstabtime then
        love.graphics.setColor(186/255, 227/255, 143/255, 1)
    else
        love.graphics.setColor(188/255, 45/255, 64/255, 1)
    end
    love.graphics.print(time_msg, self.width / 2 - fonts.radio[self.radio.current_font]:getWidth(time_msg), 10)

    return self
end

function game:mousepressed(x, y)
    if sounds.gunshot:isPlaying() then return self end
    if not self.can_shoot then return self end

    sounds.gunshot:play()
    self:screenshake(0.5)

    -- sort them by depth again, just in case
    table.sort(self.people, function(a, b)
        return a.y < b.y
    end)

    for i,v in pairs(self.people) do
        if v:intersect(x, y) then
            -- we clicked on someone
            if v.type == "assassin" then
                print("You win!")
                return intermission(self.width, self.height, self, self.previous_scene, self.level, self.gameplaytime, "win")
            elseif v.type == "civilian" then
                print("You killed an innocent!")
                return intermission(self.width, self.height, self, self.previous_scene, self.level, self.gameplaytime, "innocent")
            elseif v.type == "vip" then
                print("You killed the VIP!!")
                return intermission(self.width, self.height, self, self.previous_scene, self.level, self.gameplaytime, "vip")
            end
        end
    end

    return self
end

function game:key_pressed(key)
    return self
end

function game:key_released(key)
    return self
end