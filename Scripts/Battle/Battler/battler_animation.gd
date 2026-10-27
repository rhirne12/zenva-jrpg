class_name BattlerAnimation
extends AnimatedSprite2D

const IDLE : String = "idle"
const ATTACK : String = "attack"
const EVADE : String = "evade"
const HIT : String = "hit"

func initialize(data : BattlerData):
	sprite_frames = data.battle_sprite_frames
	play(IDLE)


func _on_animation_finished() -> void:
	if animation != IDLE:
		play(IDLE)

func play_action_animation (action : BattleAction):
	if action.useable and action.useable.output_type != UseableData.OutputType.HEAL:
		play(ATTACK)


func flash_color (color : Color):
	## change our color to color sent over
	self_modulate = color
	await get_tree().create_timer(0.1).timeout
	
	## reset color back to white
	self_modulate = Color.WHITE
