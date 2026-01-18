local fpsSettingsConfig = {}

local function initializeFpsSettings()
  Citizen.Wait(5000)
  
  local getResourceKvpString = GetResourceKvpString
  local kvpString = getResourceKvpString("fps_booster_settings")
  if kvpString == nil then
    fpsSettingsConfig = Config.GlobalSettings
  else
    local jsonDecode = json.decode
    fpsSettingsConfig = jsonDecode(kvpString)
  end
end

CreateThread(initializeFpsSettings)

local function updateFpsSettings()
  while true do
    Citizen.Wait(1000)
    
    if fpsSettingsConfig.unnecessary then
      ClearBrief()
      ClearGpsFlags()
      ClearPrints()
      ClearSmallPrints()
      ClearReplayStats()
      ClearFocus()
      ClearHdArea()
      LeaderboardsReadClearAll()
      LeaderboardsClearCacheData()
      ClearExtraTimecycleModifier()
      ClearTimecycleModifier()
      DisableScreenblurFade()
    end
    
    if fpsSettingsConfig.broken then
      ClearAllBrokenGlass()
    end
    
    if fpsSettingsConfig.ped then
      local playerPedId = PlayerPedId()
      ClearPedBloodDamage(playerPedId)
      ClearPedWetness(playerPedId)
      ClearPedEnvDirt(playerPedId)
      ResetPedVisibleDamage(playerPedId)
    end
    
    if fpsSettingsConfig.rain then
      SetRainLevel(0.0)
      SetWindSpeed(0.0)
    end
  end
end

CreateThread(updateFpsSettings)

local function updateParticleEffects()
  while true do
    Citizen.Wait(100)
    if fpsSettingsConfig.particles then
      local playerPedId = PlayerPedId()
      local entityCoords = GetEntityCoords(playerPedId)
      RemoveParticleFxInRange(entityCoords, 25.0)
    end
  end
end

CreateThread(updateParticleEffects)

local function optimizeGraphics()
  while true do
    if fpsSettingsConfig.lowTexture or fpsSettingsConfig.lights then
      Citizen.Wait(0)
      
      if fpsSettingsConfig.lowTexture then
        OverrideLodscaleThisFrame(0.6)
        DisableOcclusionThisFrame()
        SetDisableDecalRenderingThisFrame()
      end
      
      if fpsSettingsConfig.lights then
        DisableVehicleDistantlights(false)
        SetFlashLightFadeDistance(3.0)
        SetLightsCutoffDistanceTweak(3.0)
        SetArtificialLightsState(true)
      end
    else
      Citizen.Wait(1000)
    end
  end
end

CreateThread(optimizeGraphics)

local changeSetting
local openFpsMenu
local openMainCategoryMenu
local openWorldCategoryMenu
local openOtherCategoryMenu

local function openMainMenu()
  if not fpsSettingsConfig or next(fpsSettingsConfig) == nil then
    ESX.ShowNotification('Ustawienia są jeszcze ładowane, spróbuj ponownie za chwilę.', 'error')
    return
  end
  
  local menuOptions = {
    {
      title = 'FPS Booster',
      description = 'Zarządzaj ustawieniami optymalizacji FPS',
      icon = 'gauge',
      disabled = true,
    },
    {
      title = 'Główne',
      description = 'Peds, Vehicles, Objects, Particles',
      icon = 'sliders',
      arrow = true,
      onSelect = function()
        openMainCategoryMenu()
      end,
    },
    {
      title = 'Świat',
      description = 'Rain, Shadows, Lights',
      icon = 'globe',
      arrow = true,
      onSelect = function()
        openWorldCategoryMenu()
      end,
    },
    {
      title = 'Inne',
      description = 'Broken Glass, Unnecessary Effects, Ped Effects, Low Texture',
      icon = 'ellipsis-h',
      arrow = true,
      onSelect = function()
        openOtherCategoryMenu()
      end,
    },
  }
  
  lib.registerContext({
    id = 'fps_booster_main',
    title = 'FPS Booster',
    options = menuOptions
  })
  
  lib.showContext('fps_booster_main')
