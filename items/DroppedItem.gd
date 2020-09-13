extends RigidBody2D

export(int) var hp = 100

var collision_shape

var timer
var item

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_shape = $CollisionShape2D
	item = collision_shape.find_node("ItemPlace").get_child(0)
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
	
	if hp <= 0:
		destroy()

func use(target):
	if item != null and item.is_in_group("Weapon"):
		$CollisionShape2D/ItemPlace.remove_child(item)
		target.equip_weapon(item)
	destroy()

func destroy():
	call_deferred("queue_free")

func _on_timer_timeout():
	collision_shape.set_deferred("disabled", false)

func _on_DroppedItem_body_entered(body):
	if body.is_in_group("Entity"):
		if !body.is_dead:
			use(body)
