class_name Bookstand
extends Interactable
## A lectern with a book floating above it. Reading it opens the HUD's paged
## reader, so a chamber keeps all of its instructions in one place.

## Page headings, one per page.
@export var titles: PackedStringArray = PackedStringArray()
## Page bodies, matched to [member titles] by index.
@export var bodies: PackedStringArray = PackedStringArray()

@export var bob_height: float = 2.0
@export var bob_speed: float = 1.8

var _time: float = 0.0
var _book_home: Vector2 = Vector2.ZERO

@onready var book: Sprite2D = $Book
@onready var book_glow: Sprite2D = $BookGlow
@onready var lamp: PointLight2D = $Lamp


func _ready() -> void:
	super()
	if prompt == "Interact":
		prompt = "Read"
	_book_home = book.position


func _process(delta: float) -> void:
	_time += delta
	# The book hovers above the stand, so the stand stays put and only the
	# book, its halo and its light drift together.
	var hover: Vector2 = _book_home + Vector2(0.0, sin(_time * bob_speed) * bob_height)
	book.position = hover
	book_glow.position = hover
	lamp.position = hover
	book_glow.modulate.a = 0.8 + sin(_time * 1.3) * 0.2


## Number of pages the book holds.
func page_count() -> int:
	return maxi(titles.size(), bodies.size())


## Heading for a page, or an empty string when that page has none.
func page_title(index: int) -> String:
	if index >= 0 and index < titles.size():
		return titles[index]
	return ""


## Body text for a page, or an empty string when that page has none.
func page_body(index: int) -> String:
	if index >= 0 and index < bodies.size():
		return bodies[index]
	return ""