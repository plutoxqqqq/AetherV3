
local aether = shared.Aether
local compile = loadstring
local loadstring = function(...)
	local res, err = compile(...)
	if err and aether then
		aether:CreateNotification('AetherV3', 'Failed to load : ' .. err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= '' 
end
local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/plutoxqqqq/AetherV3/'.. readfile('aetherv3/profiles/commit.txt').. '/'.. select(1, path:gsub('aetherv3/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after aether updates.\n'.. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

aether.Place = 6872274481
if isfile('aetherv3/games/' .. aether.Place .. '.lua') then
	loadstring(readfile('aetherv3/games/' .. aether.Place .. '.lua'), tostring(aether.Place))()
else
	if not shared.AetherDeveloper then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/plutoxqqqq/AetherV3/'.. readfile('aetherv3/profiles/commit.txt').. '/games/'.. aether.Place.. '.lua', true)
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('aetherv3/games/' .. aether.Place .. '.lua'), tostring(aether.Place))()
		end
	end
end
