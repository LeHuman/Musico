-- Musico v0.1
--[[
    An adaptive music manager that uses songs that are split
    into tracks in order to create horizontal dynamic
    music
]]
-- local newSoundData = love.sound.newSoundData --IMPROVE: if memory becomes issue, implement decoder

local songL = require('Song')
local reader = require('MusicoReader')
local min = math.min
local pauseS, unPauseS, stopS, startS = songL.pause, songL.unPause, songL.stop, songL.start
local newSong, updateSong, getLoopTime = songL.new, songL.update, songL.getLoopTime
local songs = {}

local loopTime, playing
local activeSong
local loop = 0
local intensity = 0

function _tabletostring(tt, indent, done)
    done = done or {}
    indent = indent or 1
    if type(tt) == 'table' then
        local sb = {}
        for key, value in pairs(tt) do
            table.insert(sb, string.rep('\t', indent)) -- indent it
            local keystring = key
            if type(key) == 'number' then
                keystring = string.format('[%d]', key)
            end
            if type(key) == 'string' then
                keystring = string.format('["%s"]', key)
            end
            if type(value) == 'table' and not done[value] then
                done[value] = true
                table.insert(sb, string.format('%s={\n', keystring))
                table.insert(sb, _tabletostring(value, indent + 1, done))
                table.insert(sb, string.rep('\t', indent)) -- indent it
                table.insert(sb, '},\n')
            elseif type(value) == 'string' then
                table.insert(sb, string.format('%s ="%s",\n', keystring, value))
            else
                table.insert(sb, string.format('%s = %s,\n', keystring, tostring(value)))
            end
        end
        return table.concat(sb)
    elseif tt then
        return tt .. '\n'
    else
        return 'nil' .. '\n'
    end
end

local function loadMusic(musicPath)
    local sngs = reader(musicPath)
    for name, song in pairs(sngs) do
        -- print(_tabletostring(song))
        local o = newSong(song[1])
        for i = 2, #song do
            o:addTrack(song[i])
        end
        songs[name] = o
        print('saved song: ' .. name)
    end
end

local function loadSong(songName)
    songName = tostring(songName):lower()
    local song = songs[songName]
    if song then
        if activeSong then
            stopS(activeSong)
        end
        activeSong = song
        loopTime = getLoopTime(song)
        print('song loaded!')
    else
        print("Song '" .. songName .. "' not found!")
    end
end

local function pause()
    if activeSong then
        pauseS(activeSong)
        playing = false
    end
end

local function unpause()
    if activeSong then
        unPauseS(activeSong)
        playing = true
    else
        print('No valid song loaded!')
    end
end

local function stop()
    if activeSong then
        stopS(activeSong)
        playing = false
    end
end

local function start()
    if activeSong then
        startS(activeSong)
        playing = true
    else
        print('No valid song loaded!')
    end
end

local function setIntensity(magnitute)
    intensity = min(magnitute, 100)
end

local function getIntensity()
    return intensity
end

local function update(dt)
    if playing then
        local cut = loop >= loopTime
        updateSong(activeSong, loop, intensity, cut)
        loop = cut and 0 or loop + dt
    end
end

local function getInfo()
    local song = activeSong
    local info = {
        Name = song:getName(),
        BPM = song:getBPM(),
        BPL = song:getBPL(),
        LoopTime = song:getLoopTime(),
        tracks = {}
    }
    for i, track in ipairs(song:getTracks()) do
        info.tracks[i] = track
    end
    return info
end

local function isPlaying()
    return playing
end

local functions = {
    loadMusic = loadMusic,
    update = update,
    loadSong = loadSong,
    start = start,
    stop = stop,
    pause = pause,
    unpause = unpause,
    getInfo = getInfo,
    isPlaying = isPlaying,
    setIntensity = setIntensity,
    getIntensity = getIntensity
}

return setmetatable({}, {__index = functions})
