Framework = nil
Fr = {}

function generatePlate() 
    math.randomseed(GetGameTimer())
    local charSet = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}

    local generatedPlate = nil

    for i = 1, 8 do
        if generatedPlate == nil then
            generatedPlate = charSet[math.random(#charSet)]
        else 
            generatedPlate = generatedPlate .. charSet[math.random(#charSet)] 
        end	
    end

    local isTaken = Fr.IsPlateTaken(generatedPlate)
    if isTaken then 
        return generatePlate()
    end

    return generatedPlate
end