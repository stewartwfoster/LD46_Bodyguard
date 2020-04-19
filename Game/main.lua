

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    require("scene")
    require("main_menu")

    WIDTH, HEIGHT = 800, 600
    scenes = {}
    cur_scene = main_menu(WIDTH, HEIGHT)

    love.window.setMode(WIDTH, HEIGHT, {})
    love.window.setTitle("Bodyguard")

    
end

function love.update(dt)
    cur_scene = cur_scene:update(dt)
end

function love.draw()
    cur_scene = cur_scene:draw()
end

function love.keypressed(key)
    cur_scene = cur_scene:keypressed(key)
end

function love.keyreleased(key)
    cur_scene = cur_scene:keyreleased(key)
end

function love.mousepressed(x, y)
    cur_scene = cur_scene:mousepressed(x, y)
end