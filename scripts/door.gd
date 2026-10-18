class_name Door
extends Interactable
## A sealed door. It only opens when the player types the chamber's password
## into the HUD lock panel, so riddles are the game's real key.

## Emitted once, when the correct password is entered.
signal unlocked(door: Door)

## Heading shown on the lock panel.
@export var title: String = "Sealed Door"
## Flavour text shown above the password field.
@export_multiline var hint: String = ""

## The word that opens this door. Set per chamber as riddles are written.
@export var password: String = ""

## Scene to load once this door opens. Empty until later chambers exist.
@export_file("*.tscn") var destination: String = ""

## True once the password has been accepted.
var is_open: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var blocker: StaticBody2D = $Blocker


func _ready() -> void:
	super()
	if prompt == "Interact":
		prompt = "Examine"


## Case-insensitive, whitespace-trimmed comparison against the password.
func check_password(attempt: String) -> bool:
	if password.strip_edges().is_empty():
		return false
	var cleaned: String = attempt.strip_edges().to_lower()
	return cleaned == password.strip_edges().to_lower()


## Breaks the seal: the door fades to a faint outline and stops blocking.
func unlock() -> void:
	if is_open:
		return
	is_open = true
	blocker.set_deferred("collision_layer", 0)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate", Color(0.55, 0.8, 1.0, 0.30), 0.9)
	tween.tween_property(sprite, "scale", Vector2(1.06, 0.96), 0.9)
	unlocked.emit(self)