local filesystem, read, floor = love.filesystem, love.filesystem.read, math.floor
local newFileData = love.filesystem.newFileData

local currentHead = false
local keyWordFound = false
local keyWordSetter = false
local storedKey = ''
local savedKey = '' --TODO: multiLine var support

local keyWords = {
    file = 'string',
    id = 'number', --TODO: getRid of id option
    vol = 'number',
    volume = 'number',
    atk = 'number',
    attack = 'number',
    rls = 'number',
    release = 'number',
    mult = 'boolean',
    multiplier = 'boolean',
    inter = {'string', 'boolean'},
    interpolation = {'string', 'boolean'},
    sus = 'number',
    sustain = 'number',
    thold = 'table',
    threshold = 'table',
    name = 'string',
    bpm = 'number',
    bpl = 'number'
}

local function eval(string)
    local func = {
        'return',
        string
    }
    return loadstring(table.concat(func, ' '))()
end

local function finishKey()
    if not keyWordSetter then
        local f, s = storedKey:find('=')
        if f then
            storedKey = storedKey:sub(s + 1)
            keyWordSetter = true
        else
            return keyWordFound
        end
    end
    if keyWordSetter then
        -- print(storedKey:match('(%S+)%s?')) -- support for more vars on one line?| solved by adding commas to format
        local state, var = pcall(eval, storedKey)
        if state then
            return false, keyWordFound, var
        end
    end
    return keyWordFound
end

local function loadFile(filePath)
    currentHead = false
    keyWordFound = false
    keyWordSetter = false
    storedKey = ''
    savedKey = ''
    local finalSong = {}
    local nextTrack = 1
    local file = newFileData(filePath)
    local PATH = filePath:match('(.*/)[^/]*')
    local state, name = true, file:getFilename():lower():match('.*/([^/]*).musico')
    if string.lower(file:getExtension()) == 'musico' then
        local stream = (file:getString() .. '\r'):lower():gsub('%s+#.-\r', '\r'):gsub('^#.-\n', '\r'):gsub(' ', '')
        for line in string.gmatch(stream, '[^\r\n]+') do
            if not keyWordFound then
                local headMatch = line:match('%[(.-)%]')
                if headMatch then
                    if headMatch == 'track' then
                        nextTrack = nextTrack + 1
                        currentHead = headMatch
                    elseif headMatch == 'song' then
                        currentHead = headMatch
                    else
                        currentHead = false
                    end
                elseif currentHead then
                    keyWordFound = false
                    for keyWord, _ in pairs(keyWords) do
                        local f = line:find(keyWord)
                        if f then
                            keyWordFound = keyWord
                            keyWordSetter = false
                            break
                        end
                    end
                end
            end
            if keyWordFound then
                storedKey = line
                local key, val
                keyWordFound, key, val = finishKey()
                if not keyWordFound then
                    local pos = currentHead == 'song' and 1 or nextTrack
                    if not finalSong[pos] then
                        finalSong[pos] = {}
                    end
                    local test = keyWords[key]
                    local add = false
                    if key == 'file' then --special cases for readability
                        key = 'source'
                        val = PATH .. val
                    elseif key == 'thold' then
                        key = 'tHolds'
                    end
                    if type(test) == 'table' then
                        for _, v in ipairs(test) do
                            if type(val) == v then
                                add = true
                                break
                            end
                        end
                    elseif type(val) == test then
                        add = true
                    end
                    if add then
                        finalSong[pos][key] = val
                    end
                end
            end
        end
    else
        return false
    end
    -- for key, value in ipairs(finalSong) do
    --     print('[' .. key .. '] = { ')
    --     for k, v in pairs(value) do
    --         print('', k .. ' = ' .. tostring(v) .. ',')
    --     end
    --     print('}')
    -- end
    return state, name, finalSong
end

local function isFile(path)
    local file = filesystem.getInfo(path)
    if file then
        local typ = file.type
        if typ == 'file' then
            return true
        elseif typ == 'directory' then
            return false
        end
        return nil
    end
end

--Shall only check two levels for .musico files
local function scanFolder(tbl, folderPath, secondRun)
    secondRun = secondRun or false
    for _, songFolder in ipairs(filesystem.getDirectoryItems(folderPath)) do
        local path = folderPath .. '/' .. songFolder
        local check = isFile(path)
        if check then
            local state, name, song = loadFile(path)
            if state then
                tbl[name] = song
            end
        elseif not secondRun and check == false then
            scanFolder(tbl, path, true)
        end
    end
    return tbl
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
        return scanFolder({}, path)
    end
    print('Failed to load file(s) at:', path)
end

return loadPath
