extends GutTest

const file_path = "res://Test/TestParser/TestExit/TestExit.rk"

var script_name := ""
func _on_execute_script_finished(file_base_name:String):
	script_name = file_base_name

func test_exit():
	Rakugo.connect("execute_script_finished", self, "_on_execute_script_finished")
	
	Rakugo.parse_and_execute_script(file_path)
	
	Rakugo.do_step()
	
	yield(yield_to(Rakugo, "execute_script_finished", 0.2), YIELD)

	assert_eq(script_name, "TestExit")
