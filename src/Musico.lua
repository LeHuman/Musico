-- Musico v0.1
--[[
    An adaptive music manager that uses songs that are split
    into tracks in order to create horizontal dynamic
    music
]]
local insert, filesystem, read, floor = table.insert, love.filesystem, love.filesystem.read, math.floor
local newSoundData = love.sound.newSoundData --IMPROVE: if memory becomes issue, implement decoder
local newSource = love.audio.newSource

local newSong = require('Song')
local songs = {}

local activeTracks, thresholds, loopTime, playing
local loop = 0
local intensity = 0

local function loadSongFile(songPath) --TODO: make .musico reader
    -- local songFile = read(songPath)
    -- for line in  do
    --     table.insert(highscores, line)
    -- end
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
        name = 'shanty',
        bpm = 174,
        bpl = 12
    }
    o:addTrack {
        source = newSource('Music/Shanty/Accordian.wav', 'static'),
        id = 1,
        vol = 1,
        atk = 0,
        atkMult = true,
        atkFd = true,
        sus = 0,
        susMult = true,
        susFd = true,
        tHold = {-85, 100}
    }
    songs['shanty'] = o
end

local function loadSong(songName)
    local song = songs[songName]
    if song then
        activeTracks = song:getTracks()
        thresholds = song:getThresholds()
        loopTime = song:getBPL() / (song:getBPM() * 60)
        print('song loaded!')
    end
end

local function pause()
    for _, trak in pairs(activeTracks) do
        trak:pause()
    end
    playing = false
end

local function unpause()
    for _, trak in pairs(activeTracks) do
        trak:unpause()
    end
    playing = true
end

local function stop()
    for _, trak in pairs(activeTracks) do
        trak:stop()
    end
    playing = false
end

local function start()
    if activeTracks then
        stop()
    end
    for _, trak in pairs(activeTracks) do
        trak:start()
    end
    playing = true
end

local function setIntensity(magnitute)
    intensity = magnitute
end

local function getIntensity()
    return intensity
end

local function updateTracks()
    local tHolds = thresholds[floor(intensity * 100)]
    if tHolds then
        for i = 1, #tHolds do
            local trk = activeTracks[tHolds[i]]
            if trk then
                trk:stop()
                print('killing:' .. trk.id)
            end
        end
    end
end

local function _tabletostring(tt, indent, done)
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

local function update(dt)
    if playing then
        loop = loop + dt
        if loop >= loopTime then
            loop = 0
            updateTracks()
        end
    -- print(_tabletostring(thresholds))
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
