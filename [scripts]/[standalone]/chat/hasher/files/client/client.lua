local LocalPlayer = LocalPlayer
local chatInputActive = false
local chatInputActivating = false
local chatVisibilityToggle = false
local SetNuiFocus = SetNuiFocus
local GetPlayerName = GetPlayerName
local ExecuteCommand = ExecuteCommand
local GetRegisteredCommands = GetRegisteredCommands
local IsAceAllowed = IsAceAllowed
local GetNumResources = GetNumResources
local SendNUIMessage = SendNUIMessage
local GetScreenResolution = GetScreenResolution
local GetResourceByFindIndex = GetResourceByFindIndex
local GetResourceState = GetResourceState
local GetNumResourceMetadata = GetNumResourceMetadata
local GetResourceMetadata = GetResourceMetadata

local playerCache = {
    playerId = cache.playerId or PlayerId(),
    coords = cache.coords or GetEntityCoords(PlayerPedId())
}

if lib and lib.onCache then
    lib.onCache('playerId', function(value)
        playerCache.playerId = value
    end)
    
    lib.onCache('coords', function(value)
        playerCache.coords = value
    end)
end

local ESX = nil
if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
end

local twitterDisabled = false
local darkwebDisabled = false

RegisterCommand('togtwt', function(source, args)
    twitterDisabled = not twitterDisabled
    if twitterDisabled then
        ESX.ShowNotification('Wyłączyłeś/aś Twitter!', 'success')
    else
        ESX.ShowNotification('Włączyłeś/aś Twitter!', 'success')
    end
end, false)

RegisterCommand('togdw', function(source, args)
    darkwebDisabled = not darkwebDisabled
    if darkwebDisabled then
        ESX.ShowNotification('Wyłączyłeś/aś DarkWeba!', 'success')
    else
        ESX.ShowNotification('Włączyłeś/aś DarkWeba!', 'success')
    end
end, false)

local function isPlayerAdmin()
    if not Config.HideAdminTyping then
        return false
    end
    
    if ESX and ESX.PlayerData and ESX.PlayerData.group then
        return ESX.PlayerData.group ~= 'user'
    end
    
    return false
end

LocalPlayer.state:set('Writing', false, true)

RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:addSuggestions')
RegisterNetEvent('chat:removeSuggestion')
RegisterNetEvent('chat:clear')
RegisterNetEvent('chat:toggleChat')
RegisterNetEvent('chat:sendNewAddonChatMessage')
RegisterNetEvent('__cfx_internal:serverPrint')
RegisterNetEvent('chat:messageEntered')

AddEventHandler('chatMessage', function(author, color, text)
  local args = { text }

  if author ~= "" then
    table.insert(args, 1, author)
  end
  
  if (not chatVisibilityToggle) and not LocalPlayer.state.InSkin and not LocalPlayer.state.InInventory and not LocalPlayer.state.OnTune and not LocalPlayer.state.CamMode then
    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = {
        color = color,
        multiline = true,
        args = args
      }
    })
  end
end)

AddEventHandler('__cfx_internal:serverPrint', function(msg)
  if(not chatVisibilityToggle) and not LocalPlayer.state.CamMode then
    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = {
        color = { 0, 0, 0 },
        multiline = true,
        args = { msg }
      }
    })
  end
end)

AddEventHandler('chat:sendNewAddonChatMessage', function(title, color, message, icon, color1, color2, msgType, data)
  if msgType then
    if msgType == "twitter" then
      if twitterDisabled then return end
      if ESX.IsPlayerAdminClient() then
        title = ("[%s] %s"):format(data, title)
      end
    elseif msgType == "darkweb" then
      if darkwebDisabled then return end
      if ESX.IsPlayerAdminClient() then
        title = ("[%s] %s"):format(data, title)
      end
    end
  end
  
  if (not chatVisibilityToggle) and not LocalPlayer.state.InSkin and not LocalPlayer.state.InInventory and not LocalPlayer.state.OnTune and not LocalPlayer.state.CamMode then
    
    color2 = color2 or {255, 255, 255}
    color1 = color1 or {255, 255, 255}
    color = color or {255, 255, 255}

    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = {
        color = color1,
        args = {title, message, color[1], color[2], color[3], icon, color1[1], color1[2], color1[3]},
        templateId = 'default'
      }
    })
  end
end)

