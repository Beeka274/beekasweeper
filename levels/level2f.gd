extends "res://game.gd".Level
static var levelName = "Merged"
static var levelIcon = "6β"
static var prereq = "level2e"
static var theme = Level.theme2
static var scrollable = false
static var voidmark = false

func add_tiles():
	nextlevel = "level2g"
	for x in range(3): for y in range(3):
		if c(x,y,1,0): add(Tile.new(64*x+32, 64*y+32, Rectangle.new(64,64).shape, {number=game.NumberModifier.new(2)}))
		elif c(x,y,2,0): add(Tile.new(64*x+32, 64*y+32, Rectangle.new(64,64).shape, {number=game.NumberModifier.new(1)}))
		elif c(x,y,0,1): add(Tile.new(64*x+32, 64*y+32, Rectangle.new(64,64).shape, {number=game.NumberModifier.new(1)}))
		elif c(x,y,0,2): add(Tile.new(64*x+32, 64*y+32, Rectangle.new(128,64).shape,{nuber=game.NumberModifier.new(3)}))
		elif c(x,y,1,2): pass
		else: add(Tile.new(64*x+32, 64*y+32, Rectangle.new(64,64).shape))
