class_name NamePlate
extends Node2D
## A floating, glowing credit line, drawn with [PixelText] so it keeps the
## game's chunky pixel look and drifts like the player does.

## Group the chamber uses to find every plate when it is time to fade them out.
const GROUP_NAME := "name_plate"

@export var text: String = "NAME"
@export var color: Color = Color(0.86, 0.95, 1.0, 1.0)
## World size of one font pixel; 2.0 makes text twice the room's pixel density.
@export var pixel_scale: float = 2.0
@export var bob_height: float = 2.5
@export var bob_speed: float = 1.5

var _time: float = 0.0
var _home: Vector2 = Vector2.ZERO
var _fading: bool = false

@onready var text_sprite: Sprite2D = $Text
@onready var halo: Sprite2D = $Halo
@onready var lamp: PointLight2D = $Lamp


func _ready() -> void:
	add_to_group(GROUP_NAME)
	_home = position
	# Offset each plate's bob so side-by-side names do not move in lockstep.
	_time = fmod(absf(_home.x) + absf(_home.y), 6.2831853)
	var texture: ImageTexture = PixelText.make_texture(text, color)
	var span: float = 60.0
	if texture != null:
		text_sprite.texture = texture
		span = maxf(texture.get_width() * pixel_scale, 60.0)
	text_sprite.scale = Vector2(pixel_scale, pixel_scale)
	# Stretch the round halo into a soft band behind the line of text.
	halo.scale = Vector2(span * 1.5 / 256.0, 54.0 / 256.0)
	lamp.texture_scale = clampf(span / 256.0 * 1.8, 0.22, 1.0)


func _process(delta: float) -> void:
	_time += delta
	position.y = _home.y + sin(_time * bob_speed) * bob_height
	lamp.energy = 0.8 + sin(_time * 1.1) * 0.12


## Fades the plate and its light away, then switches it off for good.
## Staggering [param delay] across several plates reads better than all at once.
func fade_out(duration: float = 1.8, delay: float = 0.0) -> void:
	if _fading:
		return
	_fading = true
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_property(lamp, "energy", 0.0, duration)
	await tween.finished
	lamp.enabled = false
	visible = false
	set_process(false)