extends Node2D

func _ready() -> void:
	var room: Node = load("res://scenes/room_03.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	var puzzle: LightsOut = room.get_node("Props/LightsOut") as LightsOut
	print("DEBUG: initial lights=", puzzle.lights)
	room._on_interacted(puzzle)
	print("DEBUG panel open=", room.get_node("HUD").is_panel_open())
	puzzle.press(0)
	print("DEBUG after one press=", puzzle.lights)
	for index in [1, 2, 4, 6, 8]:
		puzzle.press(index)
	print("DEBUG after solution=", puzzle.lights, " solved=", puzzle.is_solved(), " hud=", room.get_node("HUD/PanelLayer/ReaderCenter/ReaderPanel/VBox/Title").text)
	get_tree().quit()
