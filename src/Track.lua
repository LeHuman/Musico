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

local function getID(self)
    return self.id
end

local function getTHolds(self)
    return self.tHolds
end

local max, min = math.max, math.min

local function press(self)
    self.tmp = min(self.tmp + self.atk, self.sus)
end

local function release(self)
    self.tmp = max(self.tmp - self.rls, 0)
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

-- local function newBound(self, upper, lower)
--     self.tHolds[#self.tHolds + 1] = {upper, lower}
--     if #self.tHolds == 1 then
--         self.check = singleHold
--     else
--         self.check = multiHold
--     end
-- end

local function update(self, intensity)
    if self:check(intensity) then
        press(self)
    else
        release(self)
    end
    local tmp = self.tmp
    if self.mult then
        setVolume(self,tmp)
    end
    -- if self.tmp == 0 then --add option to restart or continue off
    --     pauseTrack(self)
    -- else
    --     unpauseTrack(self)
    -- end
end

local track = {
    id = 0,
    vol = 1,
    atk = 1,
    rls = 1,
    mult = true,
    inter = true, --TODO:Interpolation of values
    sus = 0,
    tmp = 0,
    susMult = true,
    susFd = true,
    tHolds = {{0, 0}} -- tHolds should be formatted like this by Musico
}

local function newTrack(trackTable) --TODO:Ensure tHolds are formatted correctly
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
    newBound = newBound,
    getTHolds = getTHolds,
    update = update
}
