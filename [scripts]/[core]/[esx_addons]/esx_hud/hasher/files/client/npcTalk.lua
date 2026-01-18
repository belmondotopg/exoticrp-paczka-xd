local ESX = ESX
local TriggerServerEvent = TriggerServerEvent
local LocalPlayer = LocalPlayer

local takingTest = false
local function decrypt(key)
	local result = ""
	for i = 1, #key do
		local char = string.byte(key, i)
		char = char - 3
		result = result .. string.char(char)
	end
	return result
end


local function startDMVTest()
    if takingTest then ESX.ShowNotification('Jesteś w trakcie robienia już jednego testu!') return end
    takingTest = true
    local pages = {}
    for i, question in ipairs(Config.DMVQuestionTable) do
        local buttons = {}
        
        for j, answer in ipairs(question.answers) do
            table.insert(buttons, {
                value = tostring(j),
                label = answer.text,
                correct = answer.correct
            })
        end
        
        table.insert(pages, {
            name = "question_" .. i,
            question = {
                userName = "Instruktor",
                text = question.question
            },
            buttons = buttons
        })
    end

    local dialogId = "dmv-test-" .. GetGameTimer()
    local result = sendNPCDialogSync(dialogId, true, pages)
    
    if not result.cancelled then
        local correctCount = 0
        for pageName, answerIndex in pairs(result.answers) do
            local questionIndex = tonumber(string.match(pageName, "question_(%d+)"))
            if questionIndex and Config.DMVQuestionTable[questionIndex] then
                local answerIndexNum = tonumber(answerIndex)
                if answerIndexNum and Config.DMVQuestionTable[questionIndex].answers[answerIndexNum] and Config.DMVQuestionTable[questionIndex].answers[answerIndexNum].correct then
                    correctCount = correctCount + 1
                end
            end
        end
        
        if correctCount >= #Config.DMVQuestionTable / 2 then
            ESX.ShowNotification('Zdałeś egzamin, gratulacje!')
            TriggerServerEvent('esx_dmvschool:addLicense', 'dmv', decrypt(LocalPlayer.state.playerIndex))
            TriggerServerEvent('esx_dmvschool:reloadLicense')
        else
            ESX.ShowNotification('Oblałeś egzamin, spróbuj ponownie poźniej!')
        end
    end
    
    takingTest = false
end

local function isTakingTest()
    return takingTest
end

local function startWeaponTest()
    if takingTest then ESX.ShowNotification('Jesteś w trakcie robienia już jednego testu!') return end
    takingTest = true
    local pages = {}
    for i, question in ipairs(Config.WeaponQuestionTable) do
        local buttons = {}
        
        for j, answer in ipairs(question.answers) do
            table.insert(buttons, {
                value = tostring(j),
                label = answer.text,
                correct = answer.correct
            })
        end
        
        table.insert(pages, {
            name = "question_" .. i,
            question = {
                userName = "Psycholog",
                text = question.question
            },
            buttons = buttons
        })
    end

    local dialogId = "weapon-test-" .. GetGameTimer()
    local result = sendNPCDialogSync(dialogId, true, pages)
    
    if not result.cancelled then
        local correctCount = 0
        for pageName, answerIndex in pairs(result.answers) do
            local questionIndex = tonumber(string.match(pageName, "question_(%d+)"))
            if questionIndex and Config.WeaponQuestionTable[questionIndex] then
                local answerIndexNum = tonumber(answerIndex)
                if answerIndexNum and Config.WeaponQuestionTable[questionIndex].answers[answerIndexNum] and Config.WeaponQuestionTable[questionIndex].answers[answerIndexNum].correct then
                    correctCount = correctCount + 1
                end
            end
        end
        
        local totalQuestions = #Config.WeaponQuestionTable
        local requiredCorrect = math.ceil(totalQuestions * 0.7)

        if correctCount >= requiredCorrect then
            ESX.ShowNotification('Zdałeś egzamin, gratulacje!')
            TriggerServerEvent('esx_dmvschool:addLicense', 'weapon', decrypt(LocalPlayer.state.playerIndex))
            TriggerServerEvent('esx_dmvschool:reloadLicense')
        else
            ESX.ShowNotification('Oblałeś egzamin, spróbuj ponownie poźniej!')
        end
    end
    
    takingTest = false
end

exports('startDMVTest', startDMVTest)
exports('startWeaponTest', startWeaponTest)
exports('isTakingTest', isTakingTest)