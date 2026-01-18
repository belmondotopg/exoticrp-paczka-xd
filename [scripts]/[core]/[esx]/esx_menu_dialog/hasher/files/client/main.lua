Citizen.CreateThread(function()
	local MenuType    = 'dialog'

	local openMenu = function(namespace, name, data)
		local post = true
		data.value = lib.inputDialog(data.title, {'Wprowadź wartość:'})[1]
		local menu = ESX.UI.Menu.GetOpened(MenuType, namespace, name)
		if menu.submit ~= nil then
			if tonumber(data.value) ~= nil then

				data.value = ESX.Math.Round(tonumber(data.value))

				if tonumber(data.value) <= 0 then
					post = false
				end
			end

			data.value = ESX.Math.Trim(data.value)

			if post then
				menu.submit(data, menu)
			else
				ESX.ShowNotification('That input is invalid!')
			end
		end
	end

	local closeMenu = function(namespace, name)
		lib.closeInputDialog()
	end

	ESX.UI.Menu.RegisterType(MenuType, openMenu, closeMenu)

	RegisterNUICallback('menu_submit', function(data, cb)
		local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)
		local post = true

		if menu.submit ~= nil then

			if tonumber(data.value) ~= nil then
				data.value = round(tonumber(data.value))

				if tonumber(data.value) <= 0 then
					post = false
				end
			end

			if post then
				menu.submit(data, menu)
			end
		end

		cb('OK')
	end)

	RegisterNUICallback('menu_cancel', function(data, cb)
		local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		if menu.cancel ~= nil then
			menu.cancel(data, menu)
		end

		cb('OK')
	end)

	RegisterNUICallback('menu_change', function(data, cb)
		local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		if menu.change ~= nil then
			menu.change(data, menu)
		end

		cb('OK')
	end)

	function round(x)
		return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
	end
end)