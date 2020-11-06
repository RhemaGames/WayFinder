extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal selected(select)
signal selecting()
signal countdown(time)
signal finished(data)
var select = 1
var rotateIt = 0
var rotating = 0
var count = 10
var pressing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var _error = ""
	_error = connect("selected",get_node("../../"),"call_runner")
	_error = connect("selecting",get_node("../../"),"call_runner")
	_error = connect("countdown",get_node("../../"),"call_runner")
	
	clear_select()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if rotateIt > rotating:
		rotating += 5
		$Control.rect_rotation = rotating
		
		
	elif rotateIt < rotating:
		rotating -= 5
		$Control.rect_rotation = rotating


func clear_select():
	$Control/command/selected.hide()
	$Control/block/selected.hide()
	$Control/ranged/selected.hide()
	$Control/melee/selected.hide()

func highlight_selected():
	clear_select()
	match select:
		1:
			$Control/block/selected.show()
			$Hint.text = "Block"
		2:
			$Control/melee/selected.show()
			$Hint.text = "Melee"
		3:
			$Control/command/selected.show()
			$Hint.text = "Cmnds"
		4:
			$Control/ranged/selected.show()
			$Hint.text = "Ranged"
		
			

func _on_Back_pressed():
	$rotate.play()
	emit_signal("selecting",["selecting"])
	if select > 1:
		select -= 1
	else:
		select = 4
		
	rotateIt -= 90
	if count < 6:
		count += 4
	highlight_selected()
	

func _on_Forward_pressed():
	$rotate.play()
	emit_signal("selecting",["selecting"])
	if select < 4:
		select += 1
	else:
		select = 1
		
	rotateIt += 90
	if count < 6:
		count += 4
	highlight_selected()
	

func _input(event):
	if event is InputEventMouseButton:
		pass
	elif event.is_action_type() and event.is_pressed() and visible:
		# Down and Right
		if event.get_scancode_with_modifiers() in [16777234,16777233]:
			_on_Forward_pressed()
		# Up and Left
		if event.get_scancode_with_modifiers() in [16777232,16777231]:
			_on_Back_pressed()
		#Enter and Space
		if event.get_scancode_with_modifiers() in [16777221,32]:
			$confirm.play()
			emit_signal("selected",["selected",select])
			count = 10


func _on_melee_gui_input(event):
	
	if event.is_pressed():
		highlight_selected()
		#$Player.get_child(1).action("melee")
		#$Timer.stop()

func _on_ranged_gui_input(event):
	if event.is_pressed():
		highlight_selected()
		#$Player.get_child(1).action("range")
		#$Timer.stop()

func _on_block_gui_input(event):
	if event.is_pressed():
		highlight_selected()
		#$Player.get_child(1).action("block")
		#$Timer.stop()

func _on_command_gui_input(event):
	if event.is_pressed():
		clear_select()


func from_Above(data):
	#print(data)
	if data[0] == "player" and data[1] == "hit":
		$AnimationPlayer.play("Hit")
	if data[0] == "timer" and data[1] == "start":
		pass
		#self.count = 10
		#print("Starting Timer at: ",count)

func _on_Timer_timeout():
	#print(count)
	emit_signal("countdown",["countdown",count])
	if count == 0:
		$confirm.play()
		emit_signal("selected",["selected",select])
		#$Timer.stop()
	
	if count > 0: 
		count -= 1
	else:
		count = 10
		
	#if countdown < 8:
	#	$slow_rotate/Camera.make_current()
	
	if count < 4:
		#emit_signal("countdown",["countdown",count])
		if count % 2 == 0:
			highlight_selected()
		else:
			clear_select()


func _on_PlayerChoice_visibility_changed():
	if visible:
		count = 15
		$Timer.start()
	else:
		$Timer.stop()
		count = 15
	pass # Replace with function body.
