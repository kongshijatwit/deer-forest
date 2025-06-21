extends Control

@onready var audio_name_lbl = $HBoxContainer/Audio_Name_Lbl
@onready var audio_num_lbl = $HBoxContainer/Audio_Num_Lbl
@onready var slider = $HBoxContainer/HSlider

@export_enum("Master", "Ambiance", "Sfx", "Music") var bus_name : String

var bus_index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slider.value_changed.connect(on_value_changed)
	get_bus_name_by_index()
	set_audio_name_label_text()
	set_slider_value()
	
func set_audio_name_label_text():
	audio_name_lbl.text = str(bus_name) + " Volume"
	
func set_audio_num_label_text():
	audio_num_lbl.text = str(slider.value * 100) + "%"
	
func get_bus_name_by_index():
	bus_index = AudioServer.get_bus_index(bus_name)
	
func set_slider_value():
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	set_audio_num_label_text()

func on_value_changed(value : float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	set_audio_num_label_text()
