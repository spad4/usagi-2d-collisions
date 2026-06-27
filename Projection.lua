local Projection = {
    high = math.mininteger,
    low = math.maxinteger,
}

function Projection.new(o)
    setmetatable(o, {__index = Projection})
    return o
end

function Projection:overlaps(other)
    return not (other.high <= self.low or self.high <= other.low)
end

return Projection