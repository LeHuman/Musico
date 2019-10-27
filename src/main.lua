--Love2D Test of Musico
local Musico = require('Musico')
local visual = require('Visualize')
visual(Musico)

local played = false

function love.mousereleased()
    if not played then
        print('play!')
        played = true
        Musico.start()
    else
        print('stop!')
        played = false
        Musico.stop()
    end
end

function love.mousemoved(x)
    Musico.setIntensity(((x / love.graphics.getWidth()*2) - 1) * 100)
end

function love.load()
    Musico.loadMusic('Music')
    Musico.loadSong('rink')
    visual.newSong()
end

function love.update(dt)
    visual.update(dt)
    Musico.update(dt)
end

function love.draw()
    visual.draw()
end
