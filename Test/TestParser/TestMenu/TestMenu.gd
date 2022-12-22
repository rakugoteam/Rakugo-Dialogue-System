extends GutTest

const file_name = "res://test/TestParser/TestMenu/TestMenu.rk"

var file_base_name = file_name.get_file().get_basename()

func test_menu():
	watch_signals(Rakugo)
	
	Rakugo.parse_and_execute_script(file_name)
	
	yield(yield_to(Rakugo, "menu", 0.2), YIELD)
	
	assert_signal_emitted_with_parameters(
		Rakugo,
		"menu",
		[PoolStringArray(["Loop", "End"])])

	Rakugo.menu_return(0)
	
	yield(yield_to(Rakugo, "menu", 0.2), YIELD)
	
	assert_signal_emitted_with_parameters(
		Rakugo,
		"menu",
		[PoolStringArray(["Loop", "End"])])
		
	Rakugo.menu_return(2)

	yield(yield_to(Rakugo, "execute_script_finished", 0.2), YIELD)

	assert_signal_emitted_with_parameters(
		Rakugo,
		"execute_script_finished",
		[file_base_name])
