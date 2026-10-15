class_name BattlerData
extends Resource

enum Team
{
	PARTY,
	ENEMY
}

## using ENUM for our battler stats
enum Stat
{
	MAX_HEALTH,
	MAX_MANA,
	MANA_REGEN,
	ATTACK,
	DEFENCE,
	MAGIC_ATTACK,
	MAGIC_DEFENCE,
	ACCURACY,
	EVASION
}

@export var display_name : String
@export var team : Team

### stats for our battler
@export var base_stats : Dictionary[Stat, Variant] = {
	Stat.MAX_HEALTH: 100,
	Stat.MAX_MANA: 100,
	Stat.MANA_REGEN: 5,
	Stat.ATTACK: 10,
	Stat.DEFENCE: 4,
	Stat.MAGIC_ATTACK: 6,
	Stat.MAGIC_DEFENCE: 3,
	Stat.ACCURACY: 90,
	Stat.EVASION: 10
}

@export var skill : Array[SkillData]
@export var basic_attack : UseableData

## Skills
## Basic attack
## Status immunities
## Defending Status
