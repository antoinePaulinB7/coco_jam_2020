extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = $Player
signal player_died(score)

var player_died_sent = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if player.is_dead and !player_died_sent:
		emit_signal("player_died", int(player.MAX_HP))
		player_died_sent = true
