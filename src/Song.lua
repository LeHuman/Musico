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

local thresholdObj = {}
thresholdObj.__index = thresholdObj
function thresholdObj.new()
    local o = {
        holds = {}
    }
    setmetatable(o, thresholdObj)
    return o
end
local function multiHold(self, num)
    local holds = self.holds
    for i = 1, #holds do
        local hold = holds[i]
        if hold[1] <= num and num <= hold[2] then
            return true
        end
    end
    return false
end
local function singleHold(self, num)
    local hold = self.holds[1]
    if hold[1] <= num and num <= hold[2] then
        return true
    end
    return false
end
function thresholdObj:newBound(upper, lower)
    self.holds[#self.holds + 1] = {upper, lower}
    if #self.holds == 1 then
        self.check = singleHold
    else
        self.check = multiHold
    end
end
function thresholdObj.check()
    return false
end

local function setThresholds(songTable)
    local tracks = songTable.tracks
    local tHolds = {}

    for i = 1, #tracks do
        local trk = tracks[i]
        local tHold = trk.tHold
        tHolds[i] = thresholdObj.new()
        if type(tHold[1]) == 'table' then
            for j = 1, #tHold do
                tHolds[i]:newBound(tHold[j][1], tHold[j][2])
            end
        else
            tHolds[i]:newBound(tHold[1], tHold[2])
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
