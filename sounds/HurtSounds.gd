extends Node2D

var size = 1
var hurt = []

# Called when the node enters the scene tree for the first time.
func _ready():
	hurt = [$hurt1, $hurt2, $hurt3]

func _process(delta):
	size = get_parent().scale.x

func play_sound():
	var sound = hurt[randi() % hurt.size()]
	sound.pitch_scale = 1 / size
	sound.play()
