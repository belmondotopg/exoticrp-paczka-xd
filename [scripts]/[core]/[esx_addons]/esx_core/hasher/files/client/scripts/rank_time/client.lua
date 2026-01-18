local LocalPlayer = LocalPlayer
local ESX = ESX
local Citizen = Citizen

local function UpdateRankTime()
	local rankTimeIncrement = 1

	while not ESX.IsPlayerLoaded() do
        Citizen.Wait(200)
    end

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1 * 60000)
			local timeSinceLastInput = GetTimeSinceLastInput(0)
			if timeSinceLastInput < 45000 then
				LocalPlayer.state:set('RankTime', (LocalPlayer.state.RankTime or 0) + rankTimeIncrement, true)
			end
		end
	end)
end

Citizen.CreateThread(UpdateRankTime)