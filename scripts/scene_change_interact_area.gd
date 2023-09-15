extends InteractArea


@export_file("*.tscn") var scene_path
@export_file("*.wav", "*.ogg", "*.mp3") var music_path
@export var data: Array

func _on_interact():
	var new_data = data if data != [] else null
	Global.change_scene(scene_path, music_path, new_data)
