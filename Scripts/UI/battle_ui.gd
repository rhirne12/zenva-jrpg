class_name BattleUI
extends Panel

@export var button_containers : Dictionary[String, ButtonContainer]

var selected_action : BattleAction.Type
var selected_skill : SkillData
var possible_targets : Array[Battler]

var current_action : BattleAction

@onready var battle_manager : BattleManager = get_parent()

## reference value in another script so lines don't have to be long later on
var curr_battler : Battler:
	get: return battle_manager.current_actor


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_manager.StateChanged.connect(_on_changed_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _disable_all_containers ():
	for key in button_containers:
		button_containers[key].visible = false
		
func _display_actions ():
	var bc : ButtonContainer = button_containers["actions"]
	var data : Array[Dictionary]
	
	## Attack Button
	data.append({
		"text": "Attack",
		"info": "Cast a basic attack",
		"clicked": _on_attack_selected
	})
	
	## Defend Button
	data.append({
		"text": "Defend",
		"info": "Defend for 1 turn",
		"clicked": _on_defend_selected
	})
	
	## Skills Button
	data.append({
		"text": "Skills",
		"info": "Require MP to Use",
		"clicked": _on_skills_selected
	})
	
	## End Turn Button
	data.append({
		"text": "End Turn",
		"info": "End Turn without any action",
		"clicked": _on_end_turn_selected
	})
	
	## Flee Button
	data.append({
		"text": "Flee",
		"info": "Try to escape the fight",
		"clicked": _on_flee_selected
	})
	
	bc.initialize("Actions", data)
	
func _display_skills ():
	pass

func _display_targets ():
	pass

## Callbacks
func _on_changed_state (state : BattleManager.State):
	if state == BattleManager.State.BATTLER_INPUT and curr_battler.data.team == BattlerData.Team.PARTY:
		selected_skill = null
		possible_targets = []
		_display_actions()
	else:
		_disable_all_containers()

func _on_attack_selected ():
	print("Attack Selected!!")

func _on_defend_selected ():
	print("Defend Selected!!")

func _on_skills_selected ():
	print("Skills Selected!!")

func _on_end_turn_selected ():
	print("End Turn Selected!!")
	
func _on_flee_selected ():
	print("Flee Selected!!")	
