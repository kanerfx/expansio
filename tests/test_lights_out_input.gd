extends Node


func test_lights_out_is_reachable_from_spawn() -> void:
	var room_scene: PackedScene = load("res://scenes/room_03.tscn") as PackedScene
	var room: Room = room_scene.instantiate() as Room
	add_child(room)
	await get_tree().process_frame
	for _i: int in 4:
		await get_tree().physics_frame
	var puzzle: LightsOut = room.get_node("Props/LightsOut") as LightsOut
	var player: Player = room.get_node("Player") as Player
	assert(puzzle.global_position.distance_to(player.global_position) <= 150.0, "player should spawn beside the console")
	# Step up to the console; it should become the interactable within reach.
	player.global_position = Vector2(224, 176)
	player.velocity = Vector2.ZERO
	for _i: int in 4:
		await get_tree().physics_frame
	assert(player.current_interactable() == puzzle, "the console should be the reachable interactable when the player stands beside it")
	# And the interact key should open the puzzle, not silently do nothing.
	room._on_interacted(puzzle)
	assert(room.get_node("HUD").is_panel_open(), "interacting should open the puzzle panel")