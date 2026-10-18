class_name Room
extends Node2D
## One chamber. Wires the player, its interactables and the HUD together, and
## keeps the camera inside the chamber's walls.
##
## Putting riddles in a new chamber means building a new scene that inherits
## this behaviour and dropping signs plus one sealed [Door] into it.

@export_multiline var open_door_message: String = "Cold air moves through the opening.\n\nThe way beyond has not been written yet."

@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var walls: TileMapLayer = $Walls


func _ready() -> void:
	_frame_camera()
	player.interactable_changed.connect(_on_interactable_changed)
	player.interacted.connect(_on_interacted)
	hud.panel_opened.connect(_on_panel_opened)
	hud.panel_closed.connect(_on_panel_closed)
	hud.password_attempted.connect(_on_password_attempted)
	hud.book_closed.connect(_on_book_closed)


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
			hud.show_reader("The Open Door", open_door_message)
		else:
			hud.show_lock(door)


func _on_panel_opened() -> void:
	player.can_move = false
	player.halt()
	hud.clear_prompt()


func _on_panel_closed() -> void:
	player.can_move = true
	_on_interactable_changed(player.current_interactable())


func _on_password_attempted(door: Door, text: String) -> void:
	if door.check_password(text):
		hud.set_lock_message("The seal breaks. The door grinds open.", true)
		door.unlock()
	else:
		hud.set_lock_message("The stone stays silent. That is not the word.", false)


## The creators' names have done their job once the book has been read, so they
## fade away and leave the chamber to its riddle.
func _on_book_closed() -> void:
	var order: int = 0
	for node in get_tree().get_nodes_in_group(NamePlate.GROUP_NAME):
		var plate: NamePlate = node as NamePlate
		if plate != null:
			plate.fade_out(1.8, 0.35 * order)
			order += 1
