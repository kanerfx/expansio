class_name Interactable
extends Area2D
## Base class for anything the player can walk up to and trigger with the
## interact action (signs, sealed doors, levers, whatever a chamber needs).
##
## Every interactable sits on collision layer 3 (bit value 4) so the player's
## reach area can find it, and carries no mask of its own.

## Short verb shown in the HUD prompt, e.g. "Read" or "Examine".
@export var prompt: String = "Interact"

## Emitted when the player triggers this interactable.
signal triggered(interactable: Interactable)


func _ready() -> void:
	add_to_group("interactable")
	collision_layer = 4
	collision_mask = 0


## Called by the player when the interact action is pressed within reach.
func interact() -> void:
	triggered.emit(self)