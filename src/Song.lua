local insert, floor = table.insert, math.floor

local function startTrack(self)
    local source = self.source
    source.setLooping(source, true)
    source.play(source)
end
local function stopTrack(self)
    self.source:setLooping(false)
end
local function pauseTrack(self)
    self.source:pause()
end
local function unpauseTrack(self)
    self.source:play()
end

local function getID(self)
    return self.id
end

local track = {
    id = 0,
    vol = 1,
    atk = 0,
    atkMult = true,
    atkFd = true,
    sus = 0,
    susMult = true,
    susFd = true,
    tHold = {-85, 100},
    start = startTrack,
    stop = stopTrack,
    pause = pauseTrack,
    unpause = unpauseTrack,
    getID = getID,
}

local function newTrack(trackTable)
    setmetatable(trackTable, {__index = track})
    for k, v in pairs(track) do
        if not trackTable[k] or type(trackTable[k]) ~= type(v) then
            trackTable[k] = v
        end
    end
    return trackTable
end

local song = {
    name = 'nil',
    bpm = 60,
    bpl = 4,
}

function song.addTrack(self, trackTable)
    trackTable = newTrack(trackTable)
    self.tracks[trackTable.id] = trackTable
end

function song.getTracks(self)
    return self.tracks
end

function song.getBPM(self)
    return self.bpm
end

function song.getBPL(self)
    return self.bpl
end
function song.getName(self)
    return self.name
end

local function returnThresholds(self)
    return self.thresholds
end

local function setThresh(lr, up, id, tbl)
    lr = floor(lr - 1)
    up = floor(up + 1)
    if not tbl[lr] then
        tbl[lr] = {}
    end
    if not tbl[up] then
        tbl[up] = {}
    end
    insert(tbl[lr], id)
    insert(tbl[up], id)
end

function song.getThresholds(self)
    local tracks = self.tracks
    local tHolds = {}
    for _, trk in pairs(tracks) do
        local tHold = trk.tHold
        local id = self.id
        if type(tHold[1]) == 'table' then
            for j = 1, #tHold do
                setThresh(tHold[j][1], tHold[j][2], id, tHolds)
            end
        else
            setThresh(tHold[1], tHold[2], trk:getID(), tHolds)
        end
    end
    self.thresholds = tHolds
    self.getThresholds = returnThresholds
    return tHolds
end

local function newSong(songTable)
    songTable.tracks = {}
    setmetatable(songTable, {__index = song})
    for k, v in pairs(song) do
        if not songTable[k] or type(songTable[k]) ~= type(v) then
            songTable[k] = v
        end
    end
    return songTable
end

return newSong
