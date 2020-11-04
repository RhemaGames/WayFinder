extends Spatial

signal reset()
signal success()
signal selected(button)

var buttons = []
var buttonInterface = preload("res://packs/waypoints/trappist-1/scenes/Activities/repairPuzzleButton.tscn")
var locks = [preload("res://packs/waypoints/trappist-1/graphics/Circles_button.svg"),
			 preload("res://packs/waypoints/trappist-1/graphics/Hex_button.svg"),
			 preload("res://packs/waypoints/trappist-1/graphics/Triangle_button.svg")]

var on = preload("res://packs/waypoints/trappist-1/graphics/pipeglow.material")
var off = preload("res://packs/waypoints/trappist-1/graphics/flatblack.material")

var buttonset = ""
var handleEngaged = false
var buttonEngaged = "none"
var handlePos = 1
var buttonPos = 1

var rotateIt = 0
var rotating = 0

var raise = 0
var raised = 0
var level = 1

var lock = [{"button":"Button1","position":3},{"button":"Button2","position":2},{"button":"Button3","position":1}]
var combo = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$repairPuzzle/Handle.set_surface_material(2,off)
	$repairPuzzle/Handle.set_surface_material(3,off)
	reset()
	add_buttons(3)
	create_lock(3)
	pass # Replace with function body.
	
func new_puzzle():
	$repairPuzzle/Handle.set_surface_material(2,off)
	$repairPuzzle/Handle.set_surface_material(3,off)
	reset()
	$OmniLight.hide()
	#add_buttons(3)
	create_lock(3)

# warning-ignore:shadowed_variable
func create_lock(level):
	randomize()
	lock = []
	var usedButton = []
	var usedPosition = []
	for i in level:
		var buttonNum = int(rand_range(1,level+1))
		if len(usedButton) > 0:
			while true:
				if !buttonNum in usedButton:
					break
				else:
					buttonNum = int(rand_range(1,level+1))
					
		var positionNum = int(rand_range(1,level+1))
		if len(usedPosition) > 0:
			while true:
				if !positionNum in usedPosition:
					break
				else:
					positionNum = int(rand_range(1,level+1))
				
		var newButton = "none"
		#var newPosition = 0
		match buttonNum:
			1:
				newButton = "Button1"
			2:
				newButton = "Button2"
			3:
				newButton = "Button3"
			4:
				newButton = "Button4"
			5:
				newButton = "Button5"
			6:
				newButton = "Button6"
				
		lock.append({"button":newButton,"position":positionNum})
		usedButton.append(buttonNum)
		usedPosition.append(positionNum)
		
	print(lock)

func _unhandled_key_input(event):
	
	if event.is_pressed():
		var key = OS.get_scancode_string(event.get_scancode_with_modifiers())
		if handleEngaged and key == "Right":
			rotateIt -= 90
			if handlePos >= 4:
				handlePos = 1
			else:
				handlePos +=1
			
		if handleEngaged and key == "Left":
			rotateIt += 90
			if handlePos <= 1:
				handlePos = 4
			else:
				handlePos -=1
		if handleEngaged and key == "Enter":
			handleEngaged = false
			raise = -2
			$Closed.play()
			#$repairPuzzle/Handle.translate(Vector3(0,0,raise))
			locked(buttonEngaged,handlePos)
			
		#on_activeSet(name)
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if round(rotateIt) > round(rotating):
		rotating += 5
		$repairPuzzle/Handle.rotation_degrees = Vector3(0,0,rotating)
		
	elif round(rotateIt) < round(rotating):
		rotating -= 5
		$repairPuzzle/Handle.rotation_degrees = Vector3(0,0,rotating)
	
	if round(raise) > round(raised):
		raised += 0.5
		#print(raised)
		$repairPuzzle/Handle.translate(Vector3(0,0,raised))
	elif round(raise) < round(raised):
		raised -= 0.5
		#print(raised)
		$repairPuzzle/Handle.translate(Vector3(0,0,raised))
	else:
		raise = 0
		raised = 0
		
	pass

func add_buttons(theLevel):
	var _dump = ""
	for i in theLevel:
		buttons.append(buttonInterface.instance())
		buttons[i].get_node("Display").texture = locks[i]
		buttons[i].connect("active",self,"on_activeSet")
		_dump = connect("reset",buttons[i],"on_reset")
		_dump = connect("selected",buttons[i],"on_selected")
		$repairPuzzle.get_node("Button"+str(i+1)).add_child(buttons[i])
		buttons[i].show()
	if theLevel < 4:
		$repairPuzzle/IndicatorPath.get_node("Indicator4").set_surface_material(1,on)
		$repairPuzzle/IndicatorPath.get_node("Indicator4").get_node("Display").hide()

