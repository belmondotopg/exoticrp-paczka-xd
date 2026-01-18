local usedBuckets = {}

local function GetFreeBucket()
    local i = 1

    while usedBuckets[i] do
        i = i + 1
    end

    return i
end

exports("GetFreeBucket", GetFreeBucket)

local function SetPlayerBucket(src, bucket)
    local old = GetPlayerRoutingBucket(src)
    
    if old > 0 then
        usedBuckets[old] = nil
        print(("[BUCKET DEBUG] Player %d leaving bucket %d"):format(src, old))
    end

    SetPlayerRoutingBucket(src, bucket)

    if bucket > 0 then
        usedBuckets[bucket] = true
        print(("[BUCKET DEBUG] Player %d assigned to bucket %d"):format(src, bucket))
    else
        print(("[BUCKET DEBUG] Player %d returned to default bucket 0"):format(src))
    end
end

exports("SetPlayerBucket", SetPlayerBucket)

AddEventHandler("playerDropped", function()
    local src = source
    local bucket = GetPlayerRoutingBucket(src)

    if bucket > 0 then
        usedBuckets[bucket] = nil
        print(("[BUCKET DEBUG] Player %d dropped, bucket %d released"):format(src, bucket))
    end
end)