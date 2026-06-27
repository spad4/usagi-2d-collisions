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

    local x_new = corner.x * math.cos(self.theta) - corner.y * math.sin(self.theta)
    local y_new = corner.x * math.sin(self.theta) + corner.y * math.cos(self.theta)

    return Vector2.new({ x = x_new + self.x, y = y_new + self.y })
end

function Polygon:calculate_points_in_space()
    local final = {}
    for i, corner in pairs(self.corners) do
        final[i] = self:point_in_space(corner)
    end

    self.points = final
end

local function between(v, low, high)
    return v <= high and v >= low
end

local function cross_product(x1, x2, y1, y2)
    return x1 * y2 - y1 * x2
end

local function equal_points(x1, y1, x2, y2)
    return x1 == x2 and y1 == y2
end

local function all_equal(...)
    local arg = { ... }

    if #arg > 0 then
        local value = arg[1]
        for i, v in pairs(arg) do
            if v ~= value then
                return false
            end
        end
    end

    return true
end

local function lines_intersect(x1, y1, x2, y2, x3, y3, x4, y4)
    local px, py = x1, y1
    local rx, ry = x2 - x1, y2 - y1

    local qx, qy = x3, y3
    local sx, sy = x4 - x3, y4 - y3

    local dx, dy = qx - px, qy - py

    local t = cross_product(dx, dy, sx, sy) / cross_product(rx, ry, sx, sy)
    local u = cross_product(dx, dy, rx, ry) / cross_product(rx, ry, sx, sy)

    local rxs = cross_product(rx, ry, sx, sy)
    local dxr = cross_product(dx, dy, rx, ry)

    if rxs == 0 and dxr == 0 then -- lines are collinear
        -- points are touching
        if (equal_points(px, py, qx, qy) or equal_points(x2, y2, qx, qy) or equal_points(px, py, x4, y4) or equal_points(x3, y3, x4, y4)) then
            return true
        end

        -- check if lines overlap
        return not all_equal(x3 - x1 < 0, x3 - x2 < 0, x4 - x1 < 0, x4 - x2 < 0)
            or not all_equal(y3 - y1 < 0, y3 - y2 < 0, y4 - y1 < 0, y4 - y2 < 0)
    elseif rxs == 0 and dxr ~= 0 then -- lines are parallel
        return false
    elseif rxs ~= 0 then
        return between(t, 0, 1) and between(u, 0, 1)
    end

    return false
end

function Polygon:encloses(x1, y1)

    local count = 0

    local x2, y2 = x1 + 100, y1
    local prev_point = self.points[#self.points]
    for i, point in pairs(self.points) do
        local x3, y3 = prev_point.x, prev_point.y
        local x4, y4 = point.x, point.y
        if lines_intersect(x1, y1, x2, y2, x3, y3, x4, y4) then
            count += 1
        end
        prev_point = point
    end
    return count % 2 ~= 0
end

function Polygon:collides_on_my_axes(other, collision)
    local prev_point = self.points[#self.points]
    for i, point in pairs(self.points) do

        local tangent = Vector2.new(util.vec_normalize(point - prev_point))
        local normal = tangent:normal()

        local my_proj = self:projection(normal)
        local o_proj = other:projection(normal)

        -- gfx.line(64 + 4 * (i + 1) + normal.x * my_proj.low / 1, 64 + 4 * (i + 1) + normal.y * my_proj.low / 1,
        --     64 + 4 * (i + 1) + normal.x * my_proj.high / 1,
        --     64 + 4 * (i + 1) + normal.y * my_proj.high / 1, colors[i])
        -- gfx.line(
        --     64 + 4 * (i + 1) + normal.x * o_proj.low / 1,
        --     64 + 4 * (i + 1) + normal.y * o_proj.low / 1,
        --     64 + 4 * (i + 1) + normal.x * o_proj.high / 1,
        --     64 + 4 * (i + 1) + normal.y * o_proj.high / 1, colors[i]
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

function Polygon:collision_with(other)
    local collision = Collision_Result.new({})
    local collision2 = Collision_Result.new({})

    local result = self:collides_on_my_axes(other, collision)
    local result2 = other:collides_on_my_axes(self, collision2)
    if result.occurred and result2.occurred then
        result.penetration = math.min(result.penetration, result2.penetration)
        result.occurred = true
        return result
    end

    -- print(usagi.elapsed)
    result.occurred = false
    return result
end

function Polygon:apply_motion(dt)

end

function Polygon:move_to(x, y)
    self.x, self.y = x, y
end

function Polygon:rotate_to(t)
    self.theta = t
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
