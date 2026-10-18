extends Node


func test_lights_out_solution_and_room_03_setup() -> void:
	var room_scene: PackedScene = load("res://scenes/room_03.tscn") as PackedScene
	assert(room_scene != null, "room_03 scene should load")
	var room: Room = room_scene.instantiate() as Room
	add_child(room)
	await get_tree().process_frame
	var puzzle: LightsOut = room.get_node("Props/LightsOut") as LightsOut
	assert(puzzle != null, "room_03 should contain exactly one LightsOut puzzle")
	assert(room.get_node_or_null("Props/LightsOut2") == null, "there should not be a duplicate puzzle")
	assert(puzzle.position == Vector2(224, 120), "the puzzle should be centered in the room")
	assert(puzzle.is_in_group("interactable"), "the console should be an interactable the player can reach")
	assert(puzzle.lights == [true, true, true, false, true, false, false, false, false], "initial arrangement should match the answer key")
	# Trigger it the way the player does: the interact key beside the console.
	room._on_interacted(puzzle)
	assert(room.get_node("HUD").is_panel_open(), "interacting with the console should open the puzzle panel")
	for index: int in [0, 1, 2, 4, 6, 8]:
		puzzle.press(index)
	assert(puzzle.lights == [true, true, true, true, true, true, true, true, true], "the solution should turn every lamp on")
	assert(puzzle.is_solved(), "the puzzle should report itself solved")
	var hud: HUD = room.get_node("HUD") as HUD
	assert(hud.is_panel_open(), "solving should reveal the password in the reader panel")
	assert(hud.current_page_body().contains("miséria"), "the reader should reveal the password")
	assert(body_is_pixel(hud), "the reader should render its text as a pixel font texture")
	assert(room.get_node("Props/LightsOut") != null, "the puzzle instance should remain singular")


## True when the reader is showing a baked pixel-font texture rather than a
## plain Label.
func body_is_pixel(hud: HUD) -> bool:
	var text_rect: TextureRect = hud.get_node("PanelLayer/ReaderCenter/ReaderPanel/VBox/Text") as TextureRect
	return text_rect != null and text_rect.texture != null


func test_lights_out_presses_toggle_self_and_neighbours() -> void:
	var puzzle: LightsOut = (load("res://scenes/lights_out.tscn") as PackedScene).instantiate() as LightsOut
	add_child(puzzle)
	await get_tree().process_frame
	puzzle.press(4)
	assert(puzzle.lights == [true, false, true, true, false, true, false, true, false], "pressing a lamp should toggle it and its orthogonal neighbours")


func test_lights_out_ignores_presses_after_solved() -> void:
	var puzzle: LightsOut = (load("res://scenes/lights_out.tscn") as PackedScene).instantiate() as LightsOut
	add_child(puzzle)
	await get_tree().process_frame
	for index: int in [0, 1, 2, 4, 6, 8]:
		puzzle.press(index)
	assert(puzzle.is_solved(), "the solution should solve the puzzle")
	var state: Array[bool] = puzzle.lights.duplicate()
	puzzle.press(4)
	assert(puzzle.lights == state, "a solved puzzle should ignore further presses")
