# ![Logo](WindowIcon.png) Rakugo

![MIT License](https://img.shields.io/static/v1.svg?label=📜%20License&message=MIT&color=informational)
[![Join the Discord channel](https://img.shields.io/static/v1.svg?label=Join%20our%20Discord%20channel&message=🎆&color=7289DA&logo=discord&logoColor=white&labelColor=2C2F33)](https://discord.gg/K9gvjdg)
[![GitHub](https://img.shields.io/github/contributors/rakugoteam/Rakugo.svg)](https://github.com/rakugoteam/Rakugo)
[![GitHub](https://img.shields.io/github/stars/rakugoteam/Rakugo.svg)](https://github.com/rakugoteam/Rakugo)
[![GitHub](https://img.shields.io/github/forks/rakugoteam/Rakugo.svg)](https://github.com/rakugoteam/Rakugo/network)
[![github-watchers](https://img.shields.io/github/watchers/rakugoteam/Rakugo?label=Watch&style=social&logo=github)](https://github.com/rakugoteam/Rakugo)
[![GitHub](https://img.shields.io/github/issues/rakugoteam/Rakugo.svg)](https://github.com/rakugoteam/Rakugo/issues)
[![GitHub](https://img.shields.io/github/issues-closed/rakugoteam/Rakugo.svg)](https://github.com/rakugoteam/Rakugo/issues)

Inspired by [Ren'Py](https://www.renpy.org), Rakugo is a project aiming to provide a way to make narrative-based games on [Godot](https://godotengine.org) easily. Simplify your project, if it is a visual novel, point and click, RPG, interactive text game or many other styles and blends of styles.

Support this project here [itch.io](https://rakugoteam.github.io/donations/).

[Showcase](#Showcase) -
[Installation](#Installation) -
[Get Started](#Get-Started) -
[Rakugo Addons](#Rakugo-Addons) -
[Roadmap](#Roadmap) -
[FAQ](#faq) -
[Infos](#Infos)

---

## Feature
* Ren'Py like
* Dialog system (say, choices, ask, jump)
* Own script language
* Save/Load system
* Global variables and character's variables

## Showcase

- [**Space drive beats**](https://plopsis.itch.io/space-drive-beats)
- [**Bot Saves Dream**](https://plopsis.itch.io/curator-bot)
- [**Mon Dernier Jour**](https://theludovyc.itch.io/mondernierjour)

If your game uses Rakugo, tell us on [Discord](https://discord.gg/K9gvjdg).

## Installation

To install Rakugo plugin, download it as a [ZIP archive](https://github.com/rakugoteam/Rakugo/releases). Extract the `addons/Rakugo` folder into your project folder. Then, enable the plugin in project settings and restart Godot-Engine.

If you want to know more about installing plugins you can read the [godot official documentation page](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).

## Get Started

- Create a scene with a Node and script on it

Basic GdScript (Node.gd) :
```gdscript
extends Node

const file_path = "res://Timeline.rk"

func _ready():
  Rakugo.connect("say", self, "_on_say")
  Rakugo.connect("step", self, "_on_step")
  
  Rakugo.parse_and_execute_script(file_path)
  
func _on_say(character:Dictionary, text:String):
  prints("say", character.get("name", ""), text)
  
func _on_step():
  prints("Press 'Enter' to continue...")
  
func _process(delta):
  if Rakugo.is_waiting_step() and Input.is_action_just_pressed("ui_accept"):
    Rakugo.do_step()
```

- Create your first RakuScript (text file) *"Timeline.rk"* at root of your project folder (res://)

Basic RkScript (Timeline.rk) :
```
character Gd "Godot"
Gd "Hello, world !"
Gd "I'm <Gd.name> !"
```

- Run Scene (F6)

## Documentation
Check the [wiki](https://github.com/rakugoteam/Rakugo/wiki) to learn more things !

## Rakugo Addons
- [Advanced Text](https://github.com/rakugoteam/AdvancedText)

## Rakugo Kits
- [Visual Novel](https://github.com/rakugoteam/VisualNovelKit)
- [Click & Point Adventures](https://github.com/rakugoteam/Adventure)
- [RPG](https://github.com/rakugoteam/rakugo-open-rpg)

## Roadmap
Project Roadmap : <https://github.com/rakugoteam/Rakugo/projects/1>

## FAQ:

**Q:** So it's about adding a dialogue system to the engine? </p>
**A:** Yes

**Q:** How does the project interact with the engine ? </p>
**A:** It is a singleton (autoload)

**Q:** Is it easy to use ?</p>
**A:** Yes

## Infos

If you want to help please write to us on our [Discord](https://discord.gg/K9gvjdg).

- Rakugo Team website: https://rakugoteam.github.io/

- [Godot icons](https://github.com/godotengine/godot-design/tree/master/engine/icons/optimized)

- icons from [game-icons.net](https://game-icons.net)

