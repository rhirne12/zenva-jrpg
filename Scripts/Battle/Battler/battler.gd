class_name Battler
extends Area2D

## signals to other scripts
signal HealthChanged (cur : int, max : int)
signal ManaChanged (cur : int, max : int)
signal Died

#reference to this instance data
@export var data : BattlerData

# instance data
var current_health : int
var current_mana : int
var is_alive : bool = true

@onready var anim : BattlerAnimation = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## set current HP / MP
	current_health = get_stat(BattlerData.Stat.MAX_HEALTH)
	current_mana = get_stat(BattlerData.Stat.MAX_MANA)
	
	HealthChanged.emit(current_health, current_health)
	ManaChanged.emit(current_mana, current_mana)
	
	anim.initialize(data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_stat(stat : BattlerData.Stat) -> float:
	var value : float = data.base_stats.get(stat, 0)
	
	# TODO:  Apply status effects
	
	return value

func take_damage(amount : int):
	var max_health : int = get_stat(BattlerData.Stat.MAX_HEALTH)
	current_health -= amount
	HealthChanged.emit(current_health, max_health)
	
	anim.play(BattlerAnimation.HIT)
	anim.flash_color(Color.RED)
	
	if current_health <= 0:
		die()

func heal (amount : int):
	var max_health : int = get_stat(BattlerData.Stat.MAX_HEALTH)
	current_health += amount
	
	if current_health > max_health:
		current_health = max_health
	
	HealthChanged.emit(current_health, max_health)

func spend_mana (amount : int) -> bool:
	## make sure we have enough mana to use
	if (current_mana < amount):
		return false

	var max_mana : int = get_stat(BattlerData.Stat.MAX_MANA)
	current_mana -= amount		
	ManaChanged.emit(current_mana, max_mana)
	return true
	
func restore_mana(amount : int):
	var max_mana : int = get_stat(BattlerData.Stat.MAX_MANA)
	current_mana -= amount
	
	if current_mana > max_mana:
		current_mana = max_mana
		
	ManaChanged.emit(current_mana, max_mana)

func evade ():
	pass

func die ():
	pass
