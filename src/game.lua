local Wall = require("src.wall")
local Player = require("src.player")

local Game = {}
Game.__index = Game

function Game.new(config)
    config = config or {}
    local players = {
        Player.new(config.human_name or "玩家", true),
        Player.new("机器人A"),
        Player.new("机器人B"),
        Player.new("机器人C")
    }

    return setmetatable({
        wall = Wall.new(),
        players = players,
        turn = 1,
        winner = nil,
        round = 1
    }, Game)
end

function Game:deal_initial_tiles()
    for _ = 1, 13 do
        for _, player in ipairs(self.players) do
            player:draw(self.wall:draw())
        end
    end
end

function Game:current_player()
    return self.players[self.turn]
end

function Game:advance_turn()
    self.turn = self.turn + 1
    if self.turn > #self.players then
        self.turn = 1
        self.round = self.round + 1
    end
end

function Game:play_turn()
    local player = self:current_player()
    local drawn = self.wall:draw()

    if not drawn then
        return false, "流局：牌墙已空"
    end

    player:draw(drawn)
    print(string.format("\n[第%d巡] %s 摸牌：%s", self.round, player.name, drawn:id()))

    if player.is_human then
        print("你的手牌：" .. player:show_hand())
    end

    if player:can_win() then
        self.winner = player
        return false, string.format("%s 自摸胡牌！", player.name)
    end

    player:sort_hand()
    local discard_index = player:choose_discard_index()
    local discarded = player:discard(discard_index)
    print(string.format("%s 打出：%s", player.name, discarded:id()))

    if player.is_human then
        print("当前手牌：" .. player:show_hand())
    end

    self:advance_turn()
    return true
end

function Game:run()
    print("=== Lua 简化麻将演示 ===")
    self:deal_initial_tiles()
    print("发牌完成，游戏开始。")

    local running = true
    local message = nil
    while running do
        running, message = self:play_turn()
        if self.wall:remaining() <= 0 then
            running = false
            message = message or "流局：牌墙已空"
        end
    end

    print("\n=== 对局结束 ===")
    print(message)
end

return Game
