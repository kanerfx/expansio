class_name Intro
extends CanvasLayer
## The opening epigraph, shown once when the game starts. The quote fades in
## over a dark backdrop while the whole game is frozen, and only the interact
## key dismisses it.

## Emitted once the epigraph has faded away and play may begin.
signal finished

## Dante's tercet, its literal Portuguese translation, and its source.
const ITALIAN := "Oh cieca cupidigia e ira folle, che sì ci sproni ne la vita corta, e ne l'etterna poi sì mal c'immolle!"
const PORTUGUESE := "Ó cega cupidez e ira louca, que tanto nos aguilhoa na vida curta, e depois, na eterna, nos imerge em tanto mal!"
const ORIGIN := "- Divina Comédia (Inferno, Canto XII, versos 49–51)"

const TEXT_COLOR := Color(0.95, 0.98, 1.0, 1.0)
const ORIGIN_COLOR := Color(0.5, 0.78, 1.0, 1.0)
const GLOW_COLOR := Color(0.42, 0.68, 1.0, 0.45)
const HINT_COLOR := Color(0.62, 0.72, 0.88, 1.0)
## Smaller than the in-game text boxes, so the epigraph reads as a prologue.
const TEXT_SCALE := 2
const HINT_SCALE := 2
const MAX_WIDTH := 1140

@onready var backdrop: ColorRect = $Backdrop
@onready var quote: TextureRect = $Center/VBox/Quote
@onready var hint: TextureRect = $Center/VBox/Hint

## True once the quote has finished fading in and may be dismissed.
var _dismissable: bool = false
var _closing: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	quote.texture = PixelText.make_rich(
		"%s\n\n%s\n\n{%s}" % [ITALIAN, PORTUGUESE, ORIGIN],
		TEXT_COLOR, ORIGIN_COLOR, GLOW_COLOR, MAX_WIDTH, TEXT_SCALE, 16)
	hint.texture = PixelText.make_rich(
		"Pressione {E} para continuar", HINT_COLOR, HINT_COLOR, GLOW_COLOR, 0, HINT_SCALE, 0)
	backdrop.color.a = 0.0
	quote.modulate.a = 0.0
	hint.modulate.a = 0.0
	# Freeze the chamber (and the player) until the epigraph is read.
	get_tree().paused = true
	var tween: Tween = create_tween()
	tween.tween_property(backdrop, "color:a", 0.95, 0.9)
	tween.tween_property(quote, "modulate:a", 1.0, 1.6)
	tween.tween_property(hint, "modulate:a", 1.0, 0.8)
	tween.finished.connect(_on_faded_in)


func _on_faded_in() -> void:
	_dismissable = true


func _unhandled_input(event: InputEvent) -> void:
	if not _dismissable or _closing:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_dismiss()


func _dismiss() -> void:
	_closing = true
	var tween: Tween = create_tween()
	tween.tween_property(backdrop, "color:a", 0.0, 0.5)
	tween.parallel().tween_property(quote, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(hint, "modulate:a", 0.0, 0.5)
	tween.finished.connect(_finish)


func _finish() -> void:
	get_tree().paused = false
	finished.emit()
	queue_free()