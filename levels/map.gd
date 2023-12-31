extends "res://game.gd".Level
static var levelName = "Map"
static var levelIcon = "M"
static var prereq # hmm
static var theme = {
	unmarked = Color8(64,64,64),
	marked = Color8(160,160,160),
	border = Color8(30,30,30),
	forcedunmarked = Color8(64,64,64),
	forcedmarked = Color8(200,200,200),
	text = Color.WHITE,}
static var scrollable = true
static var voidmark = false

func add_tiles():
	add(game.MapTile.new(32, -400, Rectangle.new(64,64).shape, "happy"))
	add(game.MapTile.new(32, 32, Rectangle.new(64,64).shape, "level1"))
	add(game.MapTile.new(32, 32+64, Rectangle.new(64,64).shape, "level1b"))
	add(game.MapTile.new(32-64, 32+64+32, Rectangle.new(64,64).shape, "level1b2"))
	add(game.MapTile.new(32, 32+64*2, Rectangle.new(64,64).shape, "level1c"))
	add(game.MapTile.new(32, 32+64*3, Rectangle.new(64,64).shape, "level1d"))
	add(game.MapTile.new(32, 32+64*4, Rectangle.new(64,64).shape, "level1e"))
	add(game.MapTile.new(32+64, 32+64*4, Rectangle.new(64,64).shape, "level1A"))
	add(game.MapTile.new(32, 32+64*5, Rectangle.new(64,64).shape, "level2"))
	add(game.MapTile.new(32, 32+64*6, Rectangle.new(64,64).shape, "level2b"))
	add(game.MapTile.new(32, 32+64*7, Rectangle.new(64,64).shape, "level2c"))
	add(game.MapTile.new(32, 32+64*8, Rectangle.new(64,64).shape, "level2d"))
	add(game.MapTile.new(32, 32+64*9, Rectangle.new(64,64).shape, "level2e"))
	add(game.MapTile.new(32, 32+64*10, Rectangle.new(64,64).shape, "level2f"))
	add(game.MapTile.new(32, 32+64*11, Rectangle.new(64,64).shape, "level2g"))
