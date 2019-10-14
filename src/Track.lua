local interFunc = require('Interpolation')
local function startTrack(self)
    local source = self.source
    source.setLooping(source, true)
    source.play(source)
end

local function stopTrack(self)
    self.source:setLooping(false)
    self.tmp = 0
end

local function pauseTrack(self)
    self.source:pause()
end

local function unpauseTrack(self)
    self.source:play()
end

local function setVolume(self, vol)
    self.source:setVolume(vol)
end

local function getVolume(self)
    return self.source:getVolume()
end

local function getID(self)
    return self.id
end

local function getTHolds(self)
    return self.tHolds
end

local max, min = math.max, math.min

local function press(self)
    self.trgt = min(self.trgt + self.atk, self.sus)
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
    local tHold = self.tHolds[1]
    if tHold[1] <= intensity and intensity <= tHold[2] then
        return true
    end
    return false
end

local function interpolate(time, initial, target, duration, func)
    return func(time, initial, target - initial, duration)
end

local function update(self, dt, intensity, cut)
    if cut then
        if self:check(intensity) then --IMPROVE: better threshold checking
            press(self)
        else
            release(self)
        end
        self.init = getVolume(self)
        self.time = 0
    end

    if self.mult then
        if self.inter then
            self.time = self.time + dt
            local mov = interpolate(self.time, self.init, self.trgt, self.loopTime, self.inter)
            if mov > 0 and mov < 1 then
                print(mov)
            end
            setVolume(self, mov)
        else
            setVolume(self, intensity)
        end
    end
    --IMPROVE: add option to restart or continue off
end

local track = {
    id = 0,
    vol = 1,
    atk = 1,
    rls = 1,
    mult = true,
    inter = 'linear',
    sus = 0,
    tmp = 0,
    trgt = 0,
    susMult = true,
    susFd = true,
    tHolds = {{0, 0}} -- TODO: tHolds should be formatted like this by Musico
}

local function getInterFunc(funcName)
    local func = interFunc[string.lower(funcName)]
    if not func then
        print('Interpolation function not found!')
        return interFunc.linear
    end
    return func
end

local function newTrack(trackTable, loopTime) --TODO:Ensure tHolds are formatted correctly
    setmetatable(trackTable, {__index = track})
    for k, v in pairs(track) do
        if not trackTable[k] or type(trackTable[k]) ~= type(v) then
            trackTable[k] = v
        end
    end
    local tHolds = trackTable.tHolds
    if #tHolds == 1 then
        trackTable.check = singleHold
    else
        trackTable.check = multiHold
    end
    trackTable.inter = getInterFunc(trackTable.inter)
    trackTable.loopTime = loopTime
    trackTable.init = 0
    trackTable.time = 0
    trackTable.dur = 0
    trackTable.sus = trackTable.sus == 0 and 1 or trackTable.sus
    trackTable.atk = trackTable.atk == 0 and trackTable.sus or trackTable.atk
    trackTable.rls = trackTable.rls == 0 and trackTable.sus or trackTable.rls
    return trackTable
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
