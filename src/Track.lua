local interFunc = require('Interpolation')
local newSource = love.audio.newSource
local max, min = math.max, math.min

local function setVolume(self, vol)
    self.source:setVolume(vol)
end

local function getVolume(self)
    return self.source:getVolume()
end

local function startTrack(self)
    local source = self.source
    source.setLooping(source, true)
    source.play(source)
end

local function stopTrack(self)
    self.source:setLooping(false)
    self.init = getVolume(self)
    self.trgt = 0
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

local function getTHolds(self)
    return self.tHolds
end

local function press(self)
    self.trgt = min(self.trgt + self.atk, self.sus) --FIXME: sustain var not used properly
end

local function release(self)
    self.trgt = max(self.trgt - self.rls, 0)
end

local function multiHold(self, intensity)
    local tHolds = self.tHolds
    for i = 1, #tHolds do
        local tHold = tHolds[i]
        if tHold[1] <= intensity and intensity <= tHold[2] then
            return true
        end
    end
    return false
end

local function singleHold(self, intensity)
    local tHold = self.tHolds
    if tHold[1] <= intensity and intensity <= tHold[2] then
        return true
    end
    return false
end

local function interpolate(time, initial, target, duration, func)
    return func(time, initial, target - initial, duration)
end

local function update(self, loop, loopTime, intensity, cut)
    print(loop, loopTime)
    if cut then
        if self:check(intensity) then --IMPROVE: better threshold checking
            press(self)
        else
            release(self)
        end
        self.init = getVolume(self)
    end

    if self.mult then
        if self.inter then
            local mov = interpolate(loop, self.init, self.trgt, loopTime, self.inter)
            setVolume(self, mov)
        else
            setVolume(self, intensity)
        end
    end
    --IMPROVE: add option to restart or continue off
end

local track = {
    id = 0,
    source = 'fileLocation',
    vol = 1,
    atk = 1,
    rls = 1,
    mult = true,
    inter = 'linear',
    sus = 0,
    tHolds = {-100, 100}
}

local function getInterFunc(funcName)
    local func = interFunc[string.lower(funcName)]
    if not func then
        print('Interpolation function not found!')
        return interFunc.linear
    end
    return func
end

local function setSourceFile(trackTbl, fileLocation)
    trackTbl.source = newSource(fileLocation, 'static')
end

local function newTrack(trackTable) --TODO:Ensure tHolds are formatted correctly
    local trk = {}
    for k, v in pairs(track) do
        local lV = trackTable[k]
        if not lV or type(lV) ~= type(v) then
            trk[k] = v
        else
            trk[k] = lV
        end
    end
    if not trackTable.inter then -- special case var
        trk.inter = false
    end
    setmetatable(trk, {__index = track})

    if not pcall(setSourceFile, trk, trk.source) then
        print('Failed to load song at:', trk.source)
        return
    end

    if type(trk.tHolds[1]) ~= 'table' then
        trk.check = singleHold
    else
        trk.check = multiHold
    end

    if trk.inter then
        trk.inter = getInterFunc(trk.inter)
    end
    trk.trgt, trk.init = 0, 0
    trk.sus = trk.sus == 0 and 1 or trk.sus
    trk.atk = trk.atk == 0 and trk.sus or trk.atk
    trk.rls = trk.rls == 0 and trk.sus or trk.rls
    return trk
end

return {
    new = newTrack,
    start = startTrack,
    stop = stopTrack,
    pause = pauseTrack,
    unPause = unpauseTrack,
    getID = getID,
    getTHolds = getTHolds,
    update = update
}
