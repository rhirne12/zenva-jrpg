class_name ActionCalculator
extends Node

class ActionResult:
	var amount : int = 0
	var is_hit : bool = false
	var is_crit : bool = false
	var is_heal : bool = false
	
static func calculate (actor : Battler, target : Battler, useable : UseableData) -> ActionResult:
	var result = ActionResult.new()
	
	## if hit is evaded, just return defaults - no damage calculation needed
	if _evaded(actor, target, useable):
		print("%s evaded!!" % target.data.display_name)
		return result
	
	match useable.output_type:
		UseableData.OutputType.PHYSICAL:
			result = _calculate_physical(actor, target, useable)
		UseableData.OutputType.MAGIC:
			result = _calculate_magical(actor, target, useable)
		UseableData.OutputType.HEAL:
			result = _calculate_heal(target, useable)
	
	return result

static func _calculate_physical (actor : Battler, target : Battler, useable : UseableData) -> ActionResult:
	var result : ActionResult = ActionResult.new()
	var scaling = actor.get_stat(useable.scaling_stat)
	var defending = target.get_stat(useable.defending_stat)
	
	## get our base damage and multiple any power scalers
	var base = scaling * (useable.power / 100)
	
	## is this a critical hit, if so, add additional damage
	if randf() < useable.crit_chance:
		result.is_crit = true
		base *= 2  ## crit hit doubles damage
		
	result.is_hit = true	
	result.amount = max(base - defending, 0)
	
	return result
	
static func _calculate_magical(actor : Battler, target : Battler, useable : UseableData) -> ActionResult:
	var result : ActionResult = ActionResult.new()
	var scaling = actor.get_stat(useable.scaling_stat)
	var defending = target.get_stat(useable.defending_stat)
	
	## get our base damage and multiple any power scalers
	var base = scaling + useable.power
	
	## is this a critical hit, if so, add additional damage
	if randf() < useable.crit_chance:
		result.is_crit = true
		base *= 2  ## crit hit doubles damage
		
	result.is_hit = true	
	result.amount = max(base - defending, 0)
	
	return result

static func _calculate_heal (target : Battler, useable : UseableData) -> ActionResult:
	var result : ActionResult = ActionResult.new()
	
	result.is_heal = true
	result.amount = useable.power
	
	return result

static func _evaded (actor : Battler, target : Battler, useable :UseableData) -> bool:
	if useable.output_type == UseableData.OutputType.HEAL:
		return false
		
	if randf() > useable.accuracy:
		return true
		
	var evasion = target.get_stat(BattlerData.Stat.EVASION)
	
	return randf_range(0,100) < evasion
