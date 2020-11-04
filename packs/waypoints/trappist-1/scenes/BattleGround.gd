extends Spatial

var current_camera = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var select = 1
var rotateIt = 0
var rotating = 0
var countdown = 10

var pmodel
var playerName = "Generic Crew"
var playerClass = "Commander"
var playerHealth = 3

var enemyName = "Grunt"
var enemyClass = "Grunt"
var enemyHealth = 3
var enemy_attack = 0

var combatant1 = ""
var combatant2 = ""

signal battle_over(winner,loser)
# warning-ignore:unused_signal
signal battle_start()
signal to_ui(command)
#signal player_hit()
#signal enemy_hit()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$PlayerCamera/eStats.hide()
	$PlayerCamera/Choices.hide()
	$PlayerCamera/Stats.hide()
	
	#connect("player_hit",$PlayerCamera/Choices,"from_above")
	#connect("enemy_hit",$PlayerCamera/eChoices,"on_hit")
# warning-ignore:return_value_discarded
	connect("battle_start",self,"_on_battle_start")
# warning-ignore:return_value_discarded
	connect("battle_over",self,"_on_battle_over")
	
	for scene in [$PlayerCamera/Choices,$PlayerCamera/Stats,$PlayerCamera/eStats,$PlayerCamera/eChoices]:
	# warning-ignore:return_value_discarded
		connect("to_ui",scene,"from_Above")

	#hide()
	#show()
	#emit_signal("battle_start")
	
	#$PlayerCamera/GUIPanel3D.node_viewport = $Viewport
	#$EnemyCamera/GUIPanel3D.node_viewport = $Viewport
	#$slow_rotate/Camera/GUIPanel3D.node_viewport = $Viewport
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$slow_rotate.rotate_y(0.001)
	#$Viewport/Controls/EnemyChoice/Control.rect_rotation += 0.1

	pass


func _on_Timer_timeout():
	pass

# warning-ignore:shadowed_variable
func use_current(select):
	randomize()
# warning-ignore:unused_variable
	#var choices = ["block","melee","command","ranged"]
	match select:
		1:
			enemy_attack = round(rand_range(1,3))
			#clear_select()
			$Player.get_child(1).action("block")
			enemy_action(enemy_attack)
			#shoot(choices[select-1])
		2:
			enemy_attack = round(rand_range(1,3))
			#clear_select()
			$Player.get_child(1).action("melee")
			enemy_action(enemy_attack)
			#shoot(choices[select-1])
		3:
			pass
			
		4:
			enemy_attack = round(rand_range(1,3))
			#clear_select()
			$Player.get_child(1).action("range")
			enemy_action(enemy_attack)
			#shoot(choices[select-1])

func enemy_action(act):
	var _choices = ["melee","ranged","block","command"]
	var _enemy_choice =  _choices[act-1]
	#print("from battle ground: ",_enemy_choice)
	match _enemy_choice:
		"ranged":
			$Enemy.get_child(1).action("range")
		"melee":
			$Enemy.get_child(1).action("melee")
		"block":
			$Enemy.get_child(1).action("block")

func shoot(pressed):
	print("shooting")
	#randomize()
	#enemy_attack = round(rand_range(1,3))
	var _choices = ["melee","ranged","block"]
	var _enemy_choice =  _choices[enemy_attack-1]
	
	#print("Player choice ",pressed)
	#print("Enemy choice ",_enemy_choice)
	#print("\n")
	
	if pressed == "melee" and _enemy_choice == "block":
		$PlayerCamera.make_current()
		player_wins(pressed)
		$Enemy.get_child(1).action("drop")
	elif pressed == "block" and _enemy_choice == "ranged":
		$PlayerCamera.make_current()
		player_wins(pressed)
	elif pressed == "ranged" and _enemy_choice == "melee":
		$PlayerCamera.make_current()
		player_wins(pressed)
	elif pressed == _enemy_choice:
		if pressed != "block":
			$PlayerCamera.make_current()
			player_wins(pressed)
			enemy_wins(_enemy_choice)
		else:
			$Player.get_child(1).action("drop")
			$Enemy.get_child(1).action("drop")
	else:
		$PlayerCamera.make_current()
		#$EnemyCamera.make_current()
		enemy_wins(_enemy_choice)
		if pressed == "block":
			$Player.get_child(1).action("drop")
	emit_signal("to_ui",["timer","start"])
	#$Timer.start()

