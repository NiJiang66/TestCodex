local Tile = require("src.tile")

local Wall = {}
Wall.__index = Wall

local function shuffle(arr)
    for i = #arr, 2, -1 do
        local j = math.random(i)
        arr[i], arr[j] = arr[j], arr[i]
    end
end

function Wall.new()
    local tiles = Tile.build_standard_wall()
    shuffle(tiles)
    return setmetatable({ tiles = tiles }, Wall)
end

function Wall:draw()
    return table.remove(self.tiles)
end

function Wall:remaining()
    return #self.tiles
end

return Wall
