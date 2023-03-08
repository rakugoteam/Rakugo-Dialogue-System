# ![Logo](WindowIcon.png) Rakugo Dialog System

![MIT License](https://img.shields.io/static/v1.svg?label=📜%20License&message=MIT&color=informational)
[![Join the Discord channel](https://img.shields.io/static/v1.svg?label=Join%20our%20Discord%20channel&message=🎆&color=7289DA&logo=discord&logoColor=white&labelColor=2C2F33)](https://discord.gg/K9gvjdg)
[![GitHub](https://img.shields.io/github/contributors/rakugoteam/Rakugo.svg)](https://github.com/rakugoteam/Rakugo)
[![GitHub](https://img.shields.io/github/stars/rakugoteam/Rakugo.svg)](https://github.com/rakugoteam/Rakugo)
[![GitHub](https://img.shields.io/github/forks/rakugoteam/Rakugo.svg)](https://github.com/rakugoteam/Rakugo/network)
[![github-watchers](https://img.shields.io/github/watchers/rakugoteam/Rakugo?label=Watch&style=social&logo=github)](https://github.com/rakugoteam/Rakugo)
[![GitHub](https://img.shields.io/github/issues/rakugoteam/Rakugo.svg)](https://github.com/rakugoteam/Rakugo/issues)
[![GitHub](https://img.shields.io/github/issues-closed/rakugoteam/Rakugo.svg)](https://github.com/rakugoteam/Rakugo/issues)

Core of our projects. Inspired by [Ren'Py](https://www.renpy.org), this project aiming to provide a way to make narrative-based games on [Godot](https://godotengine.org) easily. Simplify your project, if it is a visual novel, point and click, RPG, interactive text game or many other styles and blends of styles.

Support this project here [itch.io](https://rakugoteam.github.io/donations/).

[Showcase](#Showcase) -
[Installation](#Installation) -
[Use .rk files](#Use-.rk-files) -
[Get Started](#Get-Started) -
[Documentation](#Documentation) -
[Rakugo Addons](#Rakugo-Addons) -
[FAQ](#faq) -
[Infos](#Infos)

---

## Feature
* Ren'Py like
* Dialog system (say, choices, ask, jump)
* Own script language
* Save/Load system
* Global variables and character's variables
* Unit tested with [Gut](https://github.com/bitwes/Gut)

## Showcase

### Examples

Check our project [Examples](https://github.com/rakugoteam/Examples) to see examples of uses. You can copy and customize them for yours projects too !

### Games

- [**Space drive beats**](https://plopsis.itch.io/space-drive-beats)
- [**Bot Saves Dream**](https://plopsis.itch.io/curator-bot)
- [**Mon Dernier Jour**](https://theludovyc.itch.io/mondernierjour)

If your game uses Rakugo, tell us on [Discord](https://discord.gg/K9gvjdg).

## Update from Godot 3.X to 4.X
Signal system have changed. So we renamed all Rakugo signals.

Just add "sg_" at begining. Like "old_signal_name" to "sg_old_signal_name".

Everything else is the same.

## Installation

To install Rakugo plugin, download it [here](https://github.com/rakugoteam/Rakugo/releases). Then extract the `Rakugo` folder into your `res://addons` folder. Finaly, enable the plugin in project settings and restart Godot-Engine.

If you want to know more about installing plugins you can read the [godot official documentation page](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).

## Use .rk files
### Configure Godot
Rk files are text files. So you can use .txt extension. But if you want to use .rk you can do this :
- Go to Editor > Editor Settings
- In search bar type : "Extensi"
- Add "rk"

### Export
**/!\ .rk files are not exported by default /!\\**

Follow this guide https://rakugoteam.github.io/rakugo-docs/export/

## Get Started

- Create a scene with a Node and add a script on it

GdScript (Node.gd) :

```gdscript
extends Node

const file_path = "res://Timeline.rk"

func _ready():
	Rakugo.sg_say.connect(_on_say)
	Rakugo.sg_step.connect(_on_step)
	Rakugo.sg_execute_script_finished.connect(_on_execute_script_finished)
  
	Rakugo.parse_and_execute_script(file_path)
  
func _on_say(character:Dictionary, text:String):
	prints("Say", character.get("name", ""), text)
  
func _on_step():
	prints("Press \"Enter\" to continue...")
	
func _on_execute_script_finished(file_name:String, error_str:String):
	prints("End of script")
  
func _process(delta):
	if Rakugo.is_waiting_step() and Input.is_action_just_pressed("ui_accept"):
		Rakugo.do_step()
```

- Create your first RakuScript (text file) *"Timeline.rk"* at root of your project folder (res://)

RkScript (Timeline.rk) :

```
character Gd "Godot"
Gd "Hello, world !"
Gd "I'm <Gd.name> !"
```

- Run Scene (F6)

Out :
```
Say Godot Hello, world !
Press "Enter" to continue...
Say Godot I'm Godot !
Press "Enter" to continue...
End of script
```

## Documentation
If you want to know how to use Rakugo or write rk scripts.

Go to https://rakugoteam.github.io/rakugo-docs/ !

## FAQ:

**Q:** So it's about adding a dialogue system to the engine? </p>
**A:** Yes

**Q:** How does the project works ? </p>
**A:** By signals and methods from a singleton (autoload) called Rakugo.

**Q:** Is it easy to use ?</p>
**A:** Yes

**Q:** What difference with [Dialogic](https://github.com/coppolaemilio/dialogic) ?</p>
**A:** Our project use normal coding with our own scripting langue inspired by Ren'Py, instead of visual. Plus is just a core, simple as possible, autoloaded when you enabled the plugin. If you want more check our addons and kits bellow.

## Rakugo Addons

- [Advanced Text](https://github.com/rakugoteam/AdvancedText)

## Rakugo Kits

- [Visual Novel](https://github.com/rakugoteam/VisualNovelKit)
- [Click & Point Adventures](https://github.com/rakugoteam/Adventure)
- [RPG](https://github.com/rakugoteam/rakugo-open-rpg)

## Infos

If you want to help please write to us on our [Discord](https://discord.gg/K9gvjdg).

- Rakugo Team website: https://rakugoteam.github.io/

- [Godot icons](https://github.com/godotengine/godot-design/tree/master/engine/icons/optimized)

- icons from [game-icons.net](https://game-icons.net)

