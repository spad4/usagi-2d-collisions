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
    Vector2.new({ x = 64, y = 64 }),
    Vector2.new({ x = 96, y = 64 }),
    Vector2.new({ x = 96, y = 96 }),
    Vector2.new({ x = 64, y = 96 }),
}


local points2 = {
    Vector2.new({ x = 32, y = 63 }),
    Vector2.new({ x = 96, y = 72 }),
    Vector2.new({ x = 96, y = 96 }),
    Vector2.new({ x = 32, y = 96 }),
}

local polygon = Polygon.new({ points = points, color = gfx.COLOR_RED })
local polygon2 = Polygon.new({ points = points2, color = gfx.COLOR_YELLOW })

-- local test1 = Vector2.new({x = 5, y = 5})
-- local test2 = Vector2.new({x = 10, y = 10})
-- print(usagi.to_json(test1:normal()))

function _draw(dt)
    gfx.clear(gfx.COLOR_BLACK)
    local vec = Vector2.new(util.vec_from_angle(Elapsed, 1))
    local normal = vec:normal()
    
    local mx, my = input.mouse()
    local mp = {
        Vector2.new({ x = mx - 12, y = my - 16 }),
        Vector2.new({ x = mx + 16, y = my - 11 }),
        Vector2.new({ x = mx + 11, y = my + 16 }),
        Vector2.new({ x = mx - 16, y = my + 23 }),
    }
    
    
    local mpoly = Polygon.new({points = mp, color = gfx.COLOR_RED})
    local proj2 = mpoly:projection(normal)
    
    local color = polygon:collides_with(mpoly) and gfx.COLOR_TRUE_WHITE or gfx.COLOR_RED
    polygon.color = color
    mpoly.color = color
    
    mpoly:draw()
    polygon:draw()
end
