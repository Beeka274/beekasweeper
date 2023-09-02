extends Node

var check
var level

func _ready():
	randomize()
	load_level("level1")
	check = CheckTile.new(64,400,PackedVector2Array([Vector2(64,0),Vector2(128,64),Vector2(64,128),Vector2(0,64)]),{text = TextModifier.new("C")})
	add_child(check)
	check.checked.connect(level.check)

func load_level(nextlevel):
	level = load("res://levels/" + nextlevel + ".gd").new()
	if check: check.checked.connect(level.check)
	add_child(level)

func get_level(): return level

class Level:
	extends Node
	
	var nextlevel = ""
	var style = {}
	var tiles = []
	var vertices = {}
	@onready var game = get_node("/root/game")
	var changed_since_unhappy = true
	
	func _init(Style:={unmarked = Color.WEB_GRAY,marked = Color.LIGHT_GRAY,border = Color.DARK_GRAY,forcedunmarked = Color.DIM_GRAY,forcedmarked = Color.WHITE_SMOKE,number = Color.WHITE,}):
		style = Style
	
	func _ready():
		add_tiles()
		for tile in tiles:
			tile.add_connections()
		for tile in tiles:
			tile.check_connections()
		for tile in tiles:
			tile.load_modifiers()
	
	func get_level(): return self
	
	func add_tiles():
		pass
	
	func add(tile:Tile) -> void:
		tiles.append(tile)
		add_child(tile)
	
	func check():
		var okay = true
		for tile in tiles:
			for modifier in tile.modifiers:
				if !tile.modifiers[modifier].check(): okay = false
		if okay:
			game.check.checked.disconnect(self.check)
			for t in tiles:
				t.next_level()
			await get_tree().create_timer(1.2).timeout
			await game.load_level(nextlevel)
			queue_free()
			
		else:
			changed_since_unhappy = false
	
	class Rectangle:
		var shape
		
		func _init(X:int,Y:int): shape = PackedVector2Array([Vector2(0,0),Vector2(X,0),Vector2(X,Y),Vector2(0,Y)])
	
	class Tile:
		extends Area2D
		
		var collision = CollisionPolygon2D.new()
		var display = Polygon2D.new()
		var border = Line2D.new()
		var hovered = false
		var marked = false
		var modifiers = {}
		var polygon:PackedVector2Array
		var style
		var tween
		var pos
		var addedpos = Vector2(0,0)
		var shape
		@onready var level = get_parent().get_level()
		var id
		var shared_vertices = []
		
		#https://www.reddit.com/r/godot/comments/b0r9l4/is_it_possible_to_get_the_bounding_box_of_a/
		const MAX_COORD = pow(2,31)-1
		const MIN_COORD = -MAX_COORD
		var box # your polygon bounding box (Rect2)
		
		func minv(curvec,newvec):
			return Vector2(min(curvec.x,newvec.x),min(curvec.y,newvec.y))
		func maxv(curvec,newvec):
			return Vector2(max(curvec.x,newvec.x),max(curvec.y,newvec.y))
	
		func on_change_my_poly():
			var min_vec = Vector2(MAX_COORD,MAX_COORD)
			var max_vec = Vector2(MIN_COORD,MIN_COORD)
			for v in shape:
				min_vec = minv(min_vec,v)
				max_vec = maxv(max_vec,v)
			box = Rect2(min_vec,max_vec-min_vec)
		
		
		func _init(X:int,Y:int,Shape:PackedVector2Array,Modifiers:={}):
			self.add_child(collision)
			self.add_child(display)
			self.add_child(border)
			pos = Vector2(X,Y)
			shape = Shape
			collision.polygon = Shape
			display.polygon = Shape
			border.points = Shape
			border.add_point(Shape[0])
			border.joint_mode = Line2D.LINE_JOINT_ROUND
			border.end_cap_mode = Line2D.LINE_CAP_ROUND
			modifiers = Modifiers
			for modifier in modifiers:
				add_child(modifiers[modifier])
			for vertex in range(len(shape)):
				shape[vertex] += pos
		
		func _ready():
			# may not be consistent? idk
			load_style()
			id = len(level.tiles)-1
			border.default_color = style.border
			self.mouse_entered.connect(set_hovered.bind(true))
			self.mouse_exited.connect(set_hovered.bind(false))
			if modifiers.has("forced"): marked = modifiers.forced.state == ForcedModifier.forced_state.MARKED
			update_display()
			on_change_my_poly()
			pos.y += 300
			modulate.a = 0
			await get_tree().create_timer(randf_range(0,0.3)).timeout
			var tweenstart = get_tree().create_tween().set_parallel()
			tweenstart.tween_property(self, "pos:y", pos.y-300, 1).set_trans(Tween.TRANS_EXPO)
			tweenstart.tween_property(self, "modulate:a", 1, 0.5).set_delay(0.5)
		
		func load_style():
			style = get_parent().style
		
		func _process(_delta):
			# sin
			position = pos + addedpos
		
		func set_hovered(toSet:bool) -> void:
			hovered = toSet
			if hovered:
				tween = get_tree().create_tween().set_parallel()
				tween.tween_property(self, "scale", Vector2(1.2,1.2), 0.2).set_trans(Tween.TRANS_SINE)
				tween.tween_property(self, "addedpos", box.size*Vector2(-0.1,-0.1), 0.2).set_trans(Tween.TRANS_SINE)
				z_index = 1
			else:
				tween = get_tree().create_tween()
				tween.parallel().tween_property(self, "scale", Vector2(1,1), 0.2).set_trans(Tween.TRANS_SINE)
				tween.parallel().tween_property(self, "addedpos", Vector2(0,0), 0.2).set_trans(Tween.TRANS_SINE)
				z_index = 0
		
		func _input(Event):
			if Event.is_action_pressed("LClick"):
				if !hovered: return
				if modifiers.has("forced"): return
				# call the signal here
				marked = !marked
				update_display()
				level.changed_since_unhappy = true
		
		func update_display():
			if marked: 
				if modifiers.has("forced"): display.color = style.forcedmarked
				else: display.color = style.marked
			else:
				if modifiers.has("forced"): display.color = style.forcedunmarked
				else: display.color = style.unmarked
		
		func add_connections():
			for vertex in shape:
				if vertex in level.vertices:
					level.vertices[vertex].append(id)
				else:
					level.vertices[vertex] = [id]
		
		func check_connections():
			for vertex in shape:
				shared_vertices.append(level.vertices[vertex].duplicate())
				shared_vertices[-1].erase(id)
		
		func load_modifiers():
			for modifier in modifiers:
				modifiers[modifier]._load()
		
		func next_level():
			await get_tree().create_timer(randf_range(0.3,0.6)).timeout
			var tweenend = get_tree().create_tween().set_parallel()
			tweenend.tween_property(self, "pos:y", pos.y+300, 1).set_trans(Tween.TRANS_EXPO)
			tweenend.tween_property(self, "modulate:a", 0, 0.5)
			await tweenend.finished
			queue_free()

