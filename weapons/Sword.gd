extends Area2D

export(int) var damage = 15
export(float) var knock_back_scale = 15

var belongs_to_player
var belongs_to_enemy
var weapon_owner
var already_touched = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var owner_player = find_parent("Player")
	var owner_enemy = find_parent("Enemy")
	
	belongs_to_player = true if owner_player != null else false
	belongs_to_enemy = true if owner_enemy != null else false
	
	if belongs_to_player:
		weapon_owner = owner_player
	elif belongs_to_enemy:
		weapon_owner = owner_enemy
	else:
		weapon_owner = self

func take_damage(a, b, c):
	pass

func reset_touched():
	already_touched.clear()

func _on_Weapon_body_entered(body):
#	print(body.name)
	if weapon_owner == null:
		return
	if body != weapon_owner and not already_touched.has(body):
		var total_damage = weapon_owner.get_scale().x * damage
		already_touched.push_back(body)
#		print(body.name)
		body.take_damage(total_damage, weapon_owner.get_global_position(), knock_back_scale * total_damage)
