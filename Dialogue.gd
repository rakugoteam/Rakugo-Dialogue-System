extends Dialogue

var player_name:String

func hello_world():
	say(null, "Hello, World !")
	
	step()
	
	say(null, "What is your name ?")
	
	player_name = ask("Paul")

	say(null, "Your name is " + player_name + " !")
