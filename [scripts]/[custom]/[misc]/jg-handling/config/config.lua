Config = {} -- Do not touch

-- General
Config.Locale = "pl"
Config.Framework = "ESX" -- or "none", "QBCore", "Qbox" or "ESX" (frameworks are used for job support, character names etc)
Config.Notifications = "ox_lib" -- or "okokNotify", "ps-ui", "nox_notify", "ox_lib", "default"
Config.SpeedUnit = "kph" -- or "kph"

-- Editor
Config.EditorCommand = "handling" -- chat command
Config.EditorAdminOnly = true -- Set to true for admin only 
Config.EditorJobRestriction = {} -- [Requires framework] Enter jobs here that can use the editor, for example {"mechanic", "government"}. if set to false & EditorAdminOnly is also false, the editor will be public.

-- The timing tool can also be used on it's own, if you set Config.EnableStandaloneTimingTool = true,
-- otherwise it will be locked to use within the handling editor preview only.
Config.EnableStandaloneTimingTool = true
Config.TimingToolOpenCommand = "timingtool"
Config.TimingToolExitCommand = "closetimingtool"
Config.TimingToolAdminOnly = true -- Set to true for admin only
Config.TimingToolJobRestriction = {} -- [Requires framework] Enter jobs here that can use the timing tool, for example {"mechanic", "tuner"}. if set to false & TimingToolAdminOnly is also false, the tool will be public.
Config.TimingToolResetKeyBind = 36
Config.TimingToolResetLabel = "CTRL"

-- Timing tool speed target measurements; values must be in mph, so convert to mph if you use a different unit
Config.SpeedTargets = {
  ["0-100"] = 62,  -- 100 km/h = 62 mph
  ["0-150"] = 93,  -- 150 km/h = 93 mph
  ["0-200"] = 124, -- 200 km/h = 124 mph
  ["0-300"] = 186  -- 300 km/h = 186 mph
}

-- Timing tool distance target measurements, values must be in ft, so convert to ft if you use a different unit
Config.DistanceTargets = { 
  ["100m"] = 328,   -- 100m = 328 ft
  ["200m"] = 656,   -- 200m = 656 ft
  ["400m"] = 1312,  -- 400m = 1312 ft
  ["1000m"] = 3281  -- 1000m = 3281 ft
}

-- Misc
Config.AutoRunSQL = true