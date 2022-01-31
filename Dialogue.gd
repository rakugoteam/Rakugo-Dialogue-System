extends Dialogue

var player_name:String

var choice:= 0

func hello_world():
	say(null, "Hello, World !")
	
	step()
	
	say(null, "What is your name ?")
	
	player_name = ask("Paul")

	say(null, "Your name is " + player_name + " !")
	
	choice = menu([
		["A", "a", {}],
		["B", "b", {}]
		])

	notify("This choice have consequences !")

	match(choice):
		1:
			say(null, "B")