end

openMainCategoryMenu = function()
  local menuOptions = {
    {
      title = 'Powrót',
      description = 'Wróć do głównego menu',
      icon = 'arrow-left',
      onSelect = function()
        openMainMenu()
      end,
    },
    {
      title = 'Główne',
      description = 'Ustawienia główne optymalizacji',
      icon = 'sliders',
      disabled = true,
    },
    {
      title = 'Peds',
      description = (fpsSettingsConfig.peds and '✅ Włączone' or '❌ Wyłączone') .. ' - Optymalizuj renderowanie NPC',
      icon = 'users',
      checked = fpsSettingsConfig.peds,
      onSelect = function()
        changeSetting('peds', not fpsSettingsConfig.peds, 'main')
      end,
    },
    {
      title = 'Vehicles',
      description = (fpsSettingsConfig.vehicles and '✅ Włączone' or '❌ Wyłączone') .. ' - Optymalizuj renderowanie pojazdów',
      icon = 'car',
      checked = fpsSettingsConfig.vehicles,
      onSelect = function()
        changeSetting('vehicles', not fpsSettingsConfig.vehicles, 'main')
      end,
    },
    {
      title = 'Objects',
      description = (fpsSettingsConfig.objects and '✅ Włączone' or '❌ Wyłączone') .. ' - Optymalizuj renderowanie obiektów',
      icon = 'cube',
      checked = fpsSettingsConfig.objects,
      onSelect = function()
        changeSetting('objects', not fpsSettingsConfig.objects, 'main')
      end,
    },
    {
      title = 'Particles',
      description = (fpsSettingsConfig.particles and '✅ Włączone' or '❌ Wyłączone') .. ' - Usuń efekty cząsteczkowe',
      icon = 'star',
      checked = fpsSettingsConfig.particles,
      onSelect = function()
        changeSetting('particles', not fpsSettingsConfig.particles, 'main')
      end,
    },
  }
  
  lib.registerContext({
    id = 'fps_booster_main_cat',
    title = 'FPS Booster - Główne',
    options = menuOptions
  })
  
  lib.showContext('fps_booster_main_cat')
end

openWorldCategoryMenu = function()
  local menuOptions = {
    {
      title = 'Powrót',
      description = 'Wróć do głównego menu',
      icon = 'arrow-left',
      onSelect = function()
        openMainMenu()
      end,
    },
    {
      title = 'Świat',
      description = 'Ustawienia świata i oświetlenia',
      icon = 'globe',
      disabled = true,
    },
    {
      title = 'Rain',
      description = (fpsSettingsConfig.rain and '✅ Włączone' or '❌ Wyłączone') .. ' - Wyłącz deszcz i wiatr',
      icon = 'cloud-rain',
      checked = fpsSettingsConfig.rain,
      onSelect = function()
        changeSetting('rain', not fpsSettingsConfig.rain, 'world')
      end,
    },
    {
      title = 'Shadows',
      description = (fpsSettingsConfig.shadows and '✅ Włączone' or '❌ Wyłączone') .. ' - Wyłącz cienie',
      icon = 'moon',
      checked = fpsSettingsConfig.shadows,
      onSelect = function()
        changeSetting('shadows', not fpsSettingsConfig.shadows, 'world')
      end,
    },
    {
      title = 'Lights',
      description = (fpsSettingsConfig.lights and '✅ Włączone' or '❌ Wyłączone') .. ' - Optymalizuj oświetlenie',
      icon = 'lightbulb',
      checked = fpsSettingsConfig.lights,
      onSelect = function()
        changeSetting('lights', not fpsSettingsConfig.lights, 'world')
      end,
    },
  }
  
  lib.registerContext({
    id = 'fps_booster_world_cat',
    title = 'FPS Booster - Świat',
    options = menuOptions
  })
  
  lib.showContext('fps_booster_world_cat')
end

