class_name BattleManager
extends Node

enum State
{
	INTRO,
	BATTLER_INPUT,
	TURN_RESOLUTION,
	END,
	FLEE
}

#signals
signal StateChanged (state : State)
signal TurnBegan (battler : Battler)
signal TurnEnded (battler : Battler)


@export var party : Array[Battler]
@export var enemies : Array[Battler]

var alive_party : Array[Battler]:
	get: return party.filter(func(b): return b.is_alive)
var alive_enemies : Array[Battler]:
	get: return enemies.filter(func(b): return b.is_alive)

var turn_queue : Array[Battler]
var state : State
var current_actor : Battler
var current_action : BattleAction



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_change_state(State.INTRO)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _build_turn_queue ():
	var all : Array[Battler] = party + enemies
	#filter out an battler that is dead
	all = all.filter(func(b): return b.is_alive)
	turn_queue = all

func _next_battler_turn ():
	## if we currently ave an actor, we first need to end their turn
	if current_actor != null:
		TurnEnded.emit(current_actor)
	
	## if the turn queue is empty, we need to rebuild the queue
	if turn_queue.is_empty():
		_build_turn_queue()
	
	## get the next person in queue to battle
	current_actor = turn_queue.pop_front()
	
	## make sure actor is still alive, if not, get the next actor
	if not current_actor.is_alive:
		_next_battler_turn()
		return
	
	print("Current Turn: %s" % current_actor.name)
	
	TurnBegan.emit(current_actor)
	_change_state(State.BATTLER_INPUT)

func _change_state(new_state : State):
	state = new_state
	
	match state:
		State.INTRO : _enter_intro()
		State.BATTLER_INPUT : _enter_battler_input()
		State.TURN_RESOLUTION : _enter_turn_resolutions()
		State.END : _enter_end()
		State.FLEE : _enter_flee()
	
	print("New State: %s" % state)
	StateChanged.emit(state)

func _enter_intro ():
	await get_tree().create_timer(1.0).timeout
	_build_turn_queue()
	_next_battler_turn()

func _enter_battler_input ():
	if current_actor.data.team == BattlerData.Team.PARTY:
		pass # Do nothing as this is managed by the BattleUI script
	else:
		## create a basic enemy AI to simply attack a random player
		current_action = BattleAction.new()
		current_action.actor = current_actor
		current_action.targets = [alive_party.pick_random()]
		current_action.type = BattleAction.Type.BASIC_ATTACK
		current_action.useable = current_actor.data.basic_attack
		_change_state(State.TURN_RESOLUTION)
		
func _enter_turn_resolutions ():
	## if we send over a null action, simply move on to next person turn - should not happen
	if not current_action:
		_next_battler_turn()
		return
	
	current_actor.anim.play_action_animation(current_action)
	
	match current_action.type:
		BattleAction.Type.BASIC_ATTACK : _execute_useable()
		BattleAction.Type.SKILL : _execute_skill()
		BattleAction.Type.DEFEND : _execute_defend()
		BattleAction.Type.FLEE : _execute_flee()
	
	## wait 1 second before moving to next battler turn
	await get_tree().create_timer(1.0).timeout
	
	## if our state has changed while we are waiting, just return don't go to next battler
	if state != State.TURN_RESOLUTION:
		return
	
	_next_battler_turn()

func _enter_end ():
	if alive_enemies.is_empty():
		print("Party wins!")
	else:
		print("Enemies wins!")

func _enter_flee ():
	pass

func submit_player_input (action : BattleAction):
	current_action = action
	_change_state(State.TURN_RESOLUTION)
	
func _execute_useable ():
	for target in current_action.targets:
		var result = ActionCalculator.calculate(current_actor, target, current_action.useable)
		
		if result.is_heal:
			target.heal(result.amount)
		elif not result.is_hit:
			target.evade()
		else:
			if result.is_crit:
				## Play unique sound / effect
				pass			
			target.take_damage(result.amount)
	
func _execute_skill ():
	var skill : SkillData = current_action.useable
	
	## if we can't afford this skill, skil over it
	if not skill.can_afford(current_actor):
		return
		
	current_actor.spend_mana(skill.mana_cost)
	_execute_useable()
	
func _execute_defend ():
	pass
	
func _execute_flee ():
	pass
	
func battler_died (battler : Battler):
	print("%s has been defeated!" % battler.data.display_name)
	
	if alive_enemies.is_empty() or alive_party.is_empty():
		_change_state(State.END)
	
