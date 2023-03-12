extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestExecuter/TestUnhandledRegex/TestUnhandledRegex.rk"

var file_base_name = get_file_base_name(file_path)

func test_unhandled_regex():
	Rakugo.parser_add_regex_at_runtime("HW", "^hello_world$")
	
	watch_rakugo_signals()
	
	await wait_parse_and_execute_script(file_path)
	
	await wait_for_signal(Rakugo.sg_parser_unhandled_regex, 0.2)
	
	var params = get_signal_parameters(Rakugo, Rakugo.sg_parser_unhandled_regex.get_name())
	
	assert_eq(params[0], "HW")
	
	await wait_execute_script_finished(file_base_name)
