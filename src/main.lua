--Love2D Test of Musico
local Musico = require('Musico')
local w = 0

function love.keypressed(key)
end

function love.mousepressed(x, y, button)
end
local played = false

function love.mousereleased(_, _, button)
    if not played then
        print('play!')
        played = true
        Musico.loadSong('shanty')
        Musico.start()
    end
end

function love.mousemoved(x)
    Musico.setIntensity((x / w) - 1)
end

function love.load()
    Musico.load()
    w = love.graphics.getDimensions() / 2
end

function love.update(dt)
    Musico.update(dt)
end

function love.draw()
    love.graphics.print(math.floor(Musico.getIntensity() * 100), 10, 10)
end
