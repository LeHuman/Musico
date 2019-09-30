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
    getID = getID
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
    bpl = 4
}

function song.addTrack(self, trackTable)
    trackTable = newTrack(trackTable)
    local id = trackTable.id
    if id < 16 and id > 0 then
        self.tracks[id] = trackTable
    else
        print('Track id is out of range: ', id)
    end
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

function song.getThresholds(self)
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

local function setThresholds(songTable)
    local tracks = songTable.tracks
    local tHolds = {}

    for i = 1, #tracks do
        local trk = tracks[i]
        local tHold = trk.tHold
        if type(tHold[1]) == 'table' then
            for j = 1, #tHold do
                setThresh(tHold[j][1], tHold[j][2], i, tHolds)
            end
        else
            setThresh(tHold[1], tHold[2], trk:getID(), tHolds)
        end
    end
    songTable.tHolds = tHolds
end

local function newSong(songTable)
    setmetatable(songTable.song, {__index = song})
    for _, trk in ipairs(songTable.tracks) do
        setmetatable(trk, {__index = track})
    end
    setThresholds(songTable)
    return songTable
end

return newSong