func _on_battle_start():
	var turn = WayFinder.turn
	var eHealthBar = $PlayerCamera/eStats/Viewport.get_child(0).get_node("HBoxContainer/healthbar")
	var pHealthBar = $PlayerCamera/Stats/Viewport.get_child(0).get_node("HBoxContainer/healthbar")
	#$Timer.start()
	$PlayerCamera.make_current()
	$PlayerCamera/Choices.force_resize()
	#$slow_rotate/Camera.make_current()
	if typeof(combatant1) != TYPE_STRING:
		playerHealth = combatant1.info["hp"]
		playerClass = combatant1.info["class"]
		pmodel = WayFinder.get_character_class(playerClass)
		$PlayerCamera/Stats/Viewport.get_child(0).get_node("HBoxContainer/VBoxContainer/Name").text = WayFinder.players[turn-1].info["name"]
		$PlayerCamera/Stats/Viewport.get_child(0).get_node("HBoxContainer/VBoxContainer/player").text = "Player "+str(turn)
		pHealthBar.max_value = combatant1.info["maxHp"]
		pHealthBar.value = playerHealth
	else:
		playerHealth = 5
		playerClass = "Commander"
		pmodel = load("res://packs/characters/Commander/Commander.tscn").instance()
		pHealthBar.max_value = 5
		pHealthBar.value = playerHealth
	
	pmodel.connect("react",self,"shoot")
	pmodel.connect("finish",self,"finish")
	
	$Player.add_child(pmodel)
	
	if typeof(combatant2) != TYPE_STRING:
		enemyHealth = combatant2.info["hp"]
		eHealthBar.max_value = combatant2.info["maxHp"]
		eHealthBar.value = enemyHealth
	else:
		enemyHealth = 3
		eHealthBar.max_value = 3
		eHealthBar.value = enemyHealth

	$Player.get_child(1).action("start")
	$Enemy.get_child(1).action("start")
	
func finish(set):
	if set == "win":
		emit_signal("battle_over",combatant1,combatant2)
	else:
		emit_signal("battle_over",combatant2,combatant1)
		
	
func _on_battle_over(_winner,_loser):

	if typeof(combatant1) != TYPE_STRING:
		$Player.remove_child($Player.get_child(1))
		pmodel.queue_free()
	
	if typeof(combatant1) != TYPE_STRING:
		_winner.inCombat = false
		_loser.inCombat = false
	#$Timer.stop()
	select = 1
	countdown = 15
	pass

func player_wins(type):
	print("Player wins with ", type)
	
	if type != "block":
		enemyHealth -= 1
		if $Enemy.get_child(1).shields:
			$Enemy.get_child(1).action("drop")
	else:
		$Player.get_child(1).action("drop")
	#else:
	#	$Player.get_child(1).action("deflect")
		
	var eHealthBar = $PlayerCamera/eStats/Viewport.get_child(0).get_node("HBoxContainer/healthbar")
	eHealthBar.value = enemyHealth
	#$AnimationPlayer.play("Begin")
	
	if enemyHealth == 0:
		if typeof(combatant1) != TYPE_STRING:
			combatant1.info["hp"] = playerHealth
			#$Viewport/Controls.hide()
			#$Timer.stop()
		emit_signal("to_ui",["enemy","hit"])
		$Player.get_child(1).action("win")
		$Enemy.get_child(1).action("loss")
	else:
		emit_signal("to_ui",["enemy","hit"])
		
	#$Timer.start()
	#$slow_rotate/Camera.make_current()

func enemy_wins(type):
	print("Enemy wins with ", type)
	
	if type != "block" and $Player.get_child_count() > 1:
		playerHealth -= 1
		if $Player.get_child(1).shields:
			$Player.get_child(1).action("drop")
	else:
		$Enemy.get_child(1).action("drop")
		
	var pHealthBar = $PlayerCamera/Stats/Viewport.get_child(0).get_node("HBoxContainer/healthbar")
	pHealthBar.value = playerHealth
	#$AnimationPlayer.play("Begin")
	
	if playerHealth == 0:
		if typeof(combatant1) != TYPE_STRING:
			combatant2.info["hp"] = enemyHealth
			combatant1.info["hp"] = playerHealth
			#$Viewport/Controls.hide()
			#$Timer.stop()
		emit_signal("to_ui",["player","hit"])
		$Enemy.get_child(1).action("win")
		$Player.get_child(1).action("loss")
	else:
		emit_signal("to_ui",["player","hit"])
		$Player.get_child(1).action("hit")
		
	#$Timer.start()
	#$slow_rotate/Camera.make_current()


func _on_BattleGround_visibility_changed():
	if visible:
		#$Timer.start()
		countdown = 15
		select = 1
		current_camera = 0
		select = 1
		rotateIt = 0
		rotating = 0
		playerName = "Generic Crew"
		playerClass = "Commander"
		playerHealth = 3

		enemyName = "Grunt"
		enemyClass = "Grunt"
		enemyHealth = 3
		enemy_attack = 0
		$PlayerCamera/eStats.show()
		$PlayerCamera/Choices.show()
		$PlayerCamera/Stats.show()
		combatant1 = ""
		combatant2 = ""
		$AnimationPlayer.play("Begin")
		#$Viewport/Controls.show()
	else:
		#$Viewport/Controls.hide()
		$PlayerCamera/eStats.hide()
		$PlayerCamera/Choices.hide()
		$PlayerCamera/Stats.hide()
		#$Timer.stop()


func _on_Choices_relay(baton):
	if baton[0] == "selected":
		use_current(baton[1])
		
	if baton[0] == "countdown":
		$Countdown.show()
		$Countdown/Count.text = str(baton[1])
		if baton[1] == 0 or baton[1] > 3:
			$Countdown.hide()
		
	pass # Replace with function body.
