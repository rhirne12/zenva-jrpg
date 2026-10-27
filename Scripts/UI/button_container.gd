class_name ButtonContainer
extends Control

@onready var header_label : Label = $Header
@onready var container : VBoxContainer = $ScrollContainer/VBoxContainer

var buttons: Array[Button]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in container.get_children():
		if child is Button:
			buttons.append(child)
			
func initialize (header : String, data : Array[Dictionary]):
	visible = true
	header_label.text = header
	for i in len(buttons):
		if i >= len(data):
			buttons[i].visible = false
			continue
		
		var b = buttons[i]
		b.visible = true
		b.text = data[i]["text"]
		
		_clear_signal(b.pressed)
		
		b.pressed.connect(_on_pressed.bind(data[i]["clicked"]))

func _on_pressed (callable : Callable):
	callable.call()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _clear_signal (sig : Signal):
	for conn in sig.get_connections():
		sig.disconnect(conn["callable"])
