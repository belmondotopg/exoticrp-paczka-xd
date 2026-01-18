local function GenerateBucket()
    return math.random(Config.BucketRange[1], Config.BucketRange[2])
end

local function IsBucketFree(bucket)
    local players = GetPlayers()
    for i, player in pairs(players) do
        if GetPlayerRoutingBucket(player) == bucket then
            return false
        end
    end

    return true
end

function GetFreeBucket()
    local bucket = GenerateBucket()
    if not IsBucketFree(bucket) then
        Wait(0)
        return GetFreeBucket()
    end

    return bucket
end
