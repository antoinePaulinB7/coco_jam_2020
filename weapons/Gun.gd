extends Node2D

onready var gun_fire_particles = $GunFire
export(String) var projectile_source_name = "EggProjectile"
export(int) var DAMAGE = 40
export(int) var RANGE = 1024

var projectile
var weapon_owner
var raycast
var dir
var angle = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	raycast = $RayCast2D
	
	var owner_player = find_parent("Player")
	var owner_enemy = find_parent("Enemy")
	
	if owner_player:
		weapon_owner = owner_player
	elif owner_enemy:
		weapon_owner = owner_enemy
	else:
		weapon_owner = null

func _physics_process(delta):
	if weapon_owner == null:
		dir = Vector2.RIGHT
	else:
		dir = weapon_owner.input_vector * Vector2(weapon_owner.get_sprite().scale.x, 1)
		if dir.is_equal_approx(Vector2.ZERO):
			dir = Vector2.RIGHT
		dir = dir.normalized()
	rotation = dir.angle()

func shoot():
	gun_fire_particles.restart()
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target != weapon_owner:
			if target.is_in_group("Entity"):
				if target.name == "Player":
					$Hit.play()
				else:
					$Miss.play()
			var total_damage = scale.x * DAMAGE
			target.take_damage(total_damage, get_global_position(), total_damage * 10)
