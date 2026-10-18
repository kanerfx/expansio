class_name HUD
extends CanvasLayer
## The in-chamber interface: an interaction prompt, a sign reader panel and
## the password lock panel used to open sealed doors.

## Emitted when any panel takes over the screen.
signal panel_opened
## Emitted when the last panel closes.
signal panel_closed
## Emitted when the player submits a password for a door.
signal password_attempted(door: Door, text: String)
## Emitted when a multi-page book is closed, i.e. once it has been read.
signal book_closed

## Frames to ignore close input for, so the key that opened a panel cannot
## also close it in the same press.
const CLOSE_GUARD_MS := 160

## The "Room x" marker uses the same pixel font and colour as the name plates,
## but at its own size.
const ROOM_LABEL_COLOR := Color(0.86, 0.95, 1.0, 1.0)
const ROOM_LABEL_SCALE := 3.0

## Shared look for every text box: near-white body, bright-blue keywords and a
## soft blue glow, all baked with [PixelText].
const TEXT_COLOR := Color(0.95, 0.98, 1.0, 1.0)
const HIGHLIGHT_COLOR := Color(0.45, 0.8, 1.0, 1.0)
const DIM_COLOR := Color(0.55, 0.66, 0.82, 1.0)
const GLOW_COLOR := Color(0.42, 0.68, 1.0, 0.4)
const READER_TEXT_SCALE := 3
const READER_MAX_WIDTH := 880
const READER_LINE_SPACING := 12
const PANEL_TEXT_SCALE := 2
const PANEL_MAX_WIDTH := 660
const PANEL_LINE_SPACING := 8

@onready var prompt: TextureRect = $PromptCenter/Prompt
@onready var room_label: Sprite2D = $RoomLabel
@onready var reader_panel: PanelContainer = $PanelLayer/ReaderCenter/ReaderPanel
@onready var reader_text: TextureRect = $PanelLayer/ReaderCenter/ReaderPanel/VBox/Text
@onready var reader_page: TextureRect = $PanelLayer/ReaderCenter/ReaderPanel/VBox/PageLabel
@onready var reader_footer: TextureRect = $PanelLayer/ReaderCenter/ReaderPanel/VBox/Footer
@onready var lock_panel: PanelContainer = $PanelLayer/LockCenter/LockPanel
@onready var lock_hint: TextureRect = $PanelLayer/LockCenter/LockPanel/VBox/Hint
@onready var password_input: LineEdit = $PanelLayer/LockCenter/LockPanel/VBox/PasswordInput
@onready var lock_message: TextureRect = $PanelLayer/LockCenter/LockPanel/VBox/Message
@onready var submit_button: TextureButton = $PanelLayer/LockCenter/LockPanel/VBox/Buttons/Submit
@onready var close_button: TextureButton = $PanelLayer/LockCenter/LockPanel/VBox/Buttons/Close
@onready var puzzle_panel: PanelContainer = $PanelLayer/PuzzleCenter/PuzzlePanel
@onready var puzzle_status: TextureRect = $PanelLayer/PuzzleCenter/PuzzlePanel/VBox/Status
@onready var puzzle_hint: TextureRect = $PanelLayer/PuzzleCenter/PuzzlePanel/VBox/Hint
@onready var puzzle_close: TextureButton = $PanelLayer/PuzzleCenter/PuzzlePanel/VBox/Buttons/Close

var _active_door: Door = null
var _active_puzzle: LightsOut = null
var _puzzle_buttons: Array[Button] = []
var _open_panel: Control = null
var _close_guard_ms: int = 0
## Pages currently held by the reader panel, as {title, body} dictionaries.
var _pages: Array[Dictionary] = []
var _page_index: int = 0


func _ready() -> void:
	set_process_input(true)
	set_process_unhandled_input(true)
	reader_panel.hide()
	lock_panel.hide()
	puzzle_panel.hide()
	prompt.hide()
	submit_button.pressed.connect(_submit)
	close_button.pressed.connect(close_panel)
	password_input.text_submitted.connect(_on_text_submitted)
	puzzle_close.pressed.connect(close_panel)
	_bake_button(submit_button, "Tentar a palavra")
	_bake_button(close_button, "Afastar-se")
	_bake_button(puzzle_close, "Afastar-se")
	var grid: GridContainer = $PanelLayer/PuzzleCenter/PuzzlePanel/VBox/Grid
	for index: int in grid.get_child_count():
		var lamp: Button = grid.get_child(index) as Button
		_puzzle_buttons.append(lamp)
		lamp.pressed.connect(_on_lamp_pressed.bind(index))


