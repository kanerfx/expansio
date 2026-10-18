extends Node2D

func _ready() -> void:
	var room: Room = load("res://scenes/room_03.tscn").instantiate() as Room
	add_child(room)
	await get_tree().process_frame
	var puzzle: LightsOut = room.get_node("Props/LightsOut") as LightsOut
	var player: Player = room.get_node("Player") as Player
	print("PLAYER", player.global_position, " PUZZLE", puzzle.global_position)
	print("PUZZLE overlaps bodies", puzzle.get_overlapping_bodies())
	print("INTERACTABLE", player.current_interactable())
	get_tree().quit()
