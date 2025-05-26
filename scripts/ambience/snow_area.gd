extends Area3D

@onready var audio = $SnowAmbiance


func _ready():
	audio.play()
