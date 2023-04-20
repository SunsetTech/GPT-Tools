require"ssl.https"

unpack = unpack or table.unpack
require"Moonrise.Import.Install".All()

local CommandLine = require"Moonrise.Tools.CommandLine"

local Options = CommandLine.GetOptions()
local API_KEY = Options.Settings.key or error"Please provide --key"
local SystemPrompt = Options.Settings.system

local GPT = require"GPT-3-5"

local TestBot = GPT.Bot(API_KEY, SystemPrompt and {GPT.API.Message(SystemPrompt, "user")})

while true do
	io.write">> "
	local Success, Response, Usage, PromptTokenCount, CompletionTokenCount = TestBot:Send(io.read"l")
	if Success then
		print("Generated text:", Response)
		print("Counted completion tokens:", CompletionTokenCount)
		print("Counted prompt tokens:", PromptTokenCount)
		print("Actual Usage:", Usage.completion_tokens .." Completion Tokens", Usage.prompt_tokens .." Prompt Tokens", Usage.total_tokens .." Total")
	else
		print("Error code:", Response)
		print("Error message:", Usage)
	end
end
