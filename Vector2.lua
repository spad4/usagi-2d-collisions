local Vector2 = {
    x = 0,
    y = 0,
}

function Vector2:len()
    return util.vec_dist({ x = 0, y = 0 }, self)
end

function Vector2:dot(other)
    return self.x * other.x + self.y * other.y
end

function Vector2:normal()
    return Vector2.new({x=self.y, y = -self.x})

end

local function subtract(a, b)
    return Vector2.new({ x = a.x - b.x, y = a.y - b.y })
end

function Vector2.new(o)
    setmetatable(o, { __index = Vector2, __sub = subtract })
    return o
end

return Vector2
