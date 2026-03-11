local Tile = {}
Tile.__index = Tile

Tile.SUITS = { "W", "T", "B" }

function Tile.new(suit, rank)
    return setmetatable({ suit = suit, rank = rank }, Tile)
end

function Tile:id()
    return string.format("%s%d", self.suit, self.rank)
end

function Tile:clone()
    return Tile.new(self.suit, self.rank)
end

function Tile.compare(a, b)
    if a.suit == b.suit then
        return a.rank < b.rank
    end
    return a.suit < b.suit
end

function Tile.to_string_list(tiles)
    local labels = {}
    for i, tile in ipairs(tiles) do
        labels[i] = tile:id()
    end
    return table.concat(labels, " ")
end

function Tile.build_standard_wall()
    local wall = {}
    for _, suit in ipairs(Tile.SUITS) do
        for rank = 1, 9 do
            for _ = 1, 4 do
                table.insert(wall, Tile.new(suit, rank))
            end
        end
    end
    return wall
end

return Tile