AddEventHandler('chat:addSuggestion', function(name, help, params)
  SendNUIMessage({
    type = 'ON_SUGGESTION_ADD',
    suggestion = {
      name = name,
      help = help,
      params = params or nil
    }
  })
end)

AddEventHandler('chat:toggleChat',function(state)
  chatVisibilityToggle = state

  TriggerEvent('chat:clear')

  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = {
        color = {255,255,255},
        multiline = true,
        args = {""}
      }
    })
end)

AddEventHandler('chat:addSuggestions', function(suggestions)
  if not suggestions or #suggestions == 0 then return end
  
  SendNUIMessage({
    type = 'ON_SUGGESTIONS_ADD_BATCH',
    suggestions = suggestions
  })
end)

CreateThread(function()
  local lastScreenW, lastScreenH = GetScreenResolution()
  
  SendNUIMessage({
    type = 'CHATSCALE',
    width = (lastScreenW / 2.5) .. 'px'
  })

  while true do
    Wait(5000)
    local screenW, screenH = GetScreenResolution()
    
    if screenW ~= lastScreenW or screenH ~= lastScreenH then
      SendNUIMessage({
        type = 'CHATSCALE',
        width = (screenW / 2.5) .. 'px'
      })
      lastScreenW = screenW
      lastScreenH = screenH
    end
  end
end)

AddEventHandler('chat:removeSuggestion', function(name)
  SendNUIMessage({
    type = 'ON_SUGGESTION_REMOVE',
    name = name
  })
end)

AddEventHandler('chat:clear', function(name)
  SendNUIMessage({
    type = 'ON_CLEAR'
  })
end)

RegisterNUICallback('chatResult', function(data, cb)
  chatInputActive = false
  SetNuiFocus(false)
  
  if not isPlayerAdmin() then
    LocalPlayer.state:set('Writing', false, true)
  end
  
  if not data.canceled then
    local playerId = playerCache.playerId or PlayerId()
    local r, g, b = 0, 0x99, 255

    if data.message and #data.message > 0 then
      if data.message:sub(1, 1) == '/' then
        ExecuteCommand(data.message:sub(2))
      else
        TriggerServerEvent('chat:messageEntered', GetPlayerName(playerId), {r, g, b}, data.message)
      end
    end
  end
  
  cb('ok')
end)

local function refreshCommands()
  if GetRegisteredCommands then
    local registeredCommands = GetRegisteredCommands()
    local suggestions = {}

    for _, command in ipairs(registeredCommands) do
        if IsAceAllowed(('command.%s'):format(command.name)) then
            table.insert(suggestions, {
                name = '/' .. command.name,
                help = ''
            })
        end
    end
    TriggerEvent('chat:addSuggestions', suggestions)
  end
end

local function refreshThemes(force)
  if cachedThemes and not force then
    SendNUIMessage({
      type = 'ON_UPDATE_THEMES',
      themes = cachedThemes
    })
    return
  end

  local themes = {}

  for resIdx = 0, GetNumResources() - 1 do
    local resource = GetResourceByFindIndex(resIdx)
    if GetResourceState(resource) == 'started' then
      local numThemes = GetNumResourceMetadata(resource, 'chat_theme')
      if numThemes > 0 then
        local themeName = GetResourceMetadata(resource, 'chat_theme')
        local themeData = json.decode(GetResourceMetadata(resource, 'chat_theme_extra') or 'null')
        if themeName and themeData then
          themeData.baseUrl = 'nui://' .. resource .. '/'
          themes[themeName] = themeData
        end
      end
    end
  end

  cachedThemes = themes
  SendNUIMessage({
    type = 'ON_UPDATE_THEMES',
    themes = themes
  })
end

local refreshQueued = false
local cachedThemes = nil

local function queueRefresh()
  if refreshQueued then return end
  refreshQueued = true
  SetTimeout(100, function()
    refreshCommands()
    refreshThemes(true)
    refreshQueued = false
  end)
end

AddEventHandler('onClientResourceStart', function(resName)
  queueRefresh()
end)

AddEventHandler('onClientResourceStop', function(resName)
  cachedThemes = nil
  queueRefresh()
end)

RegisterNUICallback('loaded', function(data, cb)
  TriggerServerEvent('chat:init')

  refreshCommands()
  refreshThemes()

  cb('ok')
end)

local chatIndicatorLoaded = false

