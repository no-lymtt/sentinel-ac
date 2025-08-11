--[[
  /$$$$$$                        /$$     /$$                     /$$        /$$$$$$   /$$$$$$ 
 /$$__  $$                      | $$    |__/                    | $$       /$$__  $$ /$$__  $$
| $$  \__/  /$$$$$$  /$$$$$$$  /$$$$$$   /$$ /$$$$$$$   /$$$$$$ | $$      | $$  \ $$| $$  \__/
|  $$$$$$  /$$__  $$| $$__  $$|_  $$_/  | $$| $$__  $$ /$$__  $$| $$      | $$$$$$$$| $$      
 \____  $$| $$$$$$$$| $$  \ $$  | $$    | $$| $$  \ $$| $$$$$$$$| $$      | $$__  $$| $$      
 /$$  \ $$| $$_____/| $$  | $$  | $$ /$$| $$| $$  | $$| $$_____/| $$      | $$  | $$| $$    $$
|  $$$$$$/|  $$$$$$$| $$  | $$  |  $$$$/| $$| $$  | $$|  $$$$$$$| $$      | $$  | $$|  $$$$$$/
 \______/  \_______/|__/  |__/   \___/  |__/|__/  |__/ \_______/|__/      |__/  |__/ \______/ 
Sentinel Anti Cheat v0.1

© 2025 NO LYMT under the MIT License

“I have not failed. I've just found 10,000 ways that won't work.” - Thomas A. Edison

--]]

local initClock = os.clock()

local options = require(script.Settings)
local replicatedStorage = game:GetService("ReplicatedStorage")

local pingTable = {}

game.Players.PlayerAdded:Connect(function(plr)
	pingTable[plr.UserId] = os.clock()
	local char: Model = plr.Character or plr.CharacterAdded:Wait()
	char.ChildAdded:Connect(function(child)
		local tools = {}
		for i, v in char:GetChildren() do
			if v:IsA("Tool") then
				table.insert(tools, v.Name)
			end
		end
		if #tools > 1 then
			game.Players:BanAsync({UserIds = {plr.UserId}, ApplyToUniverse = true, Duration = -1, DisplayReason = "exploiting", PrivateReason = "multiple tools equipped"})
		end
	end)
	
	while plr.Parent do
		if os.clock() - pingTable[plr.UserId] > options.MaxCheckInTime then
			plr:Kick("An error occured: SAC-NW-NET")
		end
		task.wait(1)
	end
end)

replicatedStorage:WaitForChild("SAC").Ping.OnServerEvent:Connect(function(plr)
	pingTable[plr.UserId] = os.clock()
end)

replicatedStorage.SAC.RemoteBan.OnServerEvent:Connect(function(plr, reason)
	game.Players:BanAsync({UserIds = {plr.UserId}, ApplyToUniverse = true, Duration = -1, DisplayReason = "exploiting", PrivateReason = tostring(reason)}) --TODO: make bans last longer based on config
end)

print("SAC Initialized in " .. tostring((os.clock() - initClock)*1000) .. "s")
