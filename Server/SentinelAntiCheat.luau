--[[
  /$$$$$$                        /$$     /$$                     /$$        /$$$$$$   /$$$$$$ 
 /$$__  $$                      | $$    |__/                    | $$       /$$__  $$ /$$__  $$
| $$  \__/  /$$$$$$  /$$$$$$$  /$$$$$$   /$$ /$$$$$$$   /$$$$$$ | $$      | $$  \ $$| $$  \__/
|  $$$$$$  /$$__  $$| $$__  $$|_  $$_/  | $$| $$__  $$ /$$__  $$| $$      | $$$$$$$$| $$      
 \____  $$| $$$$$$$$| $$  \ $$  | $$    | $$| $$  \ $$| $$$$$$$$| $$      | $$__  $$| $$      
 /$$  \ $$| $$_____/| $$  | $$  | $$ /$$| $$| $$  | $$| $$_____/| $$      | $$  | $$| $$    $$
|  $$$$$$/|  $$$$$$$| $$  | $$  |  $$$$/| $$| $$  | $$|  $$$$$$$| $$      | $$  | $$|  $$$$$$/
 \______/  \_______/|__/  |__/   \___/  |__/|__/  |__/ \_______/|__/      |__/  |__/ \______/ 
Sentinel Anti Cheat v0.1-prealpha.1

© 2025 NO LYMT under the MIT License

“I have not failed. I've just found 10,000 ways that won't work.” - Thomas A. Edison

--]]

local initClock = os.clock()

local options = require(script.Settings)
local replicatedStorage = game:GetService("ReplicatedStorage")

-- the table with all of the uh handshake data
local pingTable = {}

game.Players.PlayerAdded:Connect(function(plr)
	pingTable[plr.UserId] = os.clock()
	local char: Model = plr.Character or plr.CharacterAdded:Wait()
	
	-- make sure the player doesnt have more than one tool equipped at a time (idk if this is patched but better safe than sorry yk)
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
	
	-- handshake check
	while plr.Parent and plr do
		if os.clock() - pingTable[plr.UserId] > options.MaxCheckInTime then
			plr:Kick("An error occured: SAC-NW-NET")
		end
		task.wait(1)
	end
end)

-- handshake check pt. 2
replicatedStorage:WaitForChild("SAC").Ping.OnServerEvent:Connect(function(plr)
	pingTable[plr.UserId] = os.clock()
end)
-- there was a very slight memory leak before so i fixed it :o
game.Players.PlayerRemoving:Connect(function(plr)
	pingTable[plr.UserId] = nil
end)

-- remote event integrity check
for _, event in pairs(options.RemoteEvents) do
	local remoteEvent: RemoteEvent = event.Path
	remoteEvent.OnServerEvent:Connect(function(plr, ...)
		if #{...} ~= event.ArgumentCount then
			warn("bad argument count passed for " .. event.Path:GetFullName())
			plr:Kick("SAC-NW-REM")
		end
		for i, argument in ipairs({...}) do
			if type(argument) ~= event.ArgumentTypes[i] and event.ArgumentTypes[i] ~= "any" then
				warn("bad argument type passed for " .. event.Path:GetFullName())
			end
			if event.ArgumentTypes[i] ~= "any" then
				warn("Using the any type defeats the whole purpose of a type check in the first place. Consider changing")
			end
		end
	end)
end

replicatedStorage.SAC.RemoteBan.OnServerEvent:Connect(function(plr, reason)
	game.Players:BanAsync({UserIds = {plr.UserId}, ApplyToUniverse = true, Duration = -1, DisplayReason = "exploiting", PrivateReason = tostring(reason)}) --TODO: make bans last longer based on config
end)

print("SAC Initialized in " .. tostring((os.clock() - initClock)*1000) .. "s")
