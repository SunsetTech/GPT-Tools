unpack = unpack or table.unpack
require"ssl.https"
require"Moonrise.Import.Install".All()

local Tools = require"Moonrise.Tools"
local GPT_3_5 = require"GPT-3-5"

local Options = Tools.CommandLine.GetOptions()

local Root = Options.Settings.root or "./"

local MinCompletionTokens = tonumber(Options.Settings.min_completion_tokens or 500)
local MaxTokens = tonumber(Options.Settings.max_tokens or 4097)

local Extensions = Options.Settings.extension or {"lua"}
Extensions = type(Extensions) == "string" and {Extensions} or Extensions
local Ignores = Options.Settings.ignore or {"Config.lua$"}
Ignores = type(Ignores) == "string" and {Ignores} or Ignores

local IncludedNames = {}
local BaseTokenCount = 0
local Message = GPT_3_5.API.Message("", "user")

for Path, SubPath in Tools.Filesystem.Recurse(Root, true) do
	local FullPath = Root .."/".. Path .."/".. SubPath

	local Ignore = true
	
	for _,Extension in pairs(Extensions) do
		if SubPath:match("%.".. Extension .."$") then
			Ignore = false
			break
		end
	end
	
	for _,IgnorePattern in pairs(Ignores) do
		if FullPath:match(IgnorePattern) then
			Ignore = true
			break
		end
	end
	
	if not Ignore then
		local File, Err = io.open(FullPath, "rb")
		assert(File, Err)
		local Content = File:read"a"
		local _Message = GPT_3_5.API.Message(Message.content .."\n--[[".. FullPath .." follows this line:]]\n".. Content, "user")
		local TokenCount = BaseTokenCount + GPT_3_5.API.CountMessageTokens(_Message)
		if MaxTokens-TokenCount >= MinCompletionTokens then
			Message = _Message
			table.insert(IncludedNames, FullPath)
		else
		end
	else
	end
end
print(Message.content)

