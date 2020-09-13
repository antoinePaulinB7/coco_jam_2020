extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = $Player

signal player_died(score)
signal victory(score)

var wave_manager = {}
var player_died_sent = false
var victory_signal_sent = false
var waves = []
var directory

# Called when the node enters the scene tree for the first time.
func _ready():
	directory = Directory.new()
	wave_manager.state = "in_game"
	wave_manager.curr_wave = 0
	wave_manager.timer = Timer.new()
	wave_manager.timer.connect("timeout", self, "_on_timer_timeout")
	wave_manager.timer.set_wait_time(15)
	add_child(wave_manager.timer)
	wave_manager.timer.start()

func instantiate(thing):
	print(thing)
	thing.set_owner(self)
	add_child(thing)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if wave_manager.state == "check_victory":
		check_victory()
	
	if player.is_dead and !player_died_sent:
		emit_signal("player_died", int(player.MAX_HP))
		player_died_sent = true

func spawn(curr_wave):
	var file_name = "res://waves/Wave%d.tscn" % curr_wave
	if directory.file_exists(file_name):
		var wave = load(file_name).instance()
		while wave.get_child_count() > 0:
			var child = wave.get_child(0)
			wave.remove_child(child)
			instantiate(child)
			
		print(get_children())
	else:
		wave_manager.state = "check_victory"
		wave_manager.timer.stop()

func check_victory():
	if victory_signal_sent:
		return
	var children = get_children()
	var entities = []
	for c in children:
		if c.is_in_group("Entity"):
			if !c.is_dead:
				entities.push_back(c)
	
	if entities.size() == 1 and entities[0] == player:
		emit_signal("victory", int(player.MAX_HP))
		player_died_sent = true

func _on_timer_timeout():
	spawn(wave_manager.curr_wave)
	print("Spawning new wave")
	wave_manager.curr_wave += 1
	wave_manager.timer.start()
