extends GutTest

const file_name = "res://Test/TestParser/TestVariable/TestVariable.rk"

func before_all():
	Rakugo.parse_and_execute_script(file_name)

func test_variable():
	yield(yield_to(Rakugo, "say", 0.2), YIELD)

	var a = Rakugo.get_variable("aaa")
	
	assert_eq(typeof(a), TYPE_INT)
	assert_eq(a, 1)

	var b = Rakugo.get_variable("bbb")

	assert_eq(typeof(b), TYPE_REAL)
	assert_eq(b, 2.5)

	var c = Rakugo.get_variable("ccc")

	assert_eq(typeof(c), TYPE_STRING)
	assert_eq(c, "Hello, world !")

	var d = Rakugo.get_variable("ddd")
	
	assert_eq(d, a)
	
	var syname = Rakugo.get_variable("Sy.name")
	
	assert_eq(typeof(syname), TYPE_STRING)
	assert_eq(syname, "Sylvie")
	
	var sylife = Rakugo.get_variable("Sy.life")
	
	assert_eq(typeof(sylife), TYPE_INT)
	assert_eq(sylife, 5)
	
	var e = Rakugo.get_variable("eee")
	
	assert_eq(e, sylife)

	assert_eq(Rakugo.get_variable("fff"), null)
