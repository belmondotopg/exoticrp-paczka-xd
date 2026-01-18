local duiUrl = string.format("https://cfx-nui-%s/web/build/index.html", GetCurrentResourceName())
local screenWidth = math.floor(1920)
local screenHeight = math.floor(1080)
local Duis = {}

function removeAllDuis()
    for k, v in pairs(Duis) do
        removeDui(tonumber(k))
    end
end

function removeDui(prop)
    local propIndexString = tostring(prop)
    DestroyDui(Duis[propIndexString].duiObject)
    Duis[propIndexString].duiObject = nil
    Duis[propIndexString].duiHandle = nil
    Duis[propIndexString] = nil
end

function createDUI(prop)
    local propIndexString = tostring(prop)
    Duis[propIndexString] = {}
    Duis[propIndexString].duiObject = CreateDui(duiUrl, screenWidth, screenHeight)
    Duis[propIndexString].duiHandle = GetDuiHandle(Duis[propIndexString].duiObject)

    local txd = CreateRuntimeTxd('dui_texture_' .. propIndexString)
    local duiTex = CreateRuntimeTextureFromDuiHandle(txd, 'dui_render_' .. propIndexString, Duis[propIndexString].duiHandle)
    local todo = 100

    local positionAbove = GetEntityCoords(prop)

    positionAbove = vec3(positionAbove.x, positionAbove.y, positionAbove.z + 1.4)

    while Duis[propIndexString] do
        local sleep = 100
        local onScreen, screenX, screenY =
        GetScreenCoordFromWorldCoord(positionAbove.x, positionAbove.y, positionAbove.z)
        local camCoord = GetGameplayCamCoord()
        local distance = #(positionAbove - camCoord)
        local playercoords = GetEntityCoords(PlayerPedId())
        local propcoords = positionAbove
        local distance2 = #(playercoords - propcoords)
        local scale = math.max(0.1, 5.0 / distance)

        if distance2 < 10.0 then
            sleep = 0
            DrawSprite('dui_texture_' .. propIndexString, 'dui_render_' .. propIndexString, screenX,
            screenY, scale, scale, 0.0, 255, 255, 255, 255)
        end

        if todo > 0 then
            todo = todo - 1
            SendDuiMessage(Duis[propIndexString].duiObject, json.encode({
                action = "setVisible",
                visible = true
            }))
            
            SendDuiMessage(Duis[propIndexString].duiObject, json.encode({
                action = "setTimer",
                data = {
                    minutes = Global.duiTimestamp
                }
            }))
        end

        Wait(sleep)
    end
end