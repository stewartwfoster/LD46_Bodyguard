function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    require("scene")
    require("main_menu")
    require("animated_object")
    require("sounds")

    WIDTH, HEIGHT = 800, 600
    scenes = {}
    cur_scene = main_menu(WIDTH, HEIGHT)

    love.window.setMode(WIDTH, HEIGHT, {})
    love.window.setTitle("LD46 - Bodyguard")

    love.mouse.setVisible(false)
    cursor = animated_object(0, 0, 0, 0, {
        idle = {
            images = {{"crosshair1.png", "crosshair2.png"}},
            time = 0.2
        }
    }, true)
    cursor:setanim("idle")

    music_toggle = animated_object(WIDTH - 50, 40, 40, 40, {
        idle = {
            images = {{"musicnote1.png", "musicnote2.png"}},
            time = 0.2
        },
        disabled = {
            images = {{"musicnote1_off.png", "musicnote2_off.png"}},
            time = 0.2
        }
    })
    music_toggle:setanim("idle")

    music_active = true
    music.track1:play()
end

function love.update(dt)
    cur_scene = cur_scene:update(dt)

    music_toggle:update_anim(dt)
    cursor:update_anim(dt)
end

function love.draw()
    cur_scene = cur_scene:draw()

    music_toggle:draw()
    cursor:draw()
end

function love.keypressed(key)
    cur_scene = cur_scene:keypressed(key)
end

function love.keyreleased(key)
    cur_scene = cur_scene:keyreleased(key)
end

function love.mousepressed(x, y)
    if music_toggle:intersect(x, y) then
        music_active = not music_active
        if music_active then
            music.track1:play()
            music_toggle:setanim("idle")
        else
            music.track1:stop()
            music_toggle:setanim("disabled")
        end
    else
        cur_scene = cur_scene:mousepressed(x, y)
    end
end