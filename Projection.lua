local Projection = {
    high = math.mininteger,
    low = math.maxinteger,
}

function Projection.new(o)
    setmetatable(o, {__index = Projection})
    return o
end

function Projection:overlap(other)

    if other.high <= self.low or self.high <= other.low then
        return nil
    else
        return math.min(math.abs(self.low - other.high), math.abs(self.high - other.low))
    end
end

return Projection