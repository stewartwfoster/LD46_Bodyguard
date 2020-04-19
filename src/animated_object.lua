object = require("object")
animated_object = object:extend()

function animated_object:new(x, y, width, height, animations, ismouse)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.animations = animations -- {idle = {images = {{"", ""}, {"", ""}}, time = 0.5}}
    -- turn the file names in to Images
    for i,v in pairs(self.animations) do -- for each animation
        v.real_images = {}
        for j,w in pairs(v.images) do -- for each image
            v.real_images[j] = {}
            for k, x in pairs(w) do -- for each bobble
                table.insert(v.real_images[j], love.graphics.newImage("images/" .. x))
            end
        end
    end

    self.current_anim = nil
    self.current_anim_name = nil
    self.current_image = nil
    self.animtime = 0

    self.bobbletime = 0
    self.maxbobbletime = 0.2
    self.current_bobble = nil

    self.ismouse = ismouse or false
    self.mouserotspeed = 0.5
    self.mouserot = 0
    self.isflipped = false
end

function animated_object:flip()
    self.isflipped = not self.isflipped
end

function animated_object:setanim(anim_name)
    self.animtime = 0
    self.current_anim = self.animations[anim_name]
    self.current_anim_name = anim_name
    self.current_image = 1
    self.current_bobble = 1
end

function animated_object:update_anim(dt)
    if self.ismouse then
        self.mouserot = self.mouserot + self.mouserotspeed * dt
    end

    if self.current_anim then
        self.animtime = self.animtime + dt
        self.bobbletime = self.bobbletime + dt
        if self.bobbletime >= self.maxbobbletime then
            self.bobbletime = 0
            self.current_bobble = self.current_bobble % #self.current_anim.images[self.current_image] + 1
        end

        if self.animtime >= self.current_anim.time then
            self.animtime = 0
            self.current_image = self.current_image % #self.current_anim.images + 1
        end
    end
end

function animated_object:draw()
    if self.current_anim then
        love.graphics.setColor(1, 1, 1, 1)
        if self.ismouse then
            local cursor_img = self.current_anim.real_images[self.current_image][self.current_bobble]
            local x, y = love.mouse.getPosition()
            love.graphics.draw(cursor_img, x, y, self.mouserot, 1, 1, cursor_img:getWidth()/2, cursor_img:getHeight()/2)
        else 
            local scale_x, scale_y = 1, 1
            local x_offset = 0
            if self.isflipped then
                scale_x, scale_y = -1, 1
                x_offset = self.width
            end
            love.graphics.draw(self.current_anim.real_images[self.current_image][self.current_bobble], self.x + x_offset, self.y, 0, scale_x, scale_y)
        end
        
    end
end

function animated_object:intersect(x, y)
    return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end