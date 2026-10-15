class_name BattleAction
extends RefCounted

enum Type
{
	BASIC_ATTACK,
	SKILL,
	DEFEND,
	FLEE
}

var actor: Battler
var targets : Array[Battler]
var type : Type
var useable : UseableData
