local ESX = ESX
local Citizen = Citizen
local TriggerServerEvent = TriggerServerEvent
local LocalPlayer = LocalPlayer
local GetWeaponComponentDamageModifier = GetWeaponComponentDamageModifier

local function CheckComponents()
	for k,v in pairs(Config.WeaponComponents) do
		local dmg = GetWeaponComponentDamageModifier(v)
		if dmg > 1.01 then
			TriggerServerEvent("esx_core:onDetectSomething", "DMG Boost detected, difference: "..dmg, ESX.GetClientKey(LocalPlayer.state.playerIndex))
			break
		end
	end
end

Citizen.CreateThread(CheckComponents)