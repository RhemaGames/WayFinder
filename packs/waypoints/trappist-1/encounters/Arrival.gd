extends Node

#### OutLine
# In Arrival the ship has been boarded by an unknown alien spieces 
# In order to complete the mission and secure the ship the following has to occur
# Medic needs to make it to the med bay (if there is a medic)
# Engineer needs to make it to Engineering station to maintain control over the deck. (if engineer)
# Commander and Security are tasked at making sure Engineer and Medic survive.
# Alien has taken a part needed by the crew, crew must capture the Alien and get back the part


var cards = [
	load("res://packs/waypoints/trappist-1/scenes/card_line.tscn"),
	load("res://packs/waypoints/trappist-1/scenes/card_T.tscn"),
	load("res://packs/waypoints/trappist-1/scenes/card_cross.tscn")
]

var eventAreas = [
	{"name":"sleepbay","file":load("res://packs/waypoints/trappist-1/scenes/sleepbay.tscn")},
	{"name":"medbay","file":load("res://packs/waypoints/trappist-1/scenes/medbay.tscn")},
	{"name":"engineering","file":load("res://packs/waypoints/trappist-1/scenes/Engineering.tscn")}
]

var objects = [
	load("res://packs/waypoints/trappist-1/scenes/computer_wall.tscn"),
	load("res://packs/waypoints/trappist-1/graphics/pipes1.glb")
]

var panels = [
	load("res://packs/waypoints/trappist-1/graphics/wall_pannel.glb"),
	load("res://packs/waypoints/trappist-1/graphics/wall_pannel_open.glb")
]

var bgm1 = "res://packs/waypoints/trappist-1/music/zapsplat_science_fiction_dark_drone_breathy_airy_sinister_53084.mp3.ogg"
var bgm2 = "res://packs/waypoints/trappist-1/music/zapsplat_science_fiction_dark_drone_breathy_airy_sinister_53084.mp3.ogg"
var bgm3 = "res://packs/waypoints/trappist-1/music/Ambient_80_A#_Pads_2.ogg"
var battleMusic = "res://packs/waypoints/trappist-1/music/music_orlamusic_Epic+005.mp3.ogg"

var Root
var main_events = 4 

var info = "The ship and her crew have reached Trapist-1 through the WayPoint Generator. However, before all the system can come on line to begin their missions within the system they are laid appon by hostles. Who are they? What do they want? Get them off the ship before things spiral out of hand!" 

func story():
	pass

func story_add(data):
	print(data)

func get_main_event(event):

	var data = {
		"title":"",
		"log": "",
		"effect": {"add":"",
					"subtract":""
					},
		"requires": {"crew":"","mapsize":3,"location":"card"},
		"unlocks":[{"who":"","what":""}]
	}
	match event:
		1: 
			data["title"] = "Stations!"
			data["log"] = "Computer:\n\nLock down proceedures have been initiated.\n\nEach deck is now isolated.\n\nContain enemy threat to end lock down."
			for p in Root.currentView.players:
				if p.info["class"] == "Medic":
					data["log"] += "\n\nMedic to Med bay\n\n"
					data["effect"]["add"] = "medbay"
					data["log"] += "All other personal, defend the Medic at all cost\n\n"
					data["requires"]["mapsize"] = 5
					break
		2:
			data["title"] = "Internal Sensors are down"
			data["log"] += "\n Internal sensors are down, enemy movements are unknown.\n"
			data["requires"]["crew"] = "Medic"
			data["requires"]["location"] = "medical"
			data["unlocks"] = [{"who":"Medic","what":"fullheal"}]
			for p in Root.currentView.players:
				if p.info["class"] == "Medic":
					data["log"] += "\n The medic can now treat other crew members.\n\n"
				if p.info["class"] == "Engineer":
					data["log"] += "\n An Engineering station is available on this deck. Get the engineer to this location to restore sensors"
					data["effect"]["add"] = "engineering"
					break
		3:
			data["title"] = "Thief!"
			data["log"] = "Engineer:The aliens have done a job to my equipment. Power is at 50%.\n\n...\n\nSensors are back online,\n\nbut Commander they've stolen our flight data module!\n\n We wont be able to deploy the WayPoint or get back home without it!.\n\nCommander: You heard him, catch the theif at all costs!"
			data["requires"]["crew"] = "Engineer"
			data["requires"]["location"] = "engineering"
			data["unlocks"] = [{"who":"Enemy","what":"stolenGoods"},{"who":"Board","what":"event3"}]
		_: 
			data["title"] = "Warning ship hull breached."
			data["log"] = "An alien ship has latched on to the hull and boarding parties are starting to overwelm the ship."
			data["requires"]["mapsize"] = 3
			data["unlocks"] = [{"who":"Board","what":"enemies"}]
			for p in Root.currentView.players:
				if p.info["class"] == "Security":
					data["effect"]["add"] = "armory"
					data["log"] += "\n\nVisiting the armory will upgrade the Security officers abilities."
	return data
	
