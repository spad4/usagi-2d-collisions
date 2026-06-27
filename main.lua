Vector2 = require("Vector2")
Polygon = require("Polygon")
Projection = require("Projection")

function _config()
    ---@type Usagi.Config
    return { name = "Game", game_id = "com.spad4.2d_collisions" }
end

function _init()
    State = {}
    Polygons = {}
    Elapsed = 0
    Debug = true
    Selected = nil
end

local points = {
    Vector2.new({ x = -16, y = -16 }),
    Vector2.new({ x = 16, y = -16 }),
    Vector2.new({ x = 16, y = 16 }),
    Vector2.new({ x = -16, y = 16 }),
}
local pentagon = {
    Vector2.new({ x = -16, y = -16 }),
    Vector2.new({ x = 16, y = -16 }),
    Vector2.new({ x = 24, y = 8 }),
    Vector2.new({ x = 0, y = 24 }),
    Vector2.new({ x = -24, y = 8 }),
}
local hexagon = {
    Vector2.new({ x = -16, y = -16 }),
    Vector2.new({ x = 16, y = -16 }),
    Vector2.new({ x = 32, y = 8 }),
    Vector2.new({ x = 16, y = 32 }),
    Vector2.new({ x = -16, y = 32 }),
    Vector2.new({ x = -32, y = 8 }),
}

local polygon = Polygon.new({ corners = points, color = gfx.COLOR_RED, x = 64, y = 64 })
local polygon2 = Polygon.new({ corners = pentagon, color = gfx.COLOR_RED, x = 128, y = 128 })
local polygon3 = Polygon.new({ corners = hexagon, color = gfx.COLOR_RED, x = 192, y = 128 })

Polygons = { polygon, polygon2, polygon3 }

function _update(dt)
    Elapsed += dt

    if input.mouse_released(input.MOUSE_LEFT) then
        Selected = nil
    end

    for _, poly in pairs(Polygons) do
        poly:calculate_points_in_space()
        poly.color = gfx.COLOR_RED
    end

    for i = 1, #Polygons do
        local first = Polygons[i]

        if input.mouse_pressed(input.MOUSE_LEFT) and first:encloses(input.mouse()) then
            Selected = first
        end

        if Selected == first then
            first.x, first.y = input.mouse()
            first.theta += input.mouse_scroll() * math.pi / 8
        end

        if i == #Polygons then goto continue end
        for j = i+1, #Polygons do
            local second = Polygons[j]
            local result = first:collision_with(second)
            if result.occurred then
                first.color = gfx.COLOR_TRUE_WHITE
                second.color = gfx.COLOR_TRUE_WHITE
                -- first.x, first.y = first.x + result.direction.x * result.penetration / 2, first.y + result.direction.y * result.penetration / 2
                -- second.x, second.y = second.x + result.direction.x * result.penetration / -2, second.y + result.direction.y * result.penetration / -2
            end
        end
        ::continue::
    end
end

-- local test1 = Vector2.new({x = 5, y = 5})
-- local test2 = Vector2.new({x = 10, y = 10})
-- print(usagi.to_json(test1:normal()))

function _draw(dt)
    gfx.clear(gfx.COLOR_BLACK)

    for _, poly in pairs(Polygons) do
        poly:draw_filled()
    end

    local mx, my = input.mouse()
    gfx.px(mx, my, gfx.COLOR_TRUE_WHITE)
end
