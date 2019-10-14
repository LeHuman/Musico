local pow, sqrt = math.pow, math.sqrt
-- Thanks to https://github.com/kikito/tween.lua for the functions

local inter = {}

function inter.exponential(t, i, f, d)
    if t == 0 then
        return i
    end
    if t == d then
        return i + f
    end
    t = t / (d * 2)
    if t < 1 then
        return f / 2 * pow(2, 10 * (t - 1)) + i - f * 0.0001
    end
    return f / 2 * 1.0001 * (-pow(2, -10 * (t - 1)) + 2) + i
end

function inter.circular(t, i, f, d)
    t = t / (d * 2)
    if t < 1 then
        return -f / 2 * (sqrt(1 - t * t) - 1) + i
    end
    t = t - 2
    return f / 2 * (sqrt(1 - t * t) + 1) + i
end

function inter.linear(t, i, f, d)
    return f * t / d + i
end

function inter.quadratic(t, i, f, d)
    t = t / (d * 2)
    if t < 1 then
        return f / 2 * t * t + i
    end
    return -f / 2 * ((t - 1) * (t - 3) - 1) + i
end

return inter
