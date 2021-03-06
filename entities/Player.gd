# PLAYER SCRIPT

extends KinematicBody2D

export(int) var MAX_SPEED = 128
export(int) var ACCELERATION = 640
export(int) var FRICTION = 960
export(int) var MAX_HP = 100
export(String) var blob_source_name = "Blob"
export(String) var weapon_source_name = ""
export(String) var ai_type = "basic"

onready var sprite = $AnimatedSprite
onready var state_machine = $AnimationTree["parameters/playback"]
onready var heal_particles = $HealParticles
onready var dmg_particles = $DamageParticles

const PLAYER_MAX_SCALE = 6
const AI_MAX_SCALE = 8

var blob_scene
var blobs_to_spawn = []
var random_machine
var input_vector = Vector2.ZERO
var velocity = Vector2.ZERO
var weapon
var weapon_state_machine
var hp
var is_player
var is_dead
var dropped_sword_scene
var dropped_egg_scene
var dropped_gun_scene
var ai_data = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	equip_weapon(weapon_source_name)
	state_machine.start("idle")
	is_player = true if name == "Player" else false
	is_dead = false
	random_machine = RandomNumberGenerator.new()
	random_machine.randomize()
	blob_scene = load("res://items/%s.tscn" % blob_source_name)
	dropped_sword_scene = load("res://items/DroppedSword.tscn")
	dropped_egg_scene = load("res://items/DroppedEgg.tscn")
	dropped_gun_scene = load("res://items/DroppedGun.tscn")
	
	if not is_player:
		ai_data.player_target = get_node("/root/World/Player")
		ai_data.ai_type = ai_type
		ai_data.ai_state = "idle"
	
	hp = MAX_HP
	update_scale()

func _physics_process(delta):
	if is_dead:
		return
	
	update_scale()
	
	# Move
	input_vector = Vector2.ZERO
	
	if is_player:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
		var attack = Input.is_action_just_pressed("ui_accept")
		if attack:
			attack()
	else:
		# ai stuff
		match ai_data.ai_type:
			"basic":
				ai_basic()
			"ranged_egg":
				ai_ranged_egg()
			"ranged_gun":
				ai_ranged_gun()
	
	input_vector = input_vector.normalized()
	
	# if weapon_state_machine.get_current_node() == "attack":
	# 	input_vector = Vector2.ZERO
	
	if input_vector.x > 0.1:
		sprite.scale.x = 1
	elif input_vector.x < -0.1:
		sprite.scale.x = -1
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)
	
	if velocity.length() > 0.1:
		state_machine.travel("walk")
	else:
		state_machine.travel("idle")
	

func update_scale():
	var hp_scale = 0.5 + lerp(0, 0.5, hp / 100.0)
	hp_scale = min(hp_scale, PLAYER_MAX_SCALE if is_player else AI_MAX_SCALE)
	scale = Vector2(hp_scale, hp_scale)

func attack():
	if weapon:
		weapon_state_machine.start("attack")
	
func take_damage(amount, attack_origin, knock_back):
	state_machine.start("take_damage")
	if !is_player:
		ai_data.ai_state = "idle"
		
	velocity += (get_global_position() - attack_origin).normalized() * knock_back
	
	hp -= amount
	
	if hp <= 0:
		die()
		
	dmg_particles.restart()
	drop_blob(amount)

func heal(amount):
	hp += amount
	
	if hp >= MAX_HP:
		MAX_HP = hp
	
	heal_particles.restart()
	$Heal.pitch_scale = 1 / scale.x
	$Heal.play()

func equip_weapon(weapon_name):
	drop_item()
	
	if weapon_name is String:
		if weapon_name == "":
			return
		weapon = load("res://weapons/%s.tscn" % weapon_name).instance()
	elif weapon_name.is_in_group("Weapon"):
		weapon = weapon_name
	else:
		return
		
	weapon.weapon_owner = self
	
	$"AnimatedSprite/Weapon place".call_deferred("add_child", weapon)
	weapon_state_machine = weapon.get_node("AnimationTree")["parameters/playback"]
	weapon_state_machine.start("inactive")

func drop_item():
	var child_count = $"AnimatedSprite/Weapon place".get_child_count()
	for i in range(0, child_count):
		var curr_weapon = $"AnimatedSprite/Weapon place".get_child(i)
		weapon = null
		weapon_state_machine = null
		curr_weapon.weapon_owner = null
		
		$"AnimatedSprite/Weapon place".call_deferred("remove_child", curr_weapon)
		
		var random_angle = random_machine.randf_range(0, 2*PI)
		
		var angle_vector = Vector2.RIGHT.rotated(random_angle)
		
		var dropped_item
		if curr_weapon.name.to_lower().match("egg"):
			dropped_item = dropped_egg_scene.instance()
		elif curr_weapon.name.to_lower().match("gun"):
			dropped_item = dropped_gun_scene.instance()
		else:
			dropped_item = dropped_sword_scene.instance()
		
		dropped_item.set_position(get_global_position() + angle_vector * 10 * get_scale().x)
		dropped_item.set_scale(scale)
		get_tree().get_root().call_deferred("add_child", dropped_item)
		
		dropped_item.get_node("CollisionShape2D/ItemPlace").call_deferred("add_child", curr_weapon)
	

