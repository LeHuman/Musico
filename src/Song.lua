local track = require('Track')
local pauseT, unPauseT, stopT, startT = track.pause, track.unPause, track.stop, track.start
local updateTrack = track.update

local function addTrack(self, trackTable)
    if not self.tracks then
        self.tracks = {}
    end
    trackTable = track.new(trackTable)
    local id = trackTable.id
    if id < 16 and id > 0 then
        self.tracks[id] = trackTable
    else
        print('Track id is out of range: ', id)
    end
end

local function getTracks(self)
    return self.tracks
end

local function getBPM(self)
    return self.bpm
end

local function getBPL(self)
    return self.bpl
end

local function getName(self)
    return self.name
end

local function pause(self)
    local trks = self.tracks
    for i = 1, #trks do
        pauseT(trks[i])
    end
    self.playing = false
end

local function unpause(self)
    local trks = self.tracks
    for i = 1, #trks do
        unPauseT(trks[i])
    end
    self.playing = true
end

local function stop(self)
    local trks = self.tracks
    for i = 1, #trks do
        stopT(trks[i])
    end
    self.playing = false
end

local function start(self)
    local trks = self.tracks
    for i = 1, #trks do
        startT(trks[i])
    end
    self.playing = true
end

local function update(self, intensity, cut)
    local trks = self.tracks
    for i = 1, #trks do
        updateTrack(trks[i], intensity, cut)
    end
end

local song = {
    name = 'nil',
    bpm = 60,
    bpl = 4,
    playing = false,
    addTrack = addTrack,
    getTracks = getTracks,
    getBPM = getBPM,
    getBPL = getBPL,
    getName = getName,
    pause = pause,
    unpause = unpause,
    stop = stop,
    start = start
}

local function newSong(songTable)
    setmetatable(songTable, {__index = song})
    return songTable
end

return {
    new = newSong,
    update = update,
    addTrack = addTrack,
    getTracks = getTracks,
    getBPM = getBPM,
    getBPL = getBPL,
    getName = getName,
    pause = pause,
    unpause = unpause,
    stop = stop,
    start = start
}
