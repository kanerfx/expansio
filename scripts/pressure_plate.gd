class_name PressurePlate
extends Area2D
## A floor plate that reacts when the player steps onto it, used to reveal a
## hint in the HUD.

## Emitted once each time the player steps onto the plate.
signal pressed(plate: PressurePlate)

## Heading shown in the hint panel.
@export var hint_title: String = "Dica"
## Body shown in the hint panel.
@export_multiline var hint_body: String = ""

@onready var sprite: Sprite2D = $Sprite2D

## True while the player is standing on the plate.
var _occupied: bool = false


func _ready() -> void:
	add_to_group("pressure_plate")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if _occupied or not body is Player:
		return
	_occupied = true
	_sink(true)
	pressed.emit(self)


func _on_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	_occupied = false
	_sink(false)


## Sinks the plate and brightens it while it is held down.
func _sink(down: bool) -> void:
	sprite.modulate = Color(1.7, 1.7, 1.7) if down else Color(1.0, 1.0, 1.0)
	var tween: Tween = create_tween()
	var target: Vector2 = Vector2(0.0, 1.0) if down else Vector2.ZERO
	tween.tween_property(sprite, "position", target, 0.12)