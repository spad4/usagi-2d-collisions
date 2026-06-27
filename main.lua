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
local points2 = {
    Vector2.new({ x = 0, y = 0 }),
    Vector2.new({ x = 16, y = 32 }),
    Vector2.new({ x = 32, y = 32 }),
    Vector2.new({ x = 32, y = 16 }),
}

local polygon = Polygon.new({ corners = points, color = gfx.COLOR_RED, x = 64, y = 64 })
local polygon2 = Polygon.new({ corners = points, color = gfx.COLOR_YELLOW })

Polygons = { polygon, polygon2 }

function _update(dt)
    Elapsed += dt

    polygon:calculate_points_in_space()
    polygon2:calculate_points_in_space()

    for i = 1, #Polygons do
        local first = Polygons[i]
        if input.mouse_held(input.MOUSE_LEFT) and first:encloses(input.mouse()) then
            first.x, first.y = input.mouse()
            first.theta += input.mouse_scroll() * math.pi / 10
        end
        if i == #Polygons then goto continue end
        for j = 2, #Polygons do
            local second = Polygons[j]
            if first:collision_with(second).occurred then
                first.color = gfx.COLOR_TRUE_WHITE
                second.color = gfx.COLOR_TRUE_WHITE
            else
                first.color = gfx.COLOR_RED
                second.color = gfx.COLOR_RED
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

    polygon:draw()
    polygon2:draw()

    local mx, my = input.mouse()
    gfx.px(mx, my, gfx.COLOR_TRUE_WHITE)

end
