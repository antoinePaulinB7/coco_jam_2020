extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var time_begin
var time_delay

var size = 1
var small = []
var normal = []
var big = []
var sound

# Called when the node enters the scene tree for the first time.
func _ready():
	small = [$small1, $small2, $small3, $small4, $small5, $small6]
	normal = [$normal1, $normal2, $normal3, $normal4, $normal5]
	big = [$big1, $big2, $big3, $big4]
	sound = small[0]

func _process(delta):
	size = get_parent().scale.x

func play_sound():
	var time = AudioServer.get_time_since_last_mix()
	# Compensate for output latency.
	time -= AudioServer.get_output_latency()
	
	time = min(time, 0)
	
	if size < 1:
		small[randi() % small.size()].play()
	if size >= 0.75 and size < 4:
		normal[randi() % normal.size()].play()
	if size >= 2:
		big[randi() % big.size()].play()
