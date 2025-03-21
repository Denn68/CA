local a = 42
local b = 21

local function addition(x, y)
    return x + y
end

local function soustraction(x, y)
    return x - y
end

local function multiplication(x, y)
    return x * y
end

local function division(x, y)
    return x / y
end

local c = addition(a, b)  
print(c)

local d = soustraction(a, b)
print(d)

local e = multiplication(a, b)
print(e)

local f = division(a, b)
print(f)