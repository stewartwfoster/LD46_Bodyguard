-- deepcopy to copy bodyparts
function deepcopy(obj)
    if type(obj) ~= 'table' then return obj end
        local res = {}
        for k, v in pairs(obj) do 
            res[deepcopy(k)] = deepcopy(v)
        end
    return res
end

function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function chancetostab(time, min_time)
    --return 0.436621 * math.log(time) - 1.26776
    return 0.00790123 * (time) - 0.054321 -- 0.00790123 * (time - min_time) - 0.054321
end

function get_num_civilians(level)
    --return 3.75 * level * level - 7.25 * level + 8.75
    return 5 * level
    --return 100
end

function clamp(val, min, max)
    if val < min then
        return min
    elseif val > max then
        return max
    end

    return val
end