local filesystem, read, floor = love.filesystem, love.filesystem.read, math.floor
local newFileData = love.filesystem.newFileData

local function loadFile(filePath)
    local file = newFileData(filePath)
    local state, name, song, tracks = true, file:getFilename(), {}, {}
    if string.lower(file:getExtension()) == 'musico' then
        local stream = string.gsub(string.lower(file:getString()), '#.*?\n', '')
        while string.find(stream, '\n') do
        end
    else
        return false
    end
    return state, name, song, tracks
end

local function isFile(path)
    local file = filesystem.getInfo(path)
    if file then
        local typ = type(file)
        if typ == 'file' then
            return true
        elseif typ == 'directory' then
            return false
        end
        return nil
    end
end

--Shall only check two levels for .musico files
local function scanFolder(folderPath, secondRun)
    secondRun = secondRun or false
    local songs = {}
    for _, songFolder in ipairs(filesystem.getDirectoryItems(folderPath)) do
        local path = folderPath .. '/' .. songFolder
        local check = isFile(path)
        if check then
            local state, name, song, tracks = loadFile(path)
            if state then
                songs[name] = {song}
                for i = 1, tracks do
                    songs[name][#songs[name] + 1] = tracks[i]
                end
            end
        elseif not secondRun and check == false then
            scanFolder(path, true)
        end
    end
    return songs
end
-- songs = {
--     {
--         [1] = songTable,
--         [2] = TrackTbl,
--         [3] = TrackTbl,
--         [...] = TrackTbl,
--     }
-- }

local function loadPath(path) --load either folder or file dependent on what the path is
    local check = isFile(path)
    if check then
        return {loadFile(path)}
    elseif check == false then
        return scanFolder(path)
    end
    print('Failed to load file(s) at:', path)
end

return loadPath

-- local o =
-- newSong {
-- name = 'rink',
-- bpm = 235,
-- bpl = 1 --4
-- }
-- o:addTrack {
-- source = 'Music/rink/rink.wav',
-- id = 1,
-- vol = 1,
-- atk = 0.2,
-- rls = 0.2,
-- mult = true,
-- inter = 'quadratic',
-- sus = 0,
-- susMult = true,
-- susFd = true,
-- tHolds = {{-55, 100}}
-- }
-- songs['rink'] = o
