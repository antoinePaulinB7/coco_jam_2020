extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var size = 1
var small = []
var normal = []
var big = []

# Called when the node enters the scene tree for the first time.
func _ready():
	small = [$small1, $small2, $small3, $small4, $small5, $small6]
	normal = [$normal1, $normal2, $normal3, $normal4, $normal5]
	big = [$big1, $big2, $big3, $big4]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
