class_name Room
extends Node2D
## One chamber. Wires the player, its interactables and the HUD together, and
## keeps the camera inside the chamber's walls.
##
## Putting riddles in a new chamber means building a new scene that inherits
## this behaviour and dropping signs plus one sealed [Door] into it.

@export_multiline var open_door_message: String = "Ar frio atravessa a abertura.\n\nO caminho adiante ainda não foi escrito."

## When true the player's lights are blocked by the chamber's walls, so the
## maze reads only through what the light actually reaches.
@export var shadows_block_light: bool = false

## The player leaves the chamber by crossing this Y line, once its door is open.
const EXIT_Y := 0.0
## Seconds the screen takes to fade out before the next chamber loads.
const FADE_TIME := 0.6

@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var walls: TileMapLayer = $Walls
@onready var _door: Door = get_node_or_null("Props/Door") as Door

## True once the door is open and there is a chamber to step into.
var _exit_open: bool = false
## True while a chamber change is underway, so it only ever fires once.
var _transitioning: bool = false


func _ready() -> void:
	_frame_camera()
	player.interactable_changed.connect(_on_interactable_changed)
	player.interacted.connect(_on_interacted)
	hud.panel_opened.connect(_on_panel_opened)
	hud.panel_closed.connect(_on_panel_closed)
	hud.password_attempted.connect(_on_password_attempted)
	hud.book_closed.connect(_on_book_closed)
	if _door != null:
		_door.unlocked.connect(_on_door_unlocked)
	var lights_puzzle: LightsOut = get_node_or_null("Props/LightsOut") as LightsOut
	if lights_puzzle != null:
		lights_puzzle.solved.connect(_on_lights_out_solved)
	hud.set_room_label("Sala %d" % _room_number())
	if shadows_block_light:
		for node in player.find_children("*", "PointLight2D", true, false):
			var light: PointLight2D = node as PointLight2D
			if light != null:
				light.shadow_enabled = true
	for node in get_tree().get_nodes_in_group("pressure_plate"):
		var plate: PressurePlate = node as PressurePlate
		if plate != null:
			plate.pressed.connect(_on_plate_pressed)


func _physics_process(_delta: float) -> void:
	if not _exit_open or _transitioning:
		return
	if player.global_position.y < EXIT_Y:
		_leave_chamber()


## The chamber's number, read from its scene file name (room_02 -> 2).
func _room_number() -> int:
	var digits: String = ""
	for character in scene_file_path.get_file():
		if character >= "0" and character <= "9":
			digits += character
	return int(digits) if not digits.is_empty() else 0


## Clamps the player camera to the painted tile bounds.
func _frame_camera() -> void:
	if walls.tile_set == null:
		return
	var camera: Camera2D = player.get_node_or_null("Camera2D")
	if camera == null:
		return
	var used: Rect2i = walls.get_used_rect()
	var tile: Vector2i = walls.tile_set.tile_size
	camera.limit_left = used.position.x * tile.x
	camera.limit_top = used.position.y * tile.y
	camera.limit_right = used.end.x * tile.x
	camera.limit_bottom = used.end.y * tile.y


func _on_interactable_changed(target: Interactable) -> void:
	if target == null:
		hud.clear_prompt()
	else:
		hud.set_prompt("[E] %s" % target.prompt)


func _on_interacted(target: Interactable) -> void:
	if target is Sign:
		var board: Sign = target as Sign
		hud.show_reader(board.title, board.body)
	elif target is Bookstand:
		var tome: Bookstand = target as Bookstand
		hud.show_book(tome.titles, tome.bodies)
	elif target is Door:
		var door: Door = target as Door
		if door.is_open:
			hud.show_reader("A Porta Aberta", open_door_message)
		else:
			hud.show_lock(door)
	elif target is LightsOut:
		var puzzle: LightsOut = target as LightsOut
		if not puzzle.is_solved():
			hud.show_puzzle(puzzle)


func _on_panel_opened() -> void:
	player.can_move = false
	player.halt()
	hud.clear_prompt()


func _on_panel_closed() -> void:
	player.can_move = true
	_on_interactable_changed(player.current_interactable())


func _on_password_attempted(door: Door, text: String) -> void:
	if door.check_password(text):
		hud.set_lock_message("O selo se rompe. A porta se abre.", true)
		door.unlock()
	else:
		hud.set_lock_message("A pedra permanece em silêncio. Essa não é a palavra.", false)


## The door swinging open clears the wall, but the way onward only opens once
## there is a chamber waiting on the other side.
func _on_door_unlocked(_opened: Door) -> void:
	if _door.destination.is_empty():
		return
	_exit_open = true
	var threshold: StaticBody2D = get_node_or_null("Threshold") as StaticBody2D
	if threshold != null:
		threshold.set_deferred("collision_layer", 0)


## Fades the screen to black and loads the destination chamber.
func _leave_chamber() -> void:
	_transitioning = true
	player.can_move = false
	player.halt()
	hud.clear_prompt()
	var overlay: ColorRect = _make_fade_overlay()
	var tween: Tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, FADE_TIME)
	await tween.finished
	get_tree().change_scene_to_file(_door.destination)


## A full-screen black rectangle, transparent at first, for fade transitions.
func _make_fade_overlay() -> ColorRect:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var rect: ColorRect = ColorRect.new()
	rect.color = Color(0.0, 0.0, 0.0, 0.0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return rect


## Shows the password textbox when the 3x3 Lights Out puzzle is solved.
func _on_lights_out_solved(puzzle: LightsOut) -> void:
	hud.show_reader(puzzle.solved_title, puzzle.solved_body)


## Reveals a pressure plate's hint in the HUD panel.
func _on_plate_pressed(plate: PressurePlate) -> void:
	hud.show_reader(plate.hint_title, plate.hint_body)


## The creators' names have done their job once the book has been read, so they
## fade away and leave the chamber to its riddle.
func _on_book_closed() -> void:
	var order: int = 0
	for node in get_tree().get_nodes_in_group(NamePlate.GROUP_NAME):
		var plate: NamePlate = node as NamePlate
		if plate != null:
			plate.fade_out(1.8, 0.35 * order)
			order += 1
