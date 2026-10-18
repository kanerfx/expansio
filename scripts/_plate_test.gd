extends Node2D
## Temporary verification scene: checks the room_02 door password and the
## transition to room_03.

func _ready() -> void:
	var room: Node = load("res://scenes/room_02.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	var player: Node2D = room.get_node("Player")
	var door: Door = room.get_node("Props/Door")
	print("TEST naner=", door.check_password("naner"),
		" pombo=", door.check_password("pombo rei"),
		" dest=", door.destination)
	player.global_position = Vector2(216, 40)
	door.unlock()
	print("TEST exit_open=", room.get("_exit_open"))
	Input.action_press("move_up")
	for i in 40:
		await get_tree().physics_frame
	print("TEST player y=", player.global_position.y)
	Input.action_release("move_up")