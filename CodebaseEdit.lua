unpack = unpack or table.unpack
require"ssl.https"
require"Moonrise.Import.Install".All()

local Tools = require"Moonrise.Tools"

local GPT_3_5 = require"GPT-3-5"

local Options = Tools.CommandLine.GetOptions()

local DryRun = Options.Settings.dry or false
local Prompt = #Options.Arguments > 0 and table.concat(Options.Arguments, " ") or "Please summarize the preceding code files"
local Key = Options.Settings.key or error"provide --key='OPENAI_KEY'"
local Root = Options.Settings.root or "./"

local MinCompletionTokens = tonumber(Options.Settings.min_completion_tokens or 500)
local MaxTokens = tonumber(Options.Settings.max_tokens or 4097)

local Extensions = Options.Settings.extension or {"lua"}
Extensions = type(Extensions) == "string" and {Extensions} or Extensions

local Ignores = Options.Settings.ignore or {"Config.lua$"}
Ignores = type(Ignores) == "string" and {Ignores} or Ignores

local IncludedNames = {}
local History = {}
local BaseTokenCount = 3 + GPT_3_5.API.CountMessageTokens(GPT_3_5.API.Message(Prompt, "system"))
local Message = GPT_3_5.API.Message("", "user")
local TotalTokens = 0
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
		print("Reading file ".. FullPath)
		local File, Err = io.open(FullPath, "rb")
		assert(File, Err)
		local Content = File:read"a"
		local _Message = GPT_3_5.API.Message(Message.content .."\n--[[".. FullPath .." follows this line:]]\n".. Content, "user")
		local TokenCount = BaseTokenCount + GPT_3_5.API.CountMessageTokens(_Message)
		print("Files will now take ".. TokenCount .." tokens")
		if MaxTokens-TokenCount >= MinCompletionTokens then
			TotalTokens = TokenCount
			Message = _Message
			--table.insert(History, Message)
			table.insert(IncludedNames, FullPath)
		else
			print("Too big, dropping")
		end
	else
		print("Ignoring file ".. FullPath)
	end
end

print("Will send ".. TotalTokens .." tokens: " .. Tools.Pretty.Table(IncludedNames, 2, true))
print("Including prompt: ".. Prompt)
print("There will be ".. MaxTokens - TotalTokens .." tokens left for completion")
if DryRun then print"Dry run, exiting" os.exit() end

local Editor = GPT_3_5.Bot(Key, {Message}, MinCompletionTokens, MaxTokens)
local Success, Response, Usage = Editor:Send(Prompt, "system")
print(Success, Response, Tools.Pretty.Any(Usage))
