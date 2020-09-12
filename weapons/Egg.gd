extends Node2D

export(String) var projectile_source_name = "EggProjectile"
export(int) var SPEED = 160
export(int) var DAMAGE = 10

var projectile
var weapon_owner

# Called when the node enters the scene tree for the first time.
func _ready():
	projectile = load("res://items/%s.tscn" % projectile_source_name)

func shoot():
	var new_projectile = projectile.instance()
	new_projectile.set_owner(weapon_owner)
	new_projectile.set_position(get_global_position())
	new_projectile.set_scale(weapon_owner.get_scale())
	new_projectile.set_speed(SPEED)
	new_projectile.set_damage(DAMAGE)
	new_projectile.set_velocity(weapon_owner.get_velocity().normalized())
	
	get_tree().get_root().add_child(new_projectile)
