extends Spatial


func _ready():
	var _error = WayFinder.connect("step_completed",self,"on_map_update")
	for tex in WayFinder.screen_textures:
		if tex["type"] == "map":
			$Screen.get_surface_material(1).set_texture(0,tex["texture"])
			break

func on_map_update(step):
	if step == "build":
		for tex in WayFinder.screen_textures:
			if tex["type"] == "map":
				$Screen.get_surface_material(1).set_texture(0,tex["texture"])
				break
