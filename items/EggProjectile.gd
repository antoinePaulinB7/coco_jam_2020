extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var egg_particles = $EggBreakParticles

var velocity = Vector2.RIGHT
var speed = 160
var damage = 10
var weapon_owner

func _physics_process(delta):
	position += velocity * speed * scale.x * delta

func set_scale(scl):
	scale = scl

func set_velocity(vlc):
	velocity = vlc
	if velocity.is_equal_approx(Vector2.ZERO):
		velocity = Vector2.RIGHT * weapon_owner.get_sprite().scale.x

func set_speed(spd):
	speed = spd
	
func set_damage(dmg):
	damage = dmg
	
func set_owner(ownr):
	weapon_owner = ownr

func take_damage(a, b, c):
	destroy()

func destroy():
	hide()
	egg_particles.restart()
	yield(get_tree().create_timer(1), "timeout")
	call_deferred("queue_free")
	print("this %s is destroyed" % name)

func hide():
	$"CollisionShape2D/AnimatedSprite".visible = false
	collision_layer = 0
	collision_mask = 0
	$CollisionShape2D.set_deferred("disabled", true)

func _on_FlyingEgg_body_entered(body):
	if body != weapon_owner:
		var total_damage = scale.x * damage
		body.take_damage(total_damage, get_global_position(), total_damage * 10)
		destroy()
