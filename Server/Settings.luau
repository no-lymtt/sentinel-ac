local options = {}

-- ⚠️⚠️⚠️ PLEASE PLEASE PLEASE READ ME ⚠️⚠️⚠️
-- AVOID GIVING TOOLS STRAIGHT TO THE CHARACTER, INSTEAD PUT THE TOOL IN THEIR BACKPACK. IF YOU DON'T DO THIS THE PLAYER COULD GET BANNED!

-- How many times should the script run the main check function per second. Some other functions will be constantly run in a secondary loop, but the main system will be hooked up to the tick system.
-- NOTE: Physics checks might be a little finicky at high tick rates! I developed everything with a tick rate of 10!
options.TickRate = 10

-- Define the maximum amount of time in seconds between client-server handshakes. If the client does not send a handshake within this time, the server will kick the player.
options.MaxCheckInTime = 10

-- TODO: change ban duration based off of the number of times the player has been banned previously
options.BanDuration = {
	30,
	-1,
}

-- Register remote events to be checked for integrity. If an event doesn't have a definite argument count don't add it here.
options.RemoteEvents = {
	NoArgs = {
		Path = game:GetService("ReplicatedStorage").RemoteEvents.NoArgs,
		ArgumentCount = 0,
		ArgumentTypes = {},
	},
	OneArg = {
		Path = game:GetService("ReplicatedStorage").RemoteEvents.OneArg,
		ArgumentCount = 1,
		ArgumentTypes = {"any"},
	},
}

-- Maximum walkspeed in Studs per Second the player can have. Set this to math.huge to disable the check. Might add an actual toggle in the future.
options.MaxSPS = 16 or game.StarterPlayer.CharacterWalkSpeed

-- Enable no-clip detection. Might be slow in games with super high player count.
options.NoClipCheckEnabled = true

return options
