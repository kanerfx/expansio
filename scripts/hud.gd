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

@onready var prompt_label: Label = $PromptLabel
@onready var reader_panel: PanelContainer = $PanelLayer/ReaderCenter/ReaderPanel
@onready var reader_title: Label = $PanelLayer/ReaderCenter/ReaderPanel/VBox/Title
@onready var reader_body: Label = $PanelLayer/ReaderCenter/ReaderPanel/VBox/Body
@onready var reader_page: Label = $PanelLayer/ReaderCenter/ReaderPanel/VBox/Nav/PageLabel
@onready var reader_prev: Button = $PanelLayer/ReaderCenter/ReaderPanel/VBox/Nav/Prev
@onready var reader_next: Button = $PanelLayer/ReaderCenter/ReaderPanel/VBox/Nav/Next
@onready var lock_panel: PanelContainer = $PanelLayer/LockCenter/LockPanel
@onready var lock_title: Label = $PanelLayer/LockCenter/LockPanel/VBox/Title
@onready var lock_hint: Label = $PanelLayer/LockCenter/LockPanel/VBox/Hint
@onready var password_input: LineEdit = $PanelLayer/LockCenter/LockPanel/VBox/PasswordInput
@onready var lock_message: Label = $PanelLayer/LockCenter/LockPanel/VBox/Message
@onready var submit_button: Button = $PanelLayer/LockCenter/LockPanel/VBox/Buttons/Submit
@onready var close_button: Button = $PanelLayer/LockCenter/LockPanel/VBox/Buttons/Close

var _active_door: Door = null
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
	prompt_label.hide()
	submit_button.pressed.connect(_submit)
	close_button.pressed.connect(close_panel)
	password_input.text_submitted.connect(_on_text_submitted)
	reader_prev.pressed.connect(_previous_page)
	reader_next.pressed.connect(_next_page)


## Shows the "[E] Read" style prompt. Ignored while a panel is open.
func set_prompt(text: String) -> void:
	if _open_panel != null:
		return
	prompt_label.text = text
	prompt_label.show()


func clear_prompt() -> void:
	prompt_label.hide()


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


## Shows the currently selected page and updates the page navigation row.
func _refresh_page() -> void:
	var page: Dictionary = _pages[_page_index]
	reader_title.text = str(page.get("title", ""))
	reader_body.text = str(page.get("body", ""))
	var paged: bool = _pages.size() > 1
	reader_page.visible = paged
	reader_prev.visible = paged
	reader_next.visible = paged
	reader_page.text = "%d / %d" % [_page_index + 1, _pages.size()]
	reader_prev.disabled = _page_index <= 0
	reader_next.disabled = _page_index >= _pages.size() - 1


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
	lock_title.text = door.title
	lock_hint.text = door.hint
	password_input.text = ""
	set_lock_message("", true)
	lock_message.text = ""
	_activate(lock_panel)
	password_input.grab_focus()


## Sets the feedback line under the password field.
func set_lock_message(text: String, good: bool) -> void:
	lock_message.text = text
	lock_message.modulate = Color(0.55, 1.0, 0.68) if good else Color(1.0, 0.5, 0.5)
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
	_pages.clear()
	password_input.release_focus()
	panel_closed.emit()
	if read_a_book:
		book_closed.emit()


func is_panel_open() -> bool:
	return _open_panel != null


func _activate(panel: Control) -> void:
	if _open_panel != null and _open_panel != panel:
		_open_panel.hide()
	_open_panel = panel
	_close_guard_ms = Time.get_ticks_msec() + CLOSE_GUARD_MS
	prompt_label.hide()
	panel.show()
	panel_opened.emit()


func _submit() -> void:
	if _active_door == null:
		return
	var text: String = password_input.text.strip_edges()
	if text.is_empty():
		set_lock_message("Type a password first.", false)
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
