extends GutTest

const file_name = "res://Test/TestParser/TestStartFromLabel/TestStartFromLabel.rk"

var file_base_name = file_name.get_file().get_basename()

func test_start_from_label():
	watch_signals(Rakugo)
	
	Rakugo.parse_and_execute_script(file_name, "pictures")

	yield(yield_to(Rakugo, "execute_script_start", 0.2), YIELD)
	
	yield(yield_to(Rakugo, "say", 0.2), YIELD)

	assert_signal_emitted_with_parameters(
		Rakugo,
		"say",
		[{}, "Pictures of places that I have visited."])

	assert_true(Rakugo.waiting_step)

	Rakugo.do_step()

	yield(yield_to(Rakugo, "execute_script_finished", 0.2), YIELD)

	assert_signal_emitted_with_parameters(
		Rakugo,
		"execute_script_finished",
		[file_base_name])
