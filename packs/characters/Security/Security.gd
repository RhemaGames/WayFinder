extends Spatial

signal react(type)
signal finish(type)

var command1 = preload("res://packs/characters/Security/assets/Tex_skill_13.PNG")
var command2 = preload("res://packs/characters/Security/assets/Tex_skill_42.PNG")
var command3 = preload("res://packs/characters/Security/assets/Tex_skill_28.PNG")

var animQueue = []
var shields = false

var weapon = preload("res://packs/characters/gun1.glb")
var lazerbeam = preload("res://packs/characters/Effects/sfx/zapsplat_science_fiction_retro_laser_beam_002_44337.mp3.ogg")
var shield = preload("res://packs/characters/Effects/sfx/zapsplat_science_fiction_droning_pulsating_force_field_25225.mp3.ogg")

#var theme = "res://packs/characters/Security/assets/PLPSF-Synthworks_11_C_100bpm.wav"

var commands = [{
	"name":"Take Aim",
	"type":"general",
	"cost":2,
	"unlock":"",
	"discription":"Increases range by two cards in a straight line.",
	"effect":{"target":"enemy","view":"Targetting","when":"command","range":3,"duration":1},
	"icon": command1
},{
	"name": "Rapid Fire",
	"type":"combat",
	"cost":1,
	"unlock":"",
	"discription": "Gives one extra attack roll",
	"effect":{"target":"enemy","view":"special","when":"combat","attackRoll":2,"duration":1},
	"icon": command2
},{
	"name": "Tactical Retreat",
	"type":"special",
	"cost":4,
	"unlock":"",
	"discription":"During combat all players in combat can make a one card retreat outside of turn order",
	"effect":{"target":["ally","all"],"view":"ActionView","when":"command","movement":-1,"duration":1},
	"icon": command3
}]
var hp = 10

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	$Security/AnimationPlayer.connect("animation_finished",self,"do_stuff")
	animQueue.append("deflect")
	animQueue.append("onBaseSecurity")
	pass # Replace with function body.


func _process(_delta):
	if !$Security/AnimationPlayer.is_playing() and len(animQueue) > 0:
		if $Security/AnimationPlayer.has_animation(animQueue[0]):
			$Security/AnimationPlayer.play(animQueue[0])
		
		
func get_info():
	var data = {
		"class":name,
		"hp": hp,
		"commands":commands
	}
	return data
	
func action(act):
	match act:
		"start":
			animQueue.append("startSecurity")
			#$Commander/AnimationPlayer.play("start")
		"melee":
			animQueue.append("meleeSecurity")
			#$Commander/AnimationPlayer.play("melee")
		"range":
			$Timer.start()
			$sfx.stream = lazerbeam
			animQueue.append("rangedSecurity")
			#$Commander/AnimationPlayer.play("ranged")
		"hit":
			animQueue.append("hitSecurity")
			#$Commander/AnimationPlayer.play("hit")
		"block":
			$sfx.stream = shield
			animQueue.append("block")
			shields = true
			$sfx.play()
			#$AnimationPlayer.block("block")
		"drop":
			animQueue.append("deflect")
			shields = false
			$sfx.stop()
		"win":
			animQueue.append("winSecurity")
			shields = false
		"loss":
			animQueue.append("lossSecurity")
			shields = false

func do_stuff(anim_name):
	if anim_name == "rangedSecurity":
		$laserbolt.emitting = false
		$sfx.stop()
	if anim_name == "block":
		emit_signal("react","block")
	if anim_name == "rangedSecurity":
		emit_signal("react","ranged")
	if anim_name == "meleeSecurity":
		emit_signal("react","melee")
	if anim_name == "winSecurity":
		emit_signal("finish","win")
	if anim_name == "lossSecurity":
		emit_signal("finish","loss")
		
	animQueue.remove(0)

func _on_Timer_timeout():
	$laserbolt.emitting = true
	$sfx.play()
	$Timer.stop()
	pass # Replace with function body.
