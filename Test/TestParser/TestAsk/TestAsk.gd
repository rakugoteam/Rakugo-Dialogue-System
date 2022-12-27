extends GutTest

const file_name = "res://test/TestParser/TestAsk/TestAsk.rk"

var file_base_name = file_name.get_file().get_basename()

func test_ask():
	watch_signals(Rakugo)
	
	Rakugo.parse_and_execute_script(file_name)
	
	yield(yield_to(Rakugo, "ask", 0.2), YIELD)
	
	assert_signal_emitted_with_parameters(
		Rakugo,
		"ask",
		[{}, "Are you human ?", "Yes"])
		
	Rakugo.ask_return("No")
	
	assert_eq("No", Rakugo.get_variable("answer"))
	
	yield(yield_to(Rakugo, "execute_script_finished", 0.2), YIELD)
	
	assert_signal_emitted_with_parameters(
		Rakugo,
		"execute_script_finished",
		[file_base_name])
