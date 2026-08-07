--!nocheck
-- Aether Standalone loader
-- Put the repository in the executor workspace and run this file, or host the
-- standalone folder on the official AetherV2 repository and execute its raw URL.

if not game:IsLoaded() then game.Loaded:Wait() end

local globalEnvironment = (getgenv and getgenv()) or _G
local rawRepository = 'https://raw.githubusercontent.com/plutoxqqqq/AetherV2/main/'
local standaloneRaw = rawRepository..'standalone/'

if shared.AetherStandalone then
	pcall(function() shared.AetherStandalone:Uninject() end)
	shared.AetherStandalone = nil
end

local function fileExists(path)
	if not isfile then return false end
	local ok, result = pcall(isfile, path)
	return ok and result
end

local standaloneRoots = {
	'aetherv2/standalone/',
	'AetherV2/standalone/',
	'standalone/'
}

local repositoryRoots = {
	'aetherv2/',
	'AetherV2/',
	''
}

local function readLocal(candidates, relative)
	if not readfile then return nil end
	for _, root in candidates do
		local path = root..relative
		if fileExists(path) then
			local ok, result = pcall(readfile, path)
			if ok and type(result) == 'string' and result ~= '' then return result end
		end
	end
	return nil
end

local function fetch(url)
	local ok, result = pcall(function() return game:HttpGet(url, true) end)
	if not ok or type(result) ~= 'string' or result == '' or result == '404: Not Found' then
		error('Unable to download '..url..': '..tostring(result))
	end
	return result
end

local function readStandalone(relative)
	return readLocal(standaloneRoots, relative) or fetch(standaloneRaw..relative)
end

local function readRepository(path)
	local relative = path:gsub('^aetherv2/', '')
	return readLocal(repositoryRoots, relative) or fetch(rawRepository..relative)
end

local function compile(source, name)
	local chunk, errorMessage = loadstring(source, '@AetherStandalone/'..name)
	if not chunk then error('Failed to compile '..name..': '..tostring(errorMessage)) end
	return chunk
end

local Runtime = compile(readStandalone('runtime.lua'), 'runtime.lua')()
local aether = Runtime.new({
	Version = 'Standalone 1.0.0',
	SourceRoot = 'aetherv2',
	RawBase = rawRepository,
	Read = readRepository
})

shared.AetherStandalone = aether
globalEnvironment.AetherStandalone = aether

local license = {
	Closet = false,
	Standalone = true
}

local function runChunk(relative, argument)
	local ok, result = xpcall(function()
		return compile(readStandalone(relative), relative)(argument)
	end, debug and debug.traceback or tostring)
	if not ok then
		aether:CreateNotification('Loader', relative..' failed: '..tostring(result), 12, 'alert')
		warn('[Aether Standalone] '..relative..' failed: '..tostring(result))
	end
	return ok, result
end

runChunk('games/universal.lua', license)

if game.PlaceId == 6872274481 then
	runChunk('games/6872274481.lua', license)
else
	aether:CreateNotification(
		'Aether Standalone',
		'BedWars modules were not loaded because this place is '..tostring(game.PlaceId)..'.',
		8,
		'warning'
	)
end

aether:FinishLoading()
return aether
