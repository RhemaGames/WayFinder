extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal active(name)

var on = preload("res://packs/waypoints/trappist-1/graphics/pipeglow.material")
var off = preload("res://packs/waypoints/trappist-1/graphics/ContainerGlass.material")

var is_on = false

func _ready():
	if !is_on:
		$Toggle.set_surface_material(0,off)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonArea_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event.is_pressed():
		toggle()

func toggle():
	if !is_on:
		is_on = true
		$Toggle.set_surface_material(0,on)
		emit_signal("active",get_parent().name)
	else:
		is_on = false
		$Toggle.set_surface_material(0,off)

func on_reset():
	$Toggle.set_surface_material(0,off)
	is_on = false

func on_selected(button):
	if get_parent().name != button:
		$Toggle.set_surface_material(0,off)
		is_on = false