func get_crew_comment(crewclass,event):
	var data = {
		"title":"",
		"log": ""
	}
	match crewclass:
		"Medic":
			match event:
				1: 
					data["title"] = "Medic"
					data["log"] = "Lock Down!\n\nBut what about the injured on the other decks?!"
				2:
					data["title"] = "Medic"
					data["log"] = "I know I should be focusing, but these creatures are fasinating\n\n" + \
					"... \n\n"+ \
					"No, I need to tend to my crew mates \n\n"+ \
					"... \n\n" + \
					"Maybe we can capture one for study!"
				3:
					data["title"] = "Medic"
					data["log"] = "I Hate needless violence.\n\nThough I do enjoy learning about new life forms.\n\nMaybe I can collect a sample!!"
					
				_:
					data["title"] = "Medic"
					data["log"] = "Anyone else sore? I'm sore...maybe my pod was broken.\n\n Commander, do I look older...Commander?"
					
		"Security":
			match event:
				1:
					data["title"] = "Security"
					data["log"] = "Just when I thought I was going to get to take a nice break. \n\nBAM! \n\nAliens! "
					
				2:
					data["title"] = "Security"
					data["log"] = ""
				3:
					data["title"] = "Security"
					data["log"] = ""
				_:
					data["title"] = "Security"
					data["log"] = "Regulations state everyone should have a side arm when on duty. We shouldn't need anything else but I'm glad we have a fully stocked armory.\n\nThe top brass got that right at least."
		"Commander":
			match event:
				1:
					data["title"] = "Commander"
					data["log"] = "This was not how first contact was supposed to go.\n\n Maybe when the shooting stops we can parley with these Aliens.\n\n\nWe are in their backyard after all."
				2:
					data["title"] = "Commander"
					data["log"] = ""
				3:
					data["title"] = "Commander"
					data["log"] = ""
				_:
					data["title"] = "Commander"
					data["log"] = "Hope everyone had a good nap, but its time to get to work. Gear up and lets make sure we're ready for whatever discoveries this system has in store!"
		"Engineer":
			match event:
				1:
					data["title"] = "Engineer"
					data["log"] = "Why!\n\n\n I have worked on countless warships and never once saw combat. \nThe first time I get to work on a research vesel we get into an intersellar conflict the first trip out\n...\nPerfect!"			
				2:
					data["title"] = "Engineer"
					data["log"] = ""
				3:
					data["title"] = "Engineer"
					data["log"] = ""
				_:
					data["title"] = "Engineer"
					data["log"] = "That...was...better than I expected. I'll head to Engineering as soon as I can, Commander. Who knows what that jump did to our equipment"
	return data

func load_combatant():
	var combatant = load("res://packs/waypoints/trappist-1/scenes/Enemy1.tscn")
	return combatant

func load_cards():
	var card = load("res://packs/waypoints/trappist-1/scenes/card.tscn")
	return card

func load_battleGround():
	var battleGround = load("res://packs/waypoints/trappist-1/scenes/BattleGround.tscn")
	return battleGround
