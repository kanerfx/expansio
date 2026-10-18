class_name LightsOut
extends Interactable
## A 3x3 "Lights Out" console. Pressing one lamp toggles it and its orthogonal
## neighbours; turning every lamp on reveals the chamber's password.
##
## The console itself is a single prop the player walks up to and triggers with
## the interact key. The grid of lamps lives in the HUD puzzle panel (driven by
## [member changed]), so the puzzle reads at panel scale instead of as tiny
## click targets lost in the world.

## Emitted once every lamp is lit.
signal solved(puzzle: LightsOut)
## Emitted after every press, so any view of the puzzle can redraw itself.
signal changed()

@export var lit_texture: Texture2D
@export var unlit_texture: Texture2D
## Heading shown at the top of the puzzle panel.
@export var title: String = "ENIGMA DAS LUZES"
## Instruction shown beneath the grid.
@export_multiline var hint: String = "Pressione uma luz para alternar ela e as luzes ao lado.\nAcenda todas para revelar a senha."
@export var start_lights: Array[bool] = [true, true, true, false, true, false, false, false, false]
@export var solved_title: String = "SENHA"
@export_multiline var solved_body: String = "Senha"

const GRID_SIZE: int = 3
const CELL_COUNT: int = GRID_SIZE * GRID_SIZE

## Current state of the nine lamps, row by row, true meaning lit.
var lights: Array[bool] = []
var _is_solved: bool = false


func _ready() -> void:
	super()
	if prompt == "Interact":
		prompt = "Jogar"
	lights = start_lights.duplicate()
	if lights.size() != CELL_COUNT:
		push_error("LightsOut start_lights must contain exactly nine values.")
		lights.resize(CELL_COUNT)
		lights.fill(false)


## True once every lamp is on, or has been at some point.
func is_solved() -> bool:
	return _is_solved


## How many lamps are lit right now.
func lit_count() -> int:
	var count: int = 0
	for is_lit: bool in lights:
		if is_lit:
			count += 1
	return count


## Toggles the lamp at [param index] and its orthogonal neighbours. Ignored
## once the puzzle has been solved.
func press(index: int) -> void:
	if _is_solved or index < 0 or index >= CELL_COUNT or lights.size() != CELL_COUNT:
		return
	@warning_ignore("integer_division")
	var row: int = index / GRID_SIZE
	var column: int = index % GRID_SIZE
	_toggle_cell(row, column)
	_toggle_cell(row - 1, column)
	_toggle_cell(row + 1, column)
	_toggle_cell(row, column - 1)
	_toggle_cell(row, column + 1)
	changed.emit()
	if _all_lit():
		_is_solved = true
		solved.emit(self)


func _toggle_cell(row: int, column: int) -> void:
	if row < 0 or row >= GRID_SIZE or column < 0 or column >= GRID_SIZE:
		return
	var index: int = row * GRID_SIZE + column
	lights[index] = not lights[index]


func _all_lit() -> bool:
	for is_lit: bool in lights:
		if not is_lit:
			return false
	return true