local function loadChatIndicator()
  if chatIndicatorLoaded then return end
  
  RequestStreamedTextureDict('graphic', true)
  local timeout = 0
  while not HasStreamedTextureDictLoaded('graphic') and timeout < 5000 do
    Wait(10)
    timeout = timeout + 10
  end
  
  if HasStreamedTextureDictLoaded('graphic') then
    local txd = CreateRuntimeTxd('graphic')
    CreateRuntimeTexture(txd, 'BSchat', 350, 150)
    chatIndicatorLoaded = true
  end
end

local function drawChatIndicator(x, y, z)
  if not chatIndicatorLoaded then
    loadChatIndicator()
  end
  
  if chatIndicatorLoaded then
    SetDrawOrigin(x, y, z)
    DrawSprite('graphic', 'BSchat', 0.0, 0.0, 0.013, 0.023, 0.0, 255, 255, 255, 175)
    ClearDrawOrigin()
  end
end

CreateThread(function()
  if not Config.EnableTypingIndicator then
    return
  end
  
  local playerPed = PlayerPedId()
  local GetActivePlayers = GetActivePlayers
  local GetPlayerServerId = GetPlayerServerId
  local GetPlayerPed = GetPlayerPed
  local GetEntityCoords = GetEntityCoords
  local GetPedBoneCoords = GetPedBoneCoords
  local Player = Player
  
  while true do
    local sleep = 1000
    local activePlayers = GetActivePlayers()
    local writingPlayers = {}
    
    for i = 1, #activePlayers do
      local playerId = activePlayers[i]
      local serverPlayerId = GetPlayerServerId(playerId)
      if Player(serverPlayerId).state.Writing then
        writingPlayers[#writingPlayers + 1] = {
          playerId = playerId,
          serverId = serverPlayerId
        }
      end
    end
    
    if #writingPlayers > 0 then
      sleep = 0
      playerPed = PlayerPedId()
      local myCoords = playerCache.coords or GetEntityCoords(playerPed)
      local myServerId = GetPlayerServerId(PlayerId())
      local maxDist = Config.TypingIndicatorDistance

      for i = 1, #writingPlayers do
        local data = writingPlayers[i]
        if data.serverId ~= myServerId then
          local otherPed = GetPlayerPed(data.playerId)
          local otherCoords = GetEntityCoords(otherPed)
          local distance = #(otherCoords - myCoords)
          
          if distance < maxDist then
            local coords = GetPedBoneCoords(otherPed, 12844)
            drawChatIndicator(coords.x, coords.y, coords.z + 0.30)
          end
        end
      end
    end
    
    Wait(sleep)
  end
end)

lib.addKeybind({
  name = 'chat',
  description = 'Chat',
  defaultKey = 'T',
  onPressed = function()
    if chatInputActive then
      SetNuiFocus(false)
      chatInputActive = false
      if not isPlayerAdmin() then 
        LocalPlayer.state:set('Writing', false, true)
      end
    else
      chatInputActive = true
      SetNuiFocus(true)
      SendNUIMessage({
        type = 'ON_OPEN'
      })
      TriggerEvent('chatfocus', true)
      if not isPlayerAdmin() then 
        LocalPlayer.state:set('Writing', true, true)
      end
    end
  end,
  onReleased = function()
    if chatInputActivating then
      SetNuiFocus(true)
      SendNUIMessage({type = 'ON_CLOSE'})
      chatInputActivating = false
    end
  end,
})

RegisterNetEvent('chat:fixNui', function()
  if chatInputActivating then
    SetNuiFocus(true)
    SendNUIMessage({type = 'ON_CLOSE'})
    chatInputActivating = false
  end
end)

exports('addMessage', function(message)
  if type(message) == 'table' then
    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = message
    })
  end
end)

exports('addSuggestion', function(name, help, params)
  SendNUIMessage({
    type = 'ON_SUGGESTION_ADD',
    suggestion = {
      name = name,
      help = help or '',
      params = params or {}
    }
  })
end)

exports('removeSuggestion', function(name)
  SendNUIMessage({
    type = 'ON_SUGGESTION_REMOVE',
    name = name
  })
end)

exports('clearChat', function()
  SendNUIMessage({
    type = 'ON_CLEAR'
  })
end)

exports('isChatOpen', function()
  return chatInputActive
end)

exports('toggleChat', function(state)
  TriggerEvent('chat:toggleChat', state)
end)