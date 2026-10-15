class_name SkillData
extends UseableData


@export_category("Cost")
@export var mana_cost : int

func can_afford (battler : Battler) -> bool:
	return battler.current_mana >= mana_cost
