-- NOTICE!
-- All options are default to the activated state unless the option requires modification on a case-by-case basis.
-- As this is client-sided there's no way to fully prevent a determined user from changing these values or deleting the script.
-- The client-side intrusion detection is mainly to get rid of your generic skids.
-- I HIGHLY RECOMMEND migrating the script to a game-dependant localscript to discourage changes to the script.

local options = {}
-- How many times should the script run the main check function per second. Some other functions will be constantly run in a secondary loop, but the main system will be hooked up to the tick system.
options.TickRate = 20

-- Allow scripts to be added to the player at runtime.
-- If this is set to false, all scripts added to the player after initialization will be deactivated in studio or deleted while not in studio.
options.AllowPostLaunchScriptActivation = true

-- Set the maximum WalkSpeed a player may have. Make sure to set this to the highest WalkSpeed the player can achieve.
-- If the WalkSpeed is higher than this value, the WalkSpeed will be clamped down to this value.
options.WalkSpeedCheckEnabled = true
options.MaxWalkSpeed = 16

-- Set the maximum JumpPower a player may have. Make sure to set this to the highest JumpPower the player can achieve.
-- If the JumpPower is higher than this value, the JumpPower will be clamped down to this value.
-- If you use JumpHeight instead of JumpPower, set MaxJumpPower to -1 and use the MaxJumpHeight option.
options.JumpPowerCheckEnabled = true
options.MaxJumpPower = 50
options.MaxJumpHeight = -1

-- Limit extra instances under PlayerGui. If an instance is added to PlayerGui that isn't allowed.
options.LimitPlayerGui = true
options.PlayerGuiWhitelist = {} -- FullNames of instances allowed to be added during runtime. This does not automatically include descendants. I may add it as a feature later on if it makes sense to.

return options
