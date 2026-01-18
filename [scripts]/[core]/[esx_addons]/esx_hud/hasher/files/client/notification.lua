local SendNUIMessage = SendNUIMessage

local function sendNotification(_text, _type)
	if not _text or _text == "" then return end
	
	SendNUIMessage({
		eventName = "notification:push",
		data = {
			type = _type,
			html = _text,
		}
	})
end

exports('sendNotification', sendNotification)

local isShowingHelpNotification = false

local function helpNotification(action, button, text)
	if isShowingHelpNotification then
		return
	end

	if not action or not button or not text then
		return
	end

	isShowingHelpNotification = true

	SendNUIMessage({
		eventName = "nui:data:update",
		dataId = "textui",
		data = action .. ' [' .. button .. '] ' .. text
	})

	SendNUIMessage({
		eventName = "nui:visible:update",
		elementId = "textui",
		visible = true
	})
end

exports('helpNotification', helpNotification)

local function hideHelpNotification()
	if not isShowingHelpNotification then
		return
	end

	isShowingHelpNotification = false

	SendNUIMessage({
		eventName = "nui:visible:update",
		elementId = "textui",
		visible = false
	})
end

exports('hideHelpNotification', hideHelpNotification)
