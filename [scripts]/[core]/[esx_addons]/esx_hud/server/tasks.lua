local PlayerTasks = {}
local Tasks = {
    [1] = {
        Type = "Fishing",
        Label = "Wyłów ryby",
        Rewards = {
            money = {2000, 6500},
            fishing_case = {1, 3},
            daily_case = {1, 1}
        },
        TaskAmount = {20, 35},
        TaskProgress = 0
    },

    [2] = {
        Type = "DrugsCollect",
        Label = "Przygotuj towar",
        Rewards = {
            money = {3500, 9000},
            daily_case = {1, 2}
        },
        TaskAmount = {20, 60},
        TaskProgress = 0
    },

    [3] = {
        Type = "Drugs",
        Label = "Sprzedaj towar",
        Rewards = {
            money = {5000, 13000},
            cocaine_packaged = {3, 6}, -- mniej itemów, bo i tak jest kasa + case
            daily_case = {1, 2}
        },
        TaskAmount = {15, 35},
        TaskProgress = 0
    },

    [4] = {
        Type = "Money",
        Label = "Wydaj pieniądze",
        Rewards = {
            money = {2000, 8000},
            daily_case = {1, 2}
        },
        TaskAmount = {20000, 75000},
        TaskProgress = 0
    },

    [5] = {
        Type = "Scratchcard",
        Label = "Zdrap zdrapki",
        Rewards = {
            money = {1500, 6000},
            scratchcardpremium = {1, 2},
            daily_case = {1, 1}
        },
        TaskAmount = {3, 8},
        TaskProgress = 0
    },

    [6] = {
        Type = "HouseRobbery",
        Label = "Obrabuj domy",
        Rewards = {
            money = {6000, 15000},
            advancedlockpick = {1, 2},
            daily_case = {1, 2}
        },
        TaskAmount = {3, 7},
        TaskProgress = 0
    },

    [7] = {
        Type = "Garbage",
        Label = "Zbierz worki ze śmieciami",
        Rewards = {
            money = {2500, 7000},
            daily_case = {1, 1}
        },
        TaskAmount = {15, 30},
        TaskProgress = 0
    },

    [8] = {
        Type = "Taxi",
        Label = "Wykonaj kursy taksówką",
        Rewards = {
            money = {3000, 9000},
            daily_case = {1, 1}
        },
        TaskAmount = {6, 14},
        TaskProgress = 0
    },

    [9] = {
        Type = "Mechanic",
        Label = "Napraw pojazdy",
        Rewards = {
            money = {3500, 11000},
            repairkit = {1, 2},
            daily_case = {1, 1}
        },
        TaskAmount = {4, 10},
        TaskProgress = 0
    },

    [10] = {
        Type = "EMS",
        Label = "Udziel pomocy medycznej",
        Rewards = {
            money = {4000, 12000},
            bandage = {5, 12},
            daily_case = {1, 2}
        },
        TaskAmount = {2, 6},
        TaskProgress = 0
    }
}