## Bakes a pixel label onto a texture button, with a brighter hover/pressed look.
func _bake_button(button: TextureButton, label: String) -> void:
	button.texture_normal = PixelText.make_rich(label, TEXT_COLOR, HIGHLIGHT_COLOR, GLOW_COLOR, 0, PANEL_TEXT_SCALE, 0)
	button.texture_hover = PixelText.make_rich(label, HIGHLIGHT_COLOR, HIGHLIGHT_COLOR, GLOW_COLOR, 0, PANEL_TEXT_SCALE, 0)
	button.texture_pressed = button.texture_hover
	button.texture_focused = button.texture_normal
	button.texture_disabled = button.texture_normal


## Shows the "[E] Read" style prompt. Ignored while a panel is open.
func set_prompt(text: String) -> void:
	if _open_panel != null:
		return
	prompt.texture = PixelText.make_rich(text, TEXT_COLOR, HIGHLIGHT_COLOR, GLOW_COLOR, 0, PANEL_TEXT_SCALE, 0)
	prompt.show()


func clear_prompt() -> void:
	prompt.hide()


## Sets the "Room x" marker shown in the top-left corner, baked in the same
## pixel font and colour as the chamber's name plates.
func set_room_label(text: String) -> void:
	room_label.texture = PixelText.make_texture(text, ROOM_LABEL_COLOR)
	room_label.scale = Vector2(ROOM_LABEL_SCALE, ROOM_LABEL_SCALE)


## Opens the reader panel on a single page of text.
func show_reader(title: String, body: String) -> void:
	show_pages([{"title": title, "body": body}])


## Opens the reader panel on a book's pages, starting at the first one.
func show_book(titles: PackedStringArray, bodies: PackedStringArray) -> void:
	var pages: Array[Dictionary] = []
	var count: int = maxi(titles.size(), bodies.size())
	for index in count:
		pages.append({
			"title": titles[index] if index < titles.size() else "",
			"body": bodies[index] if index < bodies.size() else "",
		})
	show_pages(pages)


## Opens the reader panel on a list of {title, body} page dictionaries.
func show_pages(pages: Array[Dictionary]) -> void:
	if pages.is_empty():
		return
	_pages = pages
	_page_index = 0
	_refresh_page()
	_activate(reader_panel)


## Bakes the current page's body and the paging footer into pixel textures.
func _refresh_page() -> void:
	var body: String = str(_pages[_page_index].get("body", ""))
	reader_text.texture = PixelText.make_rich(body, TEXT_COLOR, HIGHLIGHT_COLOR, GLOW_COLOR, READER_MAX_WIDTH, READER_TEXT_SCALE, READER_LINE_SPACING)
	var paged: bool = _pages.size() > 1
	reader_page.visible = paged
	if paged:
		reader_page.texture = PixelText.make_rich("%d / %d" % [_page_index + 1, _pages.size()], DIM_COLOR, HIGHLIGHT_COLOR, GLOW_COLOR, 0, PANEL_TEXT_SCALE, 0)
	var footer: String = "[A] / [D]  virar página      [E]  fechar" if paged else "[E]  fechar"
	reader_footer.texture = PixelText.make_rich(footer, DIM_COLOR, HIGHLIGHT_COLOR, GLOW_COLOR, 0, PANEL_TEXT_SCALE, 0)


## Moves through the reader's pages, clamped to the ends.
func _turn_page(step: int) -> void:
	if _pages.size() <= 1:
		return
	var target: int = clampi(_page_index + step, 0, _pages.size() - 1)
	if target == _page_index:
		return
	_page_index = target
	_refresh_page()


func _previous_page() -> void:
	_turn_page(-1)


func _next_page() -> void:
	_turn_page(1)


## Opens the password lock panel for a sealed door.
func show_lock(door: Door) -> void:
	_active_door = door
	lock_hint.texture = PixelText.make_rich(door.hint, TEXT_COLOR, HIGHLIGHT_COLOR, GLOW_COLOR, PANEL_MAX_WIDTH, PANEL_TEXT_SCALE, PANEL_LINE_SPACING)
	password_input.text = ""
	lock_message.texture = null
	_activate(lock_panel)
	password_input.grab_focus()


## Sets the feedback line under the password field.
func set_lock_message(text: String, good: bool) -> void:
	var color: Color = Color(0.55, 1.0, 0.68) if good else Color(1.0, 0.5, 0.5)
	lock_message.texture = PixelText.make_rich(text, color, color, GLOW_COLOR, PANEL_MAX_WIDTH, PANEL_TEXT_SCALE, 0) if not text.is_empty() else null
	if not good and not text.is_empty():
		# Leave the failed guess selected so typing the next one replaces it.
		password_input.grab_focus()
		password_input.select_all()


