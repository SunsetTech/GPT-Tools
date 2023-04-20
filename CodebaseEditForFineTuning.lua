local dkjson = require"dkjson"
unpack = unpack or table.unpack
require"Moonrise.Import.Install".All()

local Filesystem = require"Moonrise.Tools.Filesystem"

local Root = arg[1] or error"where?"
local Extension = arg[2] or error"what?"

local Prefixes = {
	"File contents of";
	"file contents for";
	"Contents of";
	"Contents for";
	"What are the contents of";
	"what is the contents of";
	"What are the contents of";
}

local Suffixes = {
	"?";
	".";
	""
}

local Files = {}
for Path, SubPath in Filesystem.Recurse(Root, true) do
	if SubPath:find(".".. Extension .."$") then
		local FullPath = Root .."/".. Path .."/".. SubPath
		--print("Reading file ".. FullPath)
		local File = io.open(FullPath, "rb")
		assert(File)
		local Content = File:read"a"
		for i = 1,3 do 
			table.insert(Files, {prompt = Prefixes[math.random(1,#Prefixes)] .." ".. Path .."/".. SubPath .. Suffixes[math.random(1,#Suffixes)] .." ->"; completion = " ".. Content .." END"})
		end
	end
end
print(dkjson.encode(Files))
