local dkjson = require"dkjson"
unpack = unpack or table.unpack
require"Moonrise.Import.Install".All()

local Filesystem = require"Moonrise.Tools.Filesystem"

local Root = arg[1] or error"where?"
local Extension = arg[2] or error"what?"
local CommentStart = arg[3] or error"comment starts with?"

local Files = {}
for Path, SubPath in Filesystem.Recurse(Root, true) do
	if SubPath:find(".".. Extension .."$") then
		local FullPath = Root .."/".. Path .."/".. SubPath
		local File = io.open(FullPath, "rb")
		assert(File)
		local Content = File:read"a"
		table.insert(Files, CommentStart .. FullPath .." follows this line:\n".. Content)
	end
end
print(table.concat(Files, "\n"))
