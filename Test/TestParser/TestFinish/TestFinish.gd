extends GutTest

const file_path = "res://Test/TestParser/TestFinish/TestFinish.rk"

var file_name := ""
func _on_execute_script_finished(file_base_name:String):
	file_name = file_base_name

func test_finish():
	Rakugo.connect("execute_script_finished", self, "_on_execute_script_finished")
	
	Rakugo.parse_and_execute_script(file_path)
	
	Rakugo.do_step()

	yield(yield_to(Rakugo, "execute_script_finished", 0.2), YIELD)
	
	assert_eq(file_name, "TestFinish")