func reset():
	combo = []
	for i in 3:
		$repairPuzzle/IndicatorPath.get_node("Indicator"+str(i+1)).set_surface_material(1,off)
		$repairPuzzle/IndicatorPath.get_node("Indicator"+str(i+1)).get_node("Display").hide()

func on_activeSet(name):
	buttonEngaged = name
	emit_signal("selected",name)
	$Enter.play()
	$repairPuzzle/Handle.set_surface_material(3,on)
	if buttonEngaged != "none":
		if handleEngaged == false:
			handleEngaged = true
			raise = 2
			$Open.play()
			$repairPuzzle/Handle.set_surface_material(2,on)



func _on_MainDial_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event.is_pressed():
		if event.get_button_index() == 1 and !handleEngaged:
			if buttonEngaged != "none":
				handleEngaged = true
				raise = 2
				$Open.play()
				#$repairPuzzle/Handle.translate(Vector3(0,0,raise))
				$repairPuzzle/Handle.set_surface_material(2,on)
				#$repairPuzzle/Handle.set_surface_material(3,on)
		elif event.get_button_index() == 1:
			handleEngaged = false
			raise = -2
			$Closed.play()
			#$repairPuzzle/Handle.translate(Vector3(0,0,raise))
			locked(buttonEngaged,handlePos)
		
		if handleEngaged and event.get_button_index() == 5:
			rotateIt -= 90
			if handlePos >= 4:
				handlePos = 1
			else:
				handlePos +=1
			
		if handleEngaged and event.get_button_index() == 4:
			rotateIt += 90
			if handlePos <= 1:
				handlePos = 4
			else:
				handlePos -=1
				
	pass # Replace with function body.

func locked(button,position):
	$repairPuzzle/IndicatorPath.get_node("Indicator"+str(position)).set_surface_material(1,on)
	match button:
		"Button1":
			$repairPuzzle/IndicatorPath.get_node("Indicator"+str(position)).get_node("Display").texture = locks[0]
		"Button2":
			$repairPuzzle/IndicatorPath.get_node("Indicator"+str(position)).get_node("Display").texture = locks[1]
		"Button3":
			$repairPuzzle/IndicatorPath.get_node("Indicator"+str(position)).get_node("Display").texture = locks[2]
		"Button4":
			$repairPuzzle/IndicatorPath.get_node("Indicator"+str(position)).get_node("Display").texture = locks[3]
		"Button5":
			$repairPuzzle/IndicatorPath.get_node("Indicator"+str(position)).get_node("Display").texture = locks[4]
		"Button6":
			$repairPuzzle/IndicatorPath.get_node("Indicator"+str(position)).get_node("Display").texture = locks[5]
			
	$repairPuzzle/IndicatorPath.get_node("Indicator"+str(position)).get_node("Display").show()
	$repairPuzzle/Handle.set_surface_material(2,off)
	$repairPuzzle/Handle.set_surface_material(3,off)
	emit_signal("reset")
	buttonEngaged = "none"
	combo.append({"button":button,"position":position})
	
	if len(combo) == len(lock):
		check_lock()
		
func check_lock():
	var num = 0
	var error = 0
	for cell in combo:
		if level > 6:
			if str(cell) != str(lock[num]):
				$repairPuzzle/IndicatorPath.get_node("Indicator"+str(cell["position"])).set_surface_material(1,off)
				$repairPuzzle/IndicatorPath.get_node("Indicator"+str(cell["position"])).get_node("Display").hide()
				error +=1
				num += 1
		else:
			if !str(cell) in str(lock):
				$repairPuzzle/IndicatorPath.get_node("Indicator"+str(cell["position"])).set_surface_material(1,off)
				$repairPuzzle/IndicatorPath.get_node("Indicator"+str(cell["position"])).get_node("Display").hide()
				error += 1
				
	if error == 0:
		$AnimationPlayer.play("Success")
	else:
		$Timer.start()
		$Error.play()



func _on_AnimationPlayer_animation_finished(_anim_name):
	reset()
	
	emit_signal("success")
	pass # Replace with function body.


func _on_Timer_timeout():
	print("resting")
	reset()
	$Timer.stop()