class CheckTile:
	extends Level.Tile
	
	signal checked
	
	func load_style():
		style = get_parent().level.style
	
	func _input(Event):
		if Event.is_action_pressed("LClick"):
			if !hovered: return
			if modifiers.has("forced"): return
			checked.emit()


class Modifier:
	extends Node
	
	@onready var tile = get_parent()
	@onready var level = get_parent().get_parent()
	
	var display
	var pos = Vector2(0,0)
	var shaking = false
	
	#no overrideable constants :sob:
	static func condition(): return false
	
	func _process(_delta):
		if !condition(): return
		if !display: return
		if level.changed_since_unhappy:
			shaking = false
			display.position = pos
		if shaking:
			display.position = pos + Vector2(randi() % 4-2,randi() % 4-2)
	
	func _load():
		pass
	
	func check():
		return true

class ForcedModifier:
	extends Modifier
	
	enum forced_state {
		MARKED,
		UNMARKED,
	}
	var state:forced_state
	
	func _init(State:forced_state):
		state = State

class TextModifier:
	extends Modifier
	
	var text : String
	
	func _ready():
		tile.add_child.call_deferred(display)
	
	func _load():
		on_load()
	
	func on_load():
		display.size = tile.box.size
		display.z_index = 1
	
	func _init(Text:String):
		text = Text
		load_display()
	
	func load_display():
		display = Label.new()
		display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		display.text = text
		display.add_theme_font_size_override("font_size", int(500/display.get_minimum_size().x))
		display.add_theme_color_override("font_color", Color.WHITE)
		pos.y -= 40/display.get_minimum_size().x
		display.position = pos

class NumberModifier:
	extends TextModifier
	
	var tiles_touching = []
	var num : int
	
	static func condition(): return true
	
	func _init(Num:int):
		num = Num
		text = str(num)
		load_display()
	
	func _load():
		on_load()
		get_tiles_touching()
	
	func get_tiles_touching():
		tiles_touching = []
		for vertex in tile.shared_vertices:
			for t in vertex:
				if not t in tiles_touching:
					tiles_touching.append(t)
	
	func check():
		var count = 0
		for t in tiles_touching:
			if level.tiles[t].marked: count += 1
		if count != num: shaking = true
		return count == num