local function GetRandomTasks(playerData)
    local SelectedTasks = {}
    local AlreadySelected = {}
    
    local hasAmbulanceJob = playerData and playerData.job and (playerData.job.name == 'ambulance')
    local hasMechanicJob = playerData and playerData.job and (playerData.job.name == 'mechanik' or playerData.job.name == 'ec')
    
    local availableTasks = {}
    for i, task in ipairs(Tasks) do
        if task.Type ~= "EMS" or hasAmbulanceJob then
            table.insert(availableTasks, i)
        end
        if task.Type ~= "Mechanic" or hasMechanicJob then
            table.insert(availableTasks, i)
        end
    end
    
    local taskCount = math.min(4, #availableTasks)

    repeat
        local randomIndex = math.random(1, #availableTasks)
        local taskIndex = availableTasks[randomIndex]
        if not AlreadySelected[taskIndex] then
            local task = Tasks[taskIndex]
            local minTaskAmount = math.min(task.TaskAmount[1], task.TaskAmount[2])
            local maxTaskAmount = math.max(task.TaskAmount[1], task.TaskAmount[2])
            SelectedTasks[#SelectedTasks + 1] = {
                Type = task.Type,
                Label = task.Label,
                Rewards = task.Rewards,
                TaskAmount = math.random(minTaskAmount, maxTaskAmount),
                TaskProgress = 0,
                Timestamp = os.time(),
                completed = false
            }
            AlreadySelected[taskIndex] = true
        end
    until #SelectedTasks == taskCount

    return SelectedTasks
end

local function LoadTasks(source)
    local src = source
    local data = ESX.GetPlayerFromId(src)
    if not data then return end

    local CurrentDate = os.date("%d-%m-%Y")
    local TasksQuery = MySQL.query.await("SELECT tasks_data FROM user_tasks WHERE identifier = ? AND tasks_date = ?", {data.identifier, CurrentDate})

    local hasAmbulanceJob = data.job and  (data.job.name == 'ambulance')
    local hasMechanicJob = data.job and (data.job.name == 'mechanik' or data.job.name == 'ec')

    if TasksQuery and TasksQuery[1] then
        PlayerTasks[src] = json.decode(TasksQuery[1].tasks_data)
        
        if not hasAmbulanceJob then
            for i = #PlayerTasks[src], 1, -1 do
                if PlayerTasks[src][i].Type == "EMS" then
                    table.remove(PlayerTasks[src], i)
                end
            end
            MySQL.query.await("UPDATE user_tasks SET tasks_data = ? WHERE identifier = ? AND tasks_date = ?", {json.encode(PlayerTasks[src]), data.identifier, CurrentDate})
        end

        if not hasMechanicJob then
            for i = #PlayerTasks[src], 1, -1 do
                if PlayerTasks[src][i].Type == "Mechanic" then
                    table.remove(PlayerTasks[src], i)
                end
            end
            MySQL.query.await("UPDATE user_tasks SET tasks_data = ? WHERE identifier = ? AND tasks_date = ?", {json.encode(PlayerTasks[src]), data.identifier, CurrentDate})
        end
        
        for _, task in pairs(PlayerTasks[src]) do
            if task.completed == nil then
                task.completed = (task.TaskProgress >= task.TaskAmount)
            end
        end
    else
        local SelectedTasks = GetRandomTasks(data)
        MySQL.query.await("INSERT INTO user_tasks VALUES (?,?,?,?)", {data.identifier, json.encode(SelectedTasks), CurrentDate, os.time()})
        PlayerTasks[src] = SelectedTasks
    end
end

local function GetTasksData(source)
    local src = source
    local PlayerActiveTasks = PlayerTasks[src]
    if not PlayerActiveTasks then return {} end

    local data = ESX.GetPlayerFromId(src)
    local hasAmbulanceJob = data and data.job and  (data.job.name == 'ambulance')
    local hasMechanicJob = data and data.job and (data.job.name == 'mechanik' or data.job.name == 'ec')

    local TasksData = {}
    for _, taskData in pairs(PlayerActiveTasks) do
        if taskData.Type ~= "EMS" or hasAmbulanceJob then
            TasksData[#TasksData + 1] = {
                id = taskData.Type,
                name = taskData.Label,
                progress = {taskData.TaskProgress, taskData.TaskAmount},
                ts = taskData.Timestamp
            }
        end
        if taskData.Type ~= "Mechanic" or hasMechanicJob then
            TasksData[#TasksData + 1] = {
                id = taskData.Type,
                name = taskData.Label,
                progress = {taskData.TaskProgress, taskData.TaskAmount},
                ts = taskData.Timestamp
            }
        end
    end

    return TasksData
end

local function GetTaskByType(source, TaskType)
    local src = source
    local playerTasks = PlayerTasks[src]
    if not playerTasks then return nil end

    for index, taskData in pairs(playerTasks) do
        if taskData.Type == TaskType then
            return index
        end
    end
    return nil
end

local function UpdateTaskProgress(source, TaskType, TaskValue)
    local src = source
    local data = ESX.GetPlayerFromId(src)
    if not data then return end

    local playerTasks = PlayerTasks[src]
    if not playerTasks then return end

    local TaskIndex = GetTaskByType(src, TaskType)
    if not TaskIndex then return end

    local SelectedTask = playerTasks[TaskIndex]
    if not SelectedTask then return end

    if SelectedTask.completed or (SelectedTask.TaskProgress >= SelectedTask.TaskAmount) then
        return
    end

    TaskValue = TaskValue or 1
    SelectedTask.TaskProgress = SelectedTask.TaskProgress + TaskValue

    if SelectedTask.TaskProgress >= SelectedTask.TaskAmount then
        SelectedTask.completed = true
        
        for itemName, rewardAmount in pairs(SelectedTask.Rewards) do
            if type(rewardAmount) == "table" and rewardAmount[1] and rewardAmount[2] then
                local min = math.min(rewardAmount[1], rewardAmount[2])
                local max = math.max(rewardAmount[1], rewardAmount[2])
                local ItemCount = math.random(min, max)
                data.addInventoryItem(itemName, ItemCount)
            end
        end
        data.showNotification("Ukończyłeś zadanie (" .. SelectedTask.Label .. ") Nagroda została dodana do twojego ekwipunku")
    else
        data.showNotification("Otrzymałeś punkt do Zadania (" .. SelectedTask.Label .. ")")
    end

    if data.identifier then
        MySQL.query.await("UPDATE user_tasks SET tasks_data = ? WHERE identifier = ? AND tasks_date = ?", {json.encode(playerTasks), data.identifier, os.date("%d-%m-%Y")})
    end
end
exports("UpdateTaskProgress", UpdateTaskProgress)

local function GetRandomItem()
    if not Config or not Config.DailyCase then return nil end

    local Chance = math.random(0, 100)
    for itemName, currentItem in pairs(Config.DailyCase) do
        if Chance >= currentItem.Chance[1] and Chance <= currentItem.Chance[2] then
            if type(currentItem.Amount) == "table" and currentItem.Amount[1] and currentItem.Amount[2] then
                local minAmount = math.min(currentItem.Amount[1], currentItem.Amount[2])
                local maxAmount = math.max(currentItem.Amount[1], currentItem.Amount[2])
                return {itemName, math.random(minAmount, maxAmount)}
            end
        end
    end
    
    return {"empty", 0}
end

RegisterServerEvent("esx_hud:updateDrivenDistance", function(Distance)
    local src = source
    local playerTasks = PlayerTasks[src]
    if not playerTasks then return end

    local taskIndex = GetTaskByType(src, "Drive")
    if not taskIndex then return end

    local driveTask = playerTasks[taskIndex]
    if not driveTask then return end

    local maxDistance = driveTask.TaskAmount - driveTask.TaskProgress
    if Distance > maxDistance then
        Distance = maxDistance
    end

    UpdateTaskProgress(src, "Drive", Distance)
end)

RegisterServerEvent("esx_hud:loadPlayerTasks", function()
    LoadTasks(source)
end)

AddEventHandler("onResourceStart", function(ResourceName)
    if GetCurrentResourceName() == ResourceName then
        for _, currentPlayer in pairs(ESX.GetExtendedPlayers()) do
            LoadTasks(currentPlayer.source)
        end
    end
end)

RegisterCommand("zadania", function(source)
    local src = source
    local TasksData = GetTasksData(src)
    TriggerClientEvent("esx_hud:showTasksNUI", src, TasksData)
end)

exports('openCase', function(event, item, inventory, slot, data)
    if event == "usingItem" then
        local src = inventory.id
        local playerData = ESX.GetPlayerFromId(src)
        if not playerData then
            return false
        end

        local randomItem = GetRandomItem()
        if not randomItem then 
            playerData.showNotification("Wystąpił błąd podczas otwierania skrzynki. Spróbuj ponownie.", "error")
            return false
        end

        local itemName = randomItem[1]
        local itemCount = randomItem[2]

        if itemName == "empty" then
            playerData.showNotification("Skrzynia była pusta. Spróbuj ponownie następnym razem.", "error")
            return
        elseif itemName == "money" then
            playerData.addMoney(itemCount)
            playerData.showNotification("Z Skrzyni Zadań wypadło $" .. itemCount .. " gotówki")
        else
            local success, error = pcall(function()
                playerData.addInventoryItem(itemName, itemCount)
            end)
            
            if success then
                local itemData = playerData.getInventoryItem(itemName)
                if itemData then
                    playerData.showNotification("Z Skrzyni Zadań wypadło x" .. itemCount .. " - " .. itemData.label)
                else
                    playerData.showNotification("Z Skrzyni Zadań wypadło x" .. itemCount .. " - " .. itemName)
                end
            else
                playerData.showNotification("Wystąpił błąd podczas dodawania przedmiotu. Skrzynia nie została zużyta.", "error")
                return false -- Zwróć false aby anulować użycie przedmiotu
            end
        end
    end
end)
