
local Scale = {"K", "M", "G", "T", "P", "E", "Z", "Y", [0] = "", [-1] = "m", [-2] = "μ", [-3] = "n", [-4] = "p", [-5] = "f", [-6] = "a", [-7] = "z", [-8] = "y"}

local function format(Number, Split)
    local Index = math.floor(math.log(math.abs(Number), 1000))
    return (Scale[Index] and string.format("%s%s%s", string.gsub(string.format("%#.1f", Number / 10 ^ (Index * 3)), "%.?0*$", ""), Split or " ", Scale[Index])) or (Number == -math.huge or Number == math.huge) and "∞" or (Number ~= Number) and "NaN" or string.format("%g", Number)
end

return function(Duration, Function, ...)
    local Name = debug.getinfo(Function).name

    if #Name == 0 then
        Name = tostring(Function)
    end
    
    print(string.format("Benchmarking %s with a duration of %ss", Name, Duration))

    local Time = 0
    local Count = 0
    local Start = os.clock()

    repeat
        local Clock = os.clock()
        
        Function(...)

        Time = Time + os.clock() - Clock
        Count = Count + 1

        task.wait()
    until os.clock() - Start >= Duration

    local Average = format(Time / Count)
    local Total = math.floor((os.clock() - Start) * 100) / 100
    local CycleTime = format(Total / Count, "/")

    print(string.format("%s took on average %s per cycle and took in total %ss", Name, Average, Total))
    print(string.format("%s was called %s times (%s) in the given duration (%ss)", Name, Count, CycleTime, Duration))

    return {
        Average = Time / Count,
        Total = os.clock() - Start,
        Count = Count,
        CycleTime = (os.clock() - Start) / Count
        Duration = Duration
    }
end
