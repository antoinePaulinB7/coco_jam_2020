extends RigidBody2D

export(int) var hp = 10

onready var collision_shape = $CollisionShape2D

var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	update_size()
	timer = Timer.new()
	timer.set_wait_time(1)
	timer.connect("timeout",self,"_on_timer_timeout") 
	add_child(timer)
	timer.start()
	
func _physics_process(delta):
	update_size()
	
func set_hp(amount):
	hp = amount
	
func update_size():
	var hp_scale = lerp(0.25, 1.0, hp / 100.0)
	collision_shape.set_scale(Vector2(hp_scale, hp_scale))

	set_weight(max(hp, 10))


func take_damage(amount, attack_origin, knock_back):
	apply_central_impulse((get_global_position() - attack_origin).normalized() * knock_back)
	
	hp -= amount
	
#	print("{name} takes {dmg} damage, hp: {hp}".format({"name":name, "dmg":amount, "hp":hp}))
	
	if hp <= 0:
		destroy()

func use(target):
#	print("%s uses this %s" % [target.name, name])
	target.heal(hp)
	destroy()

func destroy():
	call_deferred("queue_free")
#	print("this %s is destroyed" % name)

func _on_timer_timeout():
	collision_shape.set_deferred("disabled", false)

func _on_Blob_body_entered(body):
#	print("touching %s" % body.name)
	if body.is_in_group("Entity") and body.get_scale().x >= 1.5 * collision_shape.get_scale().x:
		if !body.is_dead:
			use(body)
