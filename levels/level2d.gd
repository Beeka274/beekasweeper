extends "res://game.gd".Level
static var levelName = "Not so Familiar"
static var levelIcon = "4β"
static var prereq = "level2c"
static var theme = Level.theme2
static var scrollable = false
static var voidmark = false
static var map = "map"

func add_tiles():
	nextlevel = "level2e"
	for x in range(3): for y in range(3):
		if c(x,y,1,0): add(Tile.new(64*x+32, 64*y+32, Rectangle.new(64,64).shape, {number=game.NumberModifier.new(3),forced=game.ForcedModifier.new(false)}))
		elif c(x,y,2,0):  add(Tile.new(64*x+32, 64*y+32, Rectangle.new(64,64).shape, {forced=game.ForcedModifier.new(true)}))
		elif c(x,y,1,1): add(Tile.new(64*x+32, 64*y+32, Rectangle.new(64,64).shape, {number=game.NumberModifier.new(4),forced=game.ForcedModifier.new(true)}))
		elif c(x,y,2,2): add(Tile.new(64*x+32, 64*y+32, Rectangle.new(64,64).shape, {number=game.NumberModifier.new(2)}))
		else: add(Tile.new(64*x+32, 64*y+32, Rectangle.new(64,64).shape))
