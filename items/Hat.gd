extends Area2D

export(String) var hat_name = "hat_1"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hat
var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_wait_time(10)
	add_child(timer)
	timer.start()
	var hat_texture = load("res://assets/%s.png" % hat_name)
	hat = Sprite.new()
	hat.set_texture(hat_texture)
	add_child(hat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Hat_body_entered(body):
	if body.is_in_group("Entity"):
		remove_child(hat)
		delete_children(body.find_node("Hat place"))
		body.find_node("Hat place").add_child(hat)
		queue_free()

func _on_timer_timeout():
	queue_free()

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