openOtherCategoryMenu = function()
  local menuOptions = {
    {
      title = 'Powrót',
      description = 'Wróć do głównego menu',
      icon = 'arrow-left',
      onSelect = function()
        openMainMenu()
      end,
    },
    {
      title = 'Inne',
      description = 'Dodatkowe ustawienia',
      icon = 'ellipsis-h',
      disabled = true,
    },
    {
      title = 'Broken Glass',
      description = (fpsSettingsConfig.broken and '✅ Włączone' or '❌ Wyłączone') .. ' - Usuń efekt rozbitego szkła',
      icon = 'shield-alt',
      checked = fpsSettingsConfig.broken,
      onSelect = function()
        changeSetting('broken', not fpsSettingsConfig.broken, 'other')
      end,
    },
    {
      title = 'Unnecessary Effects',
      description = (fpsSettingsConfig.unnecessary and '✅ Włączone' or '❌ Wyłączone') .. ' - Usuń niepotrzebne efekty',
      icon = 'trash',
      checked = fpsSettingsConfig.unnecessary,
      onSelect = function()
        changeSetting('unnecessary', not fpsSettingsConfig.unnecessary, 'other')
      end,
    },
    {
      title = 'Ped Effects',
      description = (fpsSettingsConfig.ped and '✅ Włączone' or '❌ Wyłączone') .. ' - Usuń efekty na pedach',
      icon = 'user',
      checked = fpsSettingsConfig.ped,
      onSelect = function()
        changeSetting('ped', not fpsSettingsConfig.ped, 'other')
      end,
    },
    {
      title = 'Low Texture Mode',
      description = (fpsSettingsConfig.lowTexture and '✅ Włączone' or '❌ Wyłączone') .. ' - Obniżona jakość tekstur',
      icon = 'image',
      checked = fpsSettingsConfig.lowTexture,
      onSelect = function()
        changeSetting('lowTexture', not fpsSettingsConfig.lowTexture, 'other')
      end,
    },
  }
  
  lib.registerContext({
    id = 'fps_booster_other_cat',
    title = 'FPS Booster - Inne',
    options = menuOptions
  })
  
  lib.showContext('fps_booster_other_cat')
end

openFpsMenu = openMainMenu

changeSetting = function(settingKey, value, category)
  fpsSettingsConfig[settingKey] = value
  
  if settingKey == "shadows" then
    local shadowsEnabled = fpsSettingsConfig.shadows
    CascadeShadowsClearShadowSampleType()
    RopeDrawShadowEnabled(not shadowsEnabled)
    CascadeShadowsSetAircraftMode(not shadowsEnabled)
    CascadeShadowsEnableEntityTracker(not shadowsEnabled)
    CascadeShadowsSetDynamicDepthMode(not shadowsEnabled)
    CascadeShadowsSetEntityTrackerScale(1.0)
    CascadeShadowsSetDynamicDepthValue(1.0)
    CascadeShadowsSetCascadeBoundsScale(1.0)
  end
  
  if settingKey == "lights" then
    if not value then
      SetFlashLightFadeDistance(10.0)
      SetLightsCutoffDistanceTweak(10.0)
      SetArtificialLightsState(false)
    end
  end
  
  SetResourceKvp("fps_booster_settings", json.encode(fpsSettingsConfig))
  
  Citizen.Wait(100)
  
  if category == 'main' then
    openMainCategoryMenu()
  elseif category == 'world' then
    openWorldCategoryMenu()
  elseif category == 'other' then
    openOtherCategoryMenu()
  else
    openMainMenu()
  end
end

RegisterCommand(Config.CommandString, function()
  openFpsMenu()
end)

if not Config.DisableKeybind then
  RegisterKeyMapping(Config.CommandString, "Open Fps Booster Menu", "keyboard", Config.Key)
end

local function setSetting(key, value)
  fpsSettingsConfig[key] = value
  SetResourceKvp("fps_booster_settings", json.encode(fpsSettingsConfig))
  print(key .. " has been set to " .. tostring(value) .. " by export!")
end

exports("setSetting", setSetting)
