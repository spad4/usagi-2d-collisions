local Polygon = {
    corners = { { x = -1, y = -1 }, { x = 2, y = 2 } },
    points = { { x = -1, y = -1 }, { x = 2, y = 2 } },
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    theta = 0,
    omega = 0,
    color = gfx.COLOR_TRUE_WHITE
}

local Collision_Result = {
    occurred = false,
    penetration = math.maxinteger,
    direction = { x = 0, y = 0 }
}

function Collision_Result.new(o)
    return setmetatable(o, { __index = Collision_Result })
end

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

function Polygon:point_in_space(corner)
    return Vector2.new({ x = corner.x + self.x, y = corner.y + self.y })
end

function Polygon:calculate_points_in_space()
    local final = {}
    for i, corner in pairs(self.corners) do
        final[i] = self:point_in_space(corner)
    end

    self.points = final
end

function Polygon:collides_on_my_axes(other, collision)
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

        local penetration = my_proj:overlap(o_proj)
        if penetration then
            if penetration < collision.penetration then
                collision.penetration = penetration
                collision.direction = normal
            end
        else
            collision.occurred = false
            return collision
        end
        prev_point = point
    end

    collision.occurred = true
    return collision
end

function Polygon:collide_with(other)
    local collision = Collision_Result.new({})

    local result = self:collides_on_my_axes(other, collision)
    if result.occurred then
        return result
    end

    result = other:collides_on_my_axes(self, collision)
    return result
end

function Polygon:apply_motion(dt)

end

function Polygon:move_to(x, y)
    self.x, self.y = x, y
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

        -- gfx.line(hx, hy, hx + normal.x * 16, hy + normal.y * 16, colors[((i-1) % #colors) + 1])
        -- gfx.line(p1.x, p1.y, p2.x, p2.y, colors[((i-1) % #colors) + 1])
        gfx.line(p1.x, p1.y, p2.x, p2.y, self.color)
    end
end

return Polygon
