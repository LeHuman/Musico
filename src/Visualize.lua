local track = require('Track')
local getID, getTHolds, getVolume = track.getID, track.getTHolds, track.getVolume
local graphics = love.graphics
local ceil = math.ceil
local rectangle, clear, setColor = graphics.rectangle, graphics.clear, graphics.setColor
local font = love.graphics.newFont(15)
local fHeight = font:getHeight()
local gPrint = love.graphics.print

local instance = false
local initalHeight = 0
local remainingHeight = 0
local width = 0

local playing = false
local intensity = 0
local intensityVal = 0
local info = ''
local tracks = {}

--Sizes of things
local INTENSITY_BAR = 4
local TRACK_BAR = 8
local INFO_BAR = 4

local function newSong()
    info = instance.getInfo()
    tracks = info.tracks
    for i = 1, #tracks do
        local t = tracks[i]
        tracks[i].ID = ' ID: ' .. getID(t) .. ' '
        tracks[i].IDW = font:getWidth(tracks[i].ID)
        tracks[i].THolds = getTHolds(t)
        tracks[i].vol = 0
    end
    local fnlInfo = {}
    for key, value in pairs(info) do
        if key ~= 'tracks' then
            fnlInfo[#fnlInfo + 1] = ' ' .. key .. ': ' .. value .. ' '
        end
    end
    info = fnlInfo
    TRACK_BAR = (100 - (INTENSITY_BAR + INFO_BAR)) / #tracks
end

local function allocate(percentage, retain)
    percentage = percentage or 100
    local height = initalHeight * percentage / 100
    if not retain then
        remainingHeight = remainingHeight - height
    end
    return height
end

local function update()
    initalHeight = graphics.getHeight()
    remainingHeight = initalHeight
    width = graphics.getWidth()
    intensityVal = instance.getIntensity()
    intensity = (intensityVal + 100) / 200
    for i = 1, #tracks do
        local t = tracks[i]
        tracks[i].vol = getVolume(t)
    end
    playing = instance.isPlaying()
end

local function trackPos()
    return initalHeight - remainingHeight + allocate(INTENSITY_BAR, true)
end

local dull = {0.5, 0.5, 0.5}

local function intensityColor(val)
    if not playing then
        return dull
    end
    return {val - 0.1, 0.8 - val, 0.2 - val}
end

local function draw()
    local sFont = love.graphics.getFont()

    love.graphics.setFont(font)
    for i = 1, #tracks do
        local t = tracks[i]
        local pos = trackPos()
        local height = allocate(TRACK_BAR)
        local vol = t.vol
        local w = vol * width
        setColor(intensityColor(vol))
        rectangle('fill', 0, pos, w, height)
        setColor(0, 0, 0)
        local id = t.ID
        local idw = t.IDW
        gPrint(id, w - idw, pos)
        vol = ' Vol: ' .. ceil(vol * 100) .. ' '
        gPrint(vol, w - font:getWidth(vol), pos + fHeight)
        setColor(1, 1, 1)
        gPrint(id, w, pos)
        gPrint(vol, w, pos + fHeight)
        -- rectangle('line', 0, pos, w, height)
    end
    setColor(0.7, 0.7, 0.7)
    local height = allocate(INFO_BAR)
    local w = initalHeight - height
    rectangle('fill', 0, w, width, height)
    setColor(0, 0, 0)
    gPrint(info, 1, w + fHeight / 4)
    setColor(intensityColor(intensity))
    w = intensity * width
    local h = allocate(INTENSITY_BAR)
    rectangle('fill', 0, 0, w, h)
    setColor(0, 0, 0)
    local intense = ' ' .. ceil(intensityVal) .. ' '
    local fh = fHeight + fHeight / 4
    gPrint(intense, w - font:getWidth(intense), h - fh)
    setColor(1, 1, 1)
    gPrint(intense, w, h - fh)

    love.graphics.setFont(sFont)
end

local function setInstance(_, musicoInstance)
    instance = musicoInstance
end

local funcs = {
    update = update,
    newSong = newSong,
    allocate = allocate,
    draw = draw
}

return setmetatable({}, {__index = funcs, __call = setInstance})
