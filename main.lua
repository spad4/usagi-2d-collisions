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
end

function _update(dt)
    Elapsed += dt

    -- for i, poly in pairs(Polygons) do
    --     poly:apply_motion(dt)
    -- end

    for i = 1, 4 do
        -- enforce constraints  ??
    end
end

local points = {
    Vector2.new({ x = -16, y = -16 }),
    Vector2.new({ x = 16, y = -16 }),
    Vector2.new({ x = 16, y = 16 }),
    Vector2.new({ x = -16, y = 16 }),
}

local polygon = Polygon.new({ corners = points, color = gfx.COLOR_RED, x = 64, y = 64})
local polygon2 = Polygon.new({ corners = points, color = gfx.COLOR_YELLOW })

-- local test1 = Vector2.new({x = 5, y = 5})
-- local test2 = Vector2.new({x = 10, y = 10})
-- print(usagi.to_json(test1:normal()))

function _draw(dt)
    gfx.clear(gfx.COLOR_BLACK)
    
    polygon2:move_to(input.mouse())
    
    polygon:calculate_points_in_space()
    polygon2:calculate_points_in_space()

    local color = polygon:collide_with(polygon2).occurred and gfx.COLOR_TRUE_WHITE or gfx.COLOR_RED
    polygon.color = color
    polygon2.color = color
    
    polygon:draw()
    polygon2:draw()
end
