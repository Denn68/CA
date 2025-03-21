local a = 42
local b = 21

local function addition(x, y)
    local z = x + y
    return z + y
end

local function soustraction(x, y)
    local z = x - y
    return z - y
end

local function multiplication(x, y)
    local z = x * y
    return z * y
end

local function division(x, y)
    local z = x / y
    return z / y
end

local c = addition(a, b)  
print(c)

local d = soustraction(a, b)
print(d)

local e = multiplication(a, b)
print(e)

local f = division(a, b)
print(f)