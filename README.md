# 🚦 SignalBus

**SignalBus** is a **Godot** editor plugin that enables the creation of global signals! Global signals may be emitted from and/or connected to any script in your project. 

## Table of Contents
- [Features](#-features)
- [When to Use SignalBus](#-when-to-use)
- [Installation](#-installation)
- [Quick Start Example](#-quick-start-example)
- [Disclaimer](#-disclaimer)
- [License](#-license)

## ✨ Features
### SignalBus (Autoload)
A core singleton script that manages the addition, modification, removal, and emitting of global signals. Global signals are saved directly in your project settings.

## 🛠 When to Use
### ✅ Use SignalBus when
- Several unrelated classes must define and emit the same signal.
- You are dealing with complex Node or SceneTree hierarchies.
- You need global events that can be accessed by any object.

## 💻 Quick Start Example
The following example assumes that you have defined a global signal `game_over`. If you have not done so you can define a global signal by...
### Option 1: Project Settings
1️⃣ After enabling the plugin, select the **SignalBus** tab in Project Settings.  
2️⃣ Input the name `game_over` in the **Add New Global Signal** field.  
3️⃣ Press **Enter** or select the **+ Add** button.

<img width="50%" alt="image" src="https://github.com/user-attachments/assets/b9fe7a3c-0b1d-4139-9f9d-8cb8f33f73b2" />

### Option 2: Scripting
Add the following line to a script to add the global signal
```
SignalBus.add_global_signal("game_over")
```
### Example
After making sure that the `game_over` global signal is registered in **SignalBus**...
```
# Emitting a signal
SignalBus.emit_signal("game_over")

# Listening to a signal
SignalBus.connect("game_over", Callable(self, "_on_game_over"))

func _on_game_over():
    print("Game over!")
```
## 🛑 Disclaimers
**SignalBus** does not replace Godot’s built-in signal system. Most implementations do not require global signals.

Although the plugin make's use of [**Gut**](https://github.com/bitwes/Gut) for testing purposes, it is not a mandatory dependency and will not impact SignalBus' functionatliy if it is not included.

## 📝 License
This plugin is open-source and licensed under **MIT License**. Feel free to use, modify, and distribute it as needed.

📢 Feedback is welcome! 🚀