func drop_blob(amount):
	blobs_to_spawn.clear()
	for a in range(0,3):
		var blob_instance = blob_scene.instance()
		blob_instance.set_name("%s blob" % name)
		
		var random_angle = random_machine.randf_range(0, 2*PI)
		
		var angle_vector = Vector2.RIGHT.rotated(random_angle)
		
		blob_instance.set_position(get_global_position() + angle_vector * 5 * get_scale().x)
		
		blob_instance.set_hp((amount / 3.0) + 5.0)
		
		blobs_to_spawn.push_back(blob_instance)
	
	for b in blobs_to_spawn:
		get_tree().get_root().call_deferred("add_child", b)

func get_sprite():
	return sprite
	
func get_velocity():
	return velocity

func die():
	state_machine.start("die")
	$CollisionShape2D.set_deferred("disabled", true)
	is_dead = true
	
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	
	drop_item()


func ai_basic():
	match ai_data.ai_state:
		"idle":
			move_toward_player()
			ai_data.ai_state = "move_toward_player"
		"move_toward_player":
			if get_global_position().distance_to(ai_data.player_target.get_global_position()) <= 12 * (max(scale.x, ai_data.player_target.get_scale().x)):
				ai_data.ai_state = "wait"
				ai_data.wait = 30
			else:
				move_toward_player()
		"wait":
			if ai_data.wait <= 0:
				ai_data.ai_state = "attack"
			ai_data.wait -= 1
		"attack":
			attack()
			ai_data.ai_state = "wait_after_attack"
			ai_data.wait = 5
		"wait_after_attack":
			if ai_data.wait <= 0:
				ai_data.ai_state = "idle"
			ai_data.wait -= 1
	
func ai_ranged_egg():
	match ai_data.ai_state:
		"idle":
			move_toward_player()
			ai_data.ai_state = "move_toward_player"
		"move_toward_player":
			if get_global_position().distance_to(ai_data.player_target.get_global_position()) <= 32 * (ai_data.player_target.get_scale().x + scale.x):
				ai_data.ai_state = "wait"
				ai_data.wait = 30
				ai_data.target = ai_data.player_target.get_global_position()
			else:
				move_toward_player()
		"wait":
			if ai_data.wait <= 0:
				ai_data.ai_state = "attack"
			ai_data.wait -= 1
		"attack":
			move_toward_target(ai_data.target)
			attack()
			ai_data.ai_state = "wait_after_attack"
			ai_data.wait = 5
		"wait_after_attack":
			if ai_data.wait <= 0:
				ai_data.ai_state = "idle"
			ai_data.wait -= 1
	
func ai_ranged_gun():
	match ai_data.ai_state:
		"idle":
			move_toward_player()
			ai_data.ai_state = "move_toward_player"
		"move_toward_player":
			if get_global_position().distance_to(ai_data.player_target.get_global_position()) <= 64 * (ai_data.player_target.get_scale().x + scale.x):
				ai_data.ai_state = "wait"
				ai_data.wait = 30
				ai_data.target = ai_data.player_target.get_global_position()
			else:
				move_toward_player()
		"wait":
			if ai_data.wait <= 0:
				ai_data.ai_state = "attack_1"
			ai_data.wait -= 1
		"attack_1":
			move_toward_target(ai_data.target)
			attack()
			ai_data.ai_state = "wait_2"
			ai_data.wait = 15
		"wait_2":
			if ai_data.wait <= 0:
				ai_data.ai_state = "attack_2"
			ai_data.wait -= 1
		"attack_2":
			move_toward_target(ai_data.target)
			attack()
			ai_data.ai_state = "wait_3"
			ai_data.wait = 15
		"wait_3":
			if ai_data.wait <= 0:
				ai_data.ai_state = "attack_3"
			ai_data.wait -= 1
		"attack_3":
			move_toward_target(ai_data.target)
			attack()
			ai_data.ai_state = "wait_after_attack"
			ai_data.wait = 60
		"wait_after_attack":
			if ai_data.wait <= 0:
				ai_data.ai_state = "idle"
			ai_data.wait -= 1

func move_toward_target(target):
	var dir = target - position
	input_vector = dir.normalized()

func move_toward_player():
	if ai_data.player_target:
		move_toward_target(ai_data.player_target.get_global_position())
