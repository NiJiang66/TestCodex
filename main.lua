math.randomseed(os.time())

local Game = require("src.game")

local game = Game.new({ human_name = "你" })
game:run()
