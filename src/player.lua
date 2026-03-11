local Tile = require("src.tile")
local Rules = require("src.rules")

local Player = {}
Player.__index = Player

function Player.new(name, is_human)
    return setmetatable({
        name = name,
        is_human = is_human or false,
        hand = {},
        discards = {}
    }, Player)
end

function Player:draw(tile)
    table.insert(self.hand, tile)
end

function Player:sort_hand()
    table.sort(self.hand, Tile.compare)
end

function Player:show_hand()
    self:sort_hand()
    return Tile.to_string_list(self.hand)
end

function Player:discard(index)
    local tile = table.remove(self.hand, index)
    if tile then
        table.insert(self.discards, tile)
    end
    return tile
end

function Player:choose_discard_index()
    if not self.is_human then
        return Rules.suggest_discard(self.hand)
    end

    while true do
        io.write(string.format("%s，请输入要打出的牌序号(1-%d)：", self.name, #self.hand))
        local input = io.read("*l")
        local idx = tonumber(input)
        if idx and idx >= 1 and idx <= #self.hand then
            return idx
        end
        print("输入无效，请重试。")
    end
end

function Player:can_win()
    local copy = {}
    for _, tile in ipairs(self.hand) do
        table.insert(copy, tile:clone())
    end
    return Rules.is_standard_win(copy)
end

return Player
