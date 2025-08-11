--[[
  /$$$$$$                        /$$     /$$                     /$$       /$$$$$$ /$$$$$$$ 
 /$$__  $$                      | $$    |__/                    | $$      |_  $$_/| $$__  $$
| $$  \__/  /$$$$$$  /$$$$$$$  /$$$$$$   /$$ /$$$$$$$   /$$$$$$ | $$        | $$  | $$  \ $$
|  $$$$$$  /$$__  $$| $$__  $$|_  $$_/  | $$| $$__  $$ /$$__  $$| $$        | $$  | $$  | $$
 \____  $$| $$$$$$$$| $$  \ $$  | $$    | $$| $$  \ $$| $$$$$$$$| $$        | $$  | $$  | $$
 /$$  \ $$| $$_____/| $$  | $$  | $$ /$$| $$| $$  | $$| $$_____/| $$        | $$  | $$  | $$
|  $$$$$$/|  $$$$$$$| $$  | $$  |  $$$$/| $$| $$  | $$|  $$$$$$$| $$       /$$$$$$| $$$$$$$/
 \______/  \_______/|__/  |__/   \___/  |__/|__/  |__/ \_______/|__/      |______/|_______/                                                                                    
Sentinel Intrusion Detection v0.1

© 2025 NO LYMT under the MIT License

"Just because something has to come to an end someday doesn't mean it has to come to an end now." - Joe Bartolozzi

--]]

local initClock = os.clock()

local options, sha256 = require(script.Settings), require(script.src.Sha256)
local replicatedStorage = game:GetService("ReplicatedStorage")

while not game:IsLoaded() do
	task.wait()
end

-- // functions

-- MODIFIED FROM HexadecimalLiker's VERSION ON THE ROBLOX DEV FORUM!
local IsReferenced = function(Object)
	local Table = {}
	local WeakMT = setmetatable({
		Table, 1, "String", Object,
	}, {
		__mode = "kv"
	})

	--> Clean up
	Table = nil
	Object = nil 

	repeat task.wait(); until (not WeakMT[1])
	task.wait(0.2)

	if #WeakMT ~= 3 or rawlen(WeakMT) ~= 3 then
		print(WeakMT)
		return true
	end

	return false
end

-- END functions

-- basic script obfuscation
script.Parent = nil
game.DescendantAdded:Connect(function(instance)
	if instance:IsA("LocalScript") or instance:IsA("Script") then
		instance.Name = "C_" .. sha256.hash(instance.Name)
	end
end)

for i, v in game:GetDescendants() do
	if v:IsA("LocalScript") or v:IsA("Script") then
		v.Name = "S_" .. sha256.hash(v.Name)
	end
end

-- playergui whitelist thing here so exploiters cant add things to startergui during runtime and spoof things
-- TODO/FIX: might delete random guis if the guis take a long time to load.
local guis = options.PlayerGuiWhitelist
for i, v in game:GetService("StarterGui"):GetDescendants() do
	local text = "Players." .. game.Players.LocalPlayer.Name .. ".PlayerGui." .. string.sub(v:GetFullName(), 12)
	table.insert(guis, text)
end

-- for the uhm ping thingy
local clock = os.clock()

-- main check function
local function check()
	
	if script:FindFirstChild("LICENSE") == nil or script:FindFirstChild("Settings") == nil then
		game.Players.LocalPlayer:Kick("An error occured: SID-CL-MSD")
	end
	-- constants
	local player = game.Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid: Humanoid = char:WaitForChild("Humanoid")
	
	-- walkspeed check
	if options.WalkSpeedCheckEnabled == true and humanoid.WalkSpeed > options.MaxWalkSpeed then
		humanoid.WalkSpeed = math.clamp(humanoid.WalkSpeed, 0, options.MaxWalkSpeed)
	end
	
	-- jump check
	if options.JumpPowerCheckEnabled == true and options.MaxJumpPower ~= -1 and humanoid.JumpPower > options.MaxJumpPower then
		humanoid.JumpPower = math.clamp(humanoid.JumpPower, 0, options.MaxJumpPower)
	elseif options.JumpPowerCheckEnabled == true and options.MaxJumpHeight ~= -1 and humanoid.JumpHeight > options.MaxJumpHeight then
		humanoid.JumpHeight = math.clamp(humanoid.JumpHeight, 0, options.MaxJumpHeight)
	end
	
	-- playergui check
	if options.LimitPlayerGui then
		for i, v in game.Players.LocalPlayer.PlayerGui:GetDescendants() do
			if not table.find(guis, v:GetFullName()) then
				v:Destroy()
			end
		end
	end
	
	-- ping check
	if os.clock() - clock > 0.5 then
		clock = os.clock()
		replicatedStorage:WaitForChild("SAC").Ping:FireServer()
	end
end

-- init forever loop
task.spawn(function()
	while true do
		if IsReferenced(game.CoreGui) then
			replicatedStorage:WaitForChild("SAC").RemoteBan:FireServer("coregui")
		end
		if IsReferenced(game.InsertService) then
			replicatedStorage:WaitForChild("SAC").RemoteBan:FireServer("insertservice")
		end
	end
end)

print("SID Initialized in " .. tostring((os.clock() - initClock)*1000) .. "s")

while task.wait(1/options.TickRate) do
	check()
end
