class_name BattleheaderBar
extends Control

@onready var health_bar : ProgressBar = $HealthBar
@onready var health_label : Label = $HealthLabel

@onready var mana_bar : ProgressBar = $ManaBar
@onready var mana_label : Label = $ManaLabel

@onready var battler : Battler = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## Connect to signals
	battler.HealthChanged.connect(_on_health_changed)
	battler.ManaChanged.connect(_on_mana_changed)

func _on_health_changed (curr : int, max : int):
	health_label.text = "HP: %s / %s" %[curr, max]
	
	health_bar.max_value = max
	health_bar.value = curr
	
func _on_mana_changed (curr : int, max : int):
	mana_label.text = "MP: %s / %s" %[curr, max]
	
	mana_bar.max_value = max
	mana_bar.value = curr

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
