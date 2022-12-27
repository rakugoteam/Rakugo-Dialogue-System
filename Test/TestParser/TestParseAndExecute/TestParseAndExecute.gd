extends GutTest

const file_names = [
	"res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_0.rk",
	"res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_1.rk"
]
	
var file_base_names = [
	file_names[0].get_file().get_basename(),
	file_names[1].get_file().get_basename()
]

var test_params = [[false, 0], [false, 1], [true, 0], [true, 1]]
func test_parse_and_execute(params=use_parameters(test_params)):
	watch_signals(Rakugo)
	
	if params[0]:
		Rakugo.execute_script(file_base_names[params[1]])
	else:
		Rakugo.parse_and_execute_script(file_names[params[1]])
	
	yield(yield_to(Rakugo, "execute_script_start", 0.2), YIELD)
	
	assert_signal_emitted_with_parameters(
		Rakugo,
		"execute_script_start",
		[file_base_names[params[1]]])

	yield(yield_to(Rakugo, "say", 0.2), YIELD)

	assert_signal_emitted_with_parameters(
		Rakugo,
		"say",
		[{}, "Hello, world " + str(params[1]) + " !"])
		
	Rakugo.do_step()
		
	yield(yield_to(Rakugo, "execute_script_finished", 0.2), YIELD)
	
	assert_signal_emitted_with_parameters(
		Rakugo,
		"execute_script_finished",
		[file_base_names[params[1]]])
