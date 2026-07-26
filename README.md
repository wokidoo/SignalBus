# 🚦 SignalBus

**SignalBus** is a **Godot** editor plugin that enables the creation of global signals! Global signals may be emitted from and/or connected to any script in your project. 

## ✨ Features
### SignalBus (Autoload)
A core singleton script that manages the addition, modification, removal, and emitting of global signals. After registering a global signal, it can be emitted or connected to from any script in the project.

## 🛠 When to Use
### ✅ Use SignalBus when
- Several unrelated classes must define and emit the same signal.
- You are dealing with complex Node or SceneTree hierarchies.
- You need global events that can be accessed by any object.

## 💻 Quick Start Example
1. After enabling the plugin, select the **SignalBus** tab in Project Settings.  
2. Input the string `game_over` in the **Add New Global Signal** field.  
3. Press **Enter** or select the **+ Add** button.
4. Connect and emit the signal from anywhere :)

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
