OBF = {}
if IsDuplicityVersion() then
    OBF.ENCODE = function(key_one, key_two, text)
        local inv256
        if not inv256 then
            inv256 = {}
            for M = 0, 127 do
                local inv = -1
                repeat
                    inv = inv + 2
                until inv * (2 * M + 1) % 256 == 1
                inv256[M] = inv
            end
        end
        local K, F = key_one, 16384 + key_two
        return (text:gsub(
            ".",
            function(m)
                local L = K % 274877906944
                local H = (K - L) / 274877906944
                local M = H % 128
                m = m:byte()
                local c = (m * inv256[M] - (H - M) / 128) % 256
                K = L * F + H + c + m
                return ("%02x"):format(c)
            end
        ))
    end
else
    OBF.DECODE = function(key_one, key_two, hash)
        local K, F = key_one, 16384 + key_two

        return (hash:gsub(
            "%x%x",
            function(c)
                local L = K % 274877906944
                local H = (K - L) / 274877906944
                local M = H % 128
                c = tonumber(c, 16)
                local m = (c + (H - M) / 128) * (2 * M + 1) % 256
                K = L * F + H + c + m
                return string.char(m)
            end
        ))
    end
end

GetEncryptor = function()
    return OBF
end
