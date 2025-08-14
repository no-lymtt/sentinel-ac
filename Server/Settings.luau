local options = {}

-- ⚠️⚠️⚠️ PLEASE PLEASE PLEASE READ ME ⚠️⚠️⚠️
-- AVOID GIVING TOOLS STRAIGHT TO THE CHARACTER, INSTEAD PUT THE TOOL IN THEIR BACKPACK. IF YOU DON'T DO THIS THE PLAYER WILL GET BANNED!

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

return options
