--[[
  /$$$$$$                        /$$     /$$                     /$$        /$$$$$$   /$$$$$$ 
 /$$__  $$                      | $$    |__/                    | $$       /$$__  $$ /$$__  $$
| $$  \__/  /$$$$$$  /$$$$$$$  /$$$$$$   /$$ /$$$$$$$   /$$$$$$ | $$      | $$  \ $$| $$  \__/
|  $$$$$$  /$$__  $$| $$__  $$|_  $$_/  | $$| $$__  $$ /$$__  $$| $$      | $$$$$$$$| $$      
 \____  $$| $$$$$$$$| $$  \ $$  | $$    | $$| $$  \ $$| $$$$$$$$| $$      | $$__  $$| $$      
 /$$  \ $$| $$_____/| $$  | $$  | $$ /$$| $$| $$  | $$| $$_____/| $$      | $$  | $$| $$    $$
|  $$$$$$/|  $$$$$$$| $$  | $$  |  $$$$/| $$| $$  | $$|  $$$$$$$| $$      | $$  | $$|  $$$$$$/
 \______/  \_______/|__/  |__/   \___/  |__/|__/  |__/ \_______/|__/      |__/  |__/ \______/ 
Sentinel Anti Cheat v0.1-prealpha.2

© 2025 NO LYMT under the MIT License

“I have not failed. I've just found 10,000 ways that won't work.” - Thomas A. Edison

--]]

local initClock = os.clock()

local options = require(script.Settings)
local replicatedStorage = game:GetService("ReplicatedStorage")

-- the table with all of the uh handshake data
local pingTable = {}

local function check(plr: Player)
	local char: Model
	if plr.Character then char = plr.Character else return end
	
	local normalizedPos = Vector3.new(char:GetPivot().Position.X, 0, char:GetPivot().Position.Z)
	
	-- if the player has a last vector3 attribute then do the checks.
	if char:GetAttribute("LastVector3") then
		-- walkspeed check
		-- testing a new idea of mine where u put the last vector3 of the player's rootpart as an attribute
		-- this will in theory make the physics checks a lot more reliable
		
		if (char:GetAttribute("LastNormalizedVector3") - normalizedPos).Magnitude > options.MaxSPS / options.TickRate + 2.5 --[[small threshold to compensate for lag and stuff]] then
			char:PivotTo(CFrame.new(char:GetAttribute("LastVector3")))
		end

		-- noclip check. i tried to optimize it as much as i could but it might still be slow :/
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {char}
		params.RespectCanCollide = true
		local result = workspace:Raycast(char:GetAttribute("LastVector3"), char:GetPivot().Position - char:GetAttribute("LastVector3"), params)
		if result ~= nil then
			char:PivotTo(CFrame.new(char:GetAttribute("LastVector3")))
		end
	end
	
	char:SetAttribute("LastNormalizedVector3", normalizedPos)
	char:SetAttribute("LastVector3", char:GetPivot().Position)
end

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
		tools = nil -- i think gc wouldve cought that? i dunno, idrk how roblox gc works :p
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
			plr:Kick("SAC-NW-REM-01") -- bad argument count
		end
		for i, argument in ipairs({...}) do
			if type(argument) ~= event.ArgumentTypes[i] and event.ArgumentTypes[i] ~= "any" then
				plr:Kick("SAC-NW-REM-02") -- bad argument type
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

if game:GetService("RunService"):IsStudio() then
	print("SAC Initialized in " .. tostring((os.clock() - initClock)*1000) .. "s")
	
	-- update notifications. this is only shown in studio because im not a monster and im not gonna flood your console with notifications
	local response = game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync("https://api.github.com/repos/no-lymtt/sentinel-ac/releases/latest", true))
	if response.tag_name ~= script:GetAttribute("Version") and script:GetAttribute("Version") ~= "SILENCE PEASANT" then
		task.spawn(function()
			while true do
				warn("You are on an outdated Sentinel Anti-Cheat version! You are on version " .. script:GetAttribute("Version") .. " while the newest version is " .. response.tag_name .. "! Consider updating soon to get important safety and security updates!")
				task.wait(60)
			end
		end)
	end
end

-- main loop
while task.wait(1 / options.TickRate) do
	for _, plr in game.Players:GetPlayers() do
		check(plr)
	end
end
