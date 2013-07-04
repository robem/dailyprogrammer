local FILE_NAME = 'dailyprogrammer.txt'
local T_MODES = {"easy","intermediate","difficult","hard"}
local t_links = {}

function download()
	io.write('download ... ')
	io.flush()
	local http  = require('socket.http')
	local ltn12 = require('ltn12')

	local pat_entry = '<a class="title " href="([^"]+)"'
	local pat_next = '<a href="([^"]+)"[^>]+>next'

	local next_link = 'http://www.reddit.com/r/dailyprogrammer'
	repeat
		local html, code, header, status = http.request(next_link)
		assert(code==200)

		for x in html:gmatch(pat_entry) do
			--if x:match("_challenge_") then
			table.insert(t_links, x)
			--end
			--print(x)
		end

		next_link = html:match(pat_next)
	until not next_link

	-- write to file
	local file = assert(io.open(FILE_NAME, 'w'))
	for _,x in pairs(t_links) do
		file:write(x..'\n')
	end
	file:close()
	print('done.')
end

-------
-- main
-------
local update = (arg[1] == 'update')

local file = io.open(FILE_NAME,'r')
if not file or update then download() 
else 
	print('using local copy.')
	for link in file:lines() do
		table.insert(t_links, link)
	end
	file:close()
end

local t_mode = {}
for _,x in pairs(t_links) do
	local mode = x:match("(difficult)") or x:match("(intermediate)") or x:match("(easy)") or x:match("(hard)")

	if mode then
		if not t_mode[mode] then t_mode[mode] = {} end
		table.insert(t_mode[mode], x)
	end
end

for _,mode in pairs(T_MODES) do
	for _,link in pairs(t_mode[mode]) do
		print(mode..string.rep(' ',12-#mode),link)
	end
end

