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
	var bc : ButtonContainer = button_containers["skills"]
	var data : Array[Dictionary]
	
	for skill in curr_battler.data.skills:
		data.append({
			"text": skill.display_name,
			"info": skill.description,
			"clicked": _on_skill_selected.bind(skill)
		})
	
	bc.initialize("Skills", data)

func _display_targets ():
	var bc : ButtonContainer = button_containers["targets"]
	var data : Array[Dictionary]
	
	for target in possible_targets:
		data.append({
			"text": target.data.display_name,
			"info": "NEED TO IMPLEMENT",
			"clicked": _on_target_selected.bind(target)
		})
		
		bc.initialize("Targets", data)

## Callbacks
func _on_changed_state (state : BattleManager.State):
	if state == BattleManager.State.BATTLER_INPUT and curr_battler.data.team == BattlerData.Team.PARTY:
		selected_skill = null
		possible_targets = []
		_display_actions()
	else:
		_disable_all_containers()

func _on_attack_selected ():
	current_action = BattleAction.new()
	current_action.actor = curr_battler
	current_action.type = BattleAction.Type.BASIC_ATTACK
	current_action.useable = curr_battler.data.basic_attack
	
	possible_targets = battle_manager.alive_enemies
	
	_display_targets()

func _on_defend_selected ():
	print("Defend Selected!!")

func _on_skills_selected ():
	_display_skills()

func _on_end_turn_selected ():
	battle_manager.submit_player_input(null)
	
func _on_flee_selected ():
	print("Flee Selected!!")	

func _on_skill_selected (skill : SkillData):
	## reset button container
	button_containers["targets"].visible = false
	
	current_action = BattleAction.new()
	current_action.actor = curr_battler
	current_action.type = BattleAction.Type.SKILL
	current_action.useable = skill
	
	var display_targets : bool = false
	
	match skill.target_type:
		UseableData.TargetType.SINGLE_ENEMY:
			display_targets = true
			possible_targets = battle_manager.alive_enemies
		UseableData.TargetType.SINGLE_ALLY:
			display_targets = true
			possible_targets = battle_manager.alive_party
		UseableData.TargetType.SELF:
			possible_targets = [curr_battler]
		UseableData.TargetType.ALL_ALLIES:
			possible_targets = battle_manager.alive_party
		UseableData.TargetType.ALL_ENEMIES:
			possible_targets = battle_manager.alive_enemies
	
	if display_targets:
		_display_targets()
	else:
		current_action.targets = possible_targets
		battle_manager.submit_player_input(current_action)
	

func _on_target_selected (target : Battler):
	current_action.targets = [target]
	battle_manager.submit_player_input(current_action)
