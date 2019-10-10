-- Musico v0.1
--[[
    An adaptive music manager that uses songs that are split
    into tracks in order to create horizontal dynamic
    music
]]
local filesystem, read, floor = love.filesystem, love.filesystem.read, math.floor
local newSoundData = love.sound.newSoundData --IMPROVE: if memory becomes issue, implement decoder
local newSource = love.audio.newSource

local songL = require('Song')
local pauseS, unPauseS, stopS, startS = songL.pause, songL.unPause, songL.stop, songL.start
local newSong, updateSong = songL.new, songL.update
local songs = {}

local loopTime, playing
local activeSong
local loop = 0
local intensity = 0

local function findHeader(str)
    -- string.format(str, ...)
end

local function loadSongFile(songPath) --TODO: make .musico reader
    -- local songFile = read(songPath)
    -- for line in  do
    --     table.insert(highscores, line)
    -- end
    return {
        song = {},
        tracks = {}
    }
end

local function loadFiles(songDir)
    for _, song in ipairs(filesystem.getDirectoryItems(songDir)) do
        local pathTo = songDir .. '/' .. song
        if filesystem.getInfo(pathTo, 'file') then
            local state, output = pcall(loadSongFile, pathTo)
            if state then
                local sng = newSong(output)
                songs[song:getName()] = sng
            else
                print('MUSICO ERROR: Loading ' .. pathTo)
            end
        end
    end
end

local function load(musicFolder)
    -- for _, songFolder in ipairs(filesystem.getDirectoryItems(musicFolder)) do
    --     loadFiles(musicFolder .. '/' ..songFolder)
    -- end
    local o =
        newSong {
        name = 'rink',
        bpm = 235,
        bpl = 4
    }
    o:addTrack {
        source = newSource('Music/rink/rink.wav', 'static'),
        id = 1,
        vol = 1,
        atk = 0.2,
        rls = 0.2,
        mult = true,
        inter = true,
        sus = 0,
        susMult = true,
        susFd = true,
        tHolds = {{-55, 100}}
    }
    songs['rink'] = o
end

local function loadSong(songName)
    local song = songs[songName]
    if song then
        if activeSong then
            stopS(activeSong)
        end
        activeSong = song
        loopTime = song:getBPL()*4 / (song:getBPM() / 60) --FIXME: bpm and stuff
        print('song loaded!')
    end
end

local function pause()
    pauseS(activeSong)
    playing = false
end

local function unpause()
    unPauseS(activeSong)
    playing = true
end

local function stop()
    stopS(activeSong)
    playing = false
end

local function start()
    startS(activeSong)
    playing = true
end

local function setIntensity(magnitute)
    intensity = magnitute
end

local function getIntensity()
    return intensity
end

local function update(dt)
    if playing then
        loop = loop + dt
        if loop >= loopTime then
            print('loop')
            loop = 0
            updateSong(activeSong, intensity)
        end
    end
end

local functions = {
    load = load,
    update = update,
    loadSong = loadSong,
    start = start,
    stop = stop,
    pause = pause,
    unpause = unpause,
    setIntensity = setIntensity,
    getIntensity = getIntensity
}

return setmetatable({}, {__index = functions})
