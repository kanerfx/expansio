class_name Sign
extends Interactable
## A readable sign. Opening it fills the HUD reader panel with its text.

@export var title: String = "Sign"
@export_multiline var body: String = ""


func _ready() -> void:
	super()
	if prompt == "Interact":
		prompt = "Ler"


## Title and body the reader panel should display.
func read() -> Dictionary:
	return {"title": title, "body": body}
