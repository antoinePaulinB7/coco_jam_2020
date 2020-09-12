extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var zoom_speed = 0.015
export(Vector2) var MAX_ZOOM = Vector2(6, 4)

onready var death_message_box = $"CenterContainer/RichTextLabel"

var camera_owner
var target_zoom

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_owner = find_parent("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	target_zoom = camera_owner.scale
	target_zoom.x = min(target_zoom.x, MAX_ZOOM.x)
	target_zoom.y = min(target_zoom.y, MAX_ZOOM.y)
	
	zoom = lerp(zoom, target_zoom, zoom_speed)

func death_ui(final_score):
	print("camera player death animation")
	
	drag_margin_top = 0
	drag_margin_bottom = 0
	drag_margin_left = 0
	drag_margin_right = 0
	
	death_message_box.score = final_score
	death_message_box.visible = true
	

func _on_World_player_died(score):
	death_ui(score)
