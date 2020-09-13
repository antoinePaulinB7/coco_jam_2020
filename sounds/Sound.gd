extends Node2D

onready var sound = $AudioStreamPlayer2D

func play_sound():
	sound.play()
