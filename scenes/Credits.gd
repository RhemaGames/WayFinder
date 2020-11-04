extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func appear():
	$RichTextLabel.clear()
	$AnimationPlayer.play("appear")
	credits()
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name:
		$RichTextLabel/AnimationPlayer.play("appear")
		
func credits():
	var bbcode = $RichTextLabel
	bbcode.bbcode_text = ""
	bbcode.append_bbcode('[font=res://assets/Title.tres][center]Credits[/center][/font]\n')
	bbcode.append_bbcode('\n\n')
	
	bbcode.append_bbcode('[font=res://assets/menuFontMedium.tres]Concept:[/font]\n\n')
	bbcode.append_bbcode('[indent]Benjamin Flanagin[/indent]')
	
	bbcode.append_bbcode('\n\n\n')
	
	bbcode.append_bbcode('[font=res://assets/menuFontMedium.tres]Developer:[/font]\n\n')
	bbcode.append_bbcode('[indent]Benjamin Flanagin[/indent]')
	
	bbcode.append_bbcode('\n\n\n')
	
	bbcode.append_bbcode('[font=res://assets/menuFontMedium.tres]Design:[/font]\n\n')
	bbcode.append_bbcode('[indent]Benjamin Flanagin[/indent]')
	
	bbcode.append_bbcode('\n\n\n')
	
	bbcode.append_bbcode('[font=res://assets/menuFontMedium.tres]Graphics:[/font]\n\n')
	bbcode.append_bbcode('[indent]Benjamin Flanagin[/indent]')
	
	bbcode.append_bbcode('\n\n\n')
	
	bbcode.append_bbcode('[font=res://assets/menuFontMedium.tres]Sound:[/font]\n\n')
	bbcode.append_bbcode('[indent]Zap Splat[/indent]')
	bbcode.append_bbcode('\n[indent]Website:[url]https://www.zapsplat.com/[/url][/indent]')
	
	bbcode.append_bbcode('\n\n\n')
	
	bbcode.append_bbcode('[font=res://assets/menuFontMedium.tres]Testers:[/font]\n\n')
	
	bbcode.append_bbcode('[rainbow][indent]Your name here![/indent][/rainbow]')
	
	bbcode.append_bbcode('\n\n\n')
	
	bbcode.append_bbcode('Special thanks to all those that support the game on Patreon.')
	bbcode.append_bbcode('If you would like to become a tester and get other special rewards consider becoming a patron.')
	bbcode.append_bbcode('[url]https://www.patreon.com/vagueentertainment[/url]')

	bbcode.append_bbcode('\n\n\n')
