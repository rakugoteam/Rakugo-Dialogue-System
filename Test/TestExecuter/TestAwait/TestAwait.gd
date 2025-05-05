extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestExecuter/TestAwait/TestAwait.rk"

var file_base_name = get_file_base_name(file_path)

func test_await():
	watch_rakugo_signals()
	
	var timer := Timer.new()
	add_child(timer)
	timer.add_to_group("senders")
	timer.wait_time = 3
	watch_signals(timer)
	
	await wait_parse_and_execute_script(file_path)
	timer.start()
	await wait_for_signal(timer.timeout, timer.wait_time)
	await wait_say({}, "You should see this message after 3s.")

	await wait_execute_script_finished(file_base_name)
