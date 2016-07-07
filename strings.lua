function split(str, splitAt)
	print("called")
	res = { }
	lastFound = 0
	local loc = str:find(splitAt, lastFound);
	while loc ~= nil do
		print("called")
		table.insert(res, str:sub(lastFound, loc-1))
		lastFound = loc + 1
		loc = str:find(splitAt, lastFound);
	end
	table.insert(res, str:sub(lastFound, str:len()))
	return res
end

--Example usage

	--local str = require "strings"

	--res = split("test;test2;test3", ";")
	--for i, s in ipairs(res) do
	--	print(s)
	--end
