extends "res://Test/RakugoTest.gd"

const file_paths = [
	"res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_0.rk",
	"res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_1.rk"
]
	
var file_base_names = [
	get_file_base_name(file_paths[0]),
	get_file_base_name(file_paths[1])
]

var test_params = [[false, 0], [false, 1], [true, 0], [true, 1]]
func test_parse_and_execute(params=use_parameters(test_params)):
	watch_signals(Rakugo)

	var index = params[1]

	var file_path = file_paths[index]

	var file_base_name = file_base_names[index]
	
	if params[0]:
		Rakugo.execute_script(file_base_name)
	else:
		Rakugo.parse_and_execute_script(file_path)
	
	yield(wait_execute_script_start(file_base_name), "completed")

	yield(wait_say({}, "Hello, world " + str(index) + " !"), "completed")

	assert_do_step()
	
	yield(wait_execute_script_finished(file_base_name), "completed")
