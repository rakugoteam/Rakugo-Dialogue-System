extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestParser/TestParseFail/TestParseFail.rk"

func test_parse_fail():
    watch_rakugo_signals()

    assert_eq(Rakugo.parse_script(file_path), FAILED)