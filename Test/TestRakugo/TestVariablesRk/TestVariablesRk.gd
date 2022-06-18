extends GutTest

func test_variables():
	Rakugo.set_variable("a", 1)
	
	var a = Rakugo.get_variable("a")
	
	assert_eq(a, 1)
	
	Rakugo.define_character("Sy", "Sylvie")
	
	Rakugo.set_variable("Sy.a", 1)
	
	var sya = Rakugo.get_variable("Sy.a")
	
	assert_eq(sya, 1)
		
	assert_eq(Rakugo.get_variable("b"), null)
	
	assert_eq(Rakugo.get_variable("Bob.a"), null)
	
	assert_eq(Rakugo.get_variable("Sy.b"), null)