## Closes whichever panel is open and hands input back to the player.
func close_panel() -> void:
	if _open_panel == null:
		return
	# A closed multi-page reader counts as the player having read the book.
	var read_a_book: bool = _open_panel == reader_panel and _pages.size() > 1
	_open_panel.hide()
	_open_panel = null
	_active_door = null
	_active_puzzle = null
	_pages.clear()
	password_input.release_focus()
	panel_closed.emit()
	if read_a_book:
		book_closed.emit()


func is_panel_open() -> bool:
	return _open_panel != null


## The body text of the page the reader is currently showing, or an empty
## string when the reader has no pages. Used by tests and callers that want to
## inspect what was revealed.
func current_page_body() -> String:
	if _pages.is_empty():
		return ""
	return str(_pages[_page_index].get("body", ""))


## Opens the Lights Out puzzle panel, driving its lamps from [param puzzle].
func show_puzzle(puzzle: LightsOut) -> void:
	_active_puzzle = puzzle
	if not puzzle.changed.is_connected(_refresh_puzzle):
		puzzle.changed.connect(_refresh_puzzle)
	if not puzzle.solved.is_connected(_on_puzzle_solved):
		puzzle.solved.connect(_on_puzzle_solved)
	puzzle_hint.texture = PixelText.make_rich(puzzle.hint, TEXT_COLOR, HIGHLIGHT_COLOR, GLOW_COLOR, PANEL_MAX_WIDTH, PANEL_TEXT_SCALE, PANEL_LINE_SPACING)
	_refresh_puzzle()
	_activate(puzzle_panel)


## Redraws every lamp from the active puzzle's state.
func _refresh_puzzle() -> void:
	if _active_puzzle == null:
		return
	for index: int in _puzzle_buttons.size():
		var lamp: Button = _puzzle_buttons[index]
		var lit: bool = _active_puzzle.lights[index]
		lamp.icon = _active_puzzle.lit_texture if lit else _active_puzzle.unlit_texture
		lamp.modulate = Color.WHITE if lit else Color(0.55, 0.62, 0.76, 1)
	_set_puzzle_status("ACESAS: %d / 9" % _active_puzzle.lit_count())


## Writes a line of pixel text under the lamp grid.
func _set_puzzle_status(text: String) -> void:
	puzzle_status.texture = PixelText.make_rich(text, TEXT_COLOR, HIGHLIGHT_COLOR, GLOW_COLOR, 0, PANEL_TEXT_SCALE, 0)


func _on_lamp_pressed(index: int) -> void:
	if _active_puzzle == null:
		return
	_active_puzzle.press(index)


func _on_puzzle_solved(_puzzle: LightsOut) -> void:
	_refresh_puzzle()
	_set_puzzle_status("TODAS AS LUZES ACESAS")


func _activate(panel: Control) -> void:
	if _open_panel != null and _open_panel != panel:
		_open_panel.hide()
	_open_panel = panel
	_close_guard_ms = Time.get_ticks_msec() + CLOSE_GUARD_MS
	prompt.hide()
	panel.show()
	panel_opened.emit()


func _submit() -> void:
	if _active_door == null:
		return
	var text: String = password_input.text.strip_edges()
	if text.is_empty():
		set_lock_message("Digite uma senha primeiro.", false)
		return
	password_attempted.emit(_active_door, text)


func _on_text_submitted(_text: String) -> void:
	_submit()


## Escape closes the panel before the focused password field can eat the key.
func _input(event: InputEvent) -> void:
	if _open_panel == null or Time.get_ticks_msec() < _close_guard_ms:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_panel()


## The interact key closes the panel when nothing else has consumed it, which
## is how the reader panel is dismissed. A focused text field keeps it.
func _unhandled_input(event: InputEvent) -> void:
	if _open_panel == null or Time.get_ticks_msec() < _close_guard_ms:
		return
	if _open_panel == reader_panel:
		# The player cannot move while reading, so the movement keys are free
		# to turn pages.
		if event.is_action_pressed("move_left") or event.is_action_pressed("ui_left"):
			get_viewport().set_input_as_handled()
			_turn_page(-1)
			return
		if event.is_action_pressed("move_right") or event.is_action_pressed("ui_right"):
			get_viewport().set_input_as_handled()
			_turn_page(1)
			return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		close_panel()
