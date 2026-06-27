local Polygon = {
    points = { { x = 1, y = 1 }, { x = 2, y = 2 } },
    x = 5,
    y = 0,
    dx = 0,
    dy = 0,
    theta = 0,
    omega = 0,
    color = gfx.COLOR_TRUE_WHITE
}

local colors = {
    gfx.COLOR_BLUE,
    gfx.COLOR_GREEN,
    gfx.COLOR_RED,
    gfx.COLOR_YELLOW,
    gfx.COLOR_DARK_BLUE
}

function Polygon.new(o)
    return setmetatable(o, { __index = Polygon })
end

function Polygon:projection(normal)
    local proj = Projection.new({})

    for _, point in pairs(self.points) do
        local dot = normal:dot(point)
        proj.low = math.min(dot, proj.low)
        proj.high = math.max(dot, proj.high)
    end

    return proj
end

function Polygon:collides_on_my_axes(other)
    local prev_point = self.points[#self.points]
    for i, point in pairs(self.points) do
        local tangent = Vector2.new(util.vec_normalize(point - prev_point))
        local normal = tangent:normal()

        local my_proj = self:projection(normal)
        local o_proj = other:projection(normal)

        -- gfx.line(64 + 8 * (i + 1) + normal.x * my_proj.low / 1, 64 + 8 * (i + 1) + normal.y * my_proj.low / 1,
        --     64 + 8 * (i + 1) + normal.x * my_proj.high / 1,
        --     64 + 8 * (i + 1) + normal.y * my_proj.high / 1, colors[i])
        -- gfx.line(
        --     64 + 8 * (i + 1) + normal.x * o_proj.low / 1,
        --     64 + 8 * (i + 1) + normal.y * o_proj.low / 1,
        --     64 + 8 * (i + 1) + normal.x * o_proj.high / 1,
        --     64 + 8 * (i + 1) + normal.y * o_proj.high / 1, colors[i]
        -- )

        if not my_proj:overlaps(o_proj) then
            return false
        end
        prev_point = point
    end

    return true
end

function Polygon:collides_with(other)
    return self:collides_on_my_axes(other) and other:collides_on_my_axes(self)
end

function Polygon:apply_motion(dt)

end

function Polygon:draw()
    local length = #self.points
    for i = 1, length do
        local p1 = self.points[i]
        local p2 = self.points[i == length and 1 or i + 1]

        -- local hx = p1.x + (p2.x - p1.x) / 2
        -- local hy = p1.y + (p2.y - p1.y) / 2

        -- local tangent = Vector2.new(util.vec_normalize(p2 - p1))
        -- local normal = tangent:normal()

        -- gfx.line(hx, hy, hx + normal.x * 16, hy + normal.y * 16, colors[(i % #colors) + 1])
        -- gfx.line(p1.x, p1.y, p2.x, p2.y, colors[(i % #colors) + 1])
        gfx.line(p1.x, p1.y, p2.x, p2.y, self.color)
    end
end

return Polygon
