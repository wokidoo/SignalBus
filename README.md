# 🚦 SignalBus

![Godot Engine](https://img.shields.io/badge/Made%20With-Godot%204-478cbf?style=for-the-badge&logo=godotengine&logoColor=white)
![Godot v4.4](https://img.shields.io/badge/Godot-v4.4-478cbf?style=for-the-badge&logo=godotengine&logoColor=white)
![Godot Asset Library](https://img.shields.io/badge/Available%20on-Godot%20Asset%20Library-blue?style=for-the-badge)

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
A core singleton script that manages the addition, modification, removal, and emitting of global signals. Global signals are saved directly in your project settings, allowing for complete portability across devices.
### SignalBusSubscriber 
A node that allows a global signal to connect directly to a chosen callable (method) in the parent node, with no scripting required.

## 🛠 When to Use
### ✅ Use SignalBus when
- Several unrelated classes must define and emit the same signal.
- You are dealing with complex Node or SceneTree hierarchies.
- You need global events that can be accessed by any object.

## 📥 Installation
### **Option 1: Install from the Godot Asset Library** (Recommended)  
1️⃣ Open the **Godot Asset Library** from the Godot Editor.  
2️⃣ Search for **SignalBus** and click **Download**.  
3️⃣ Enable the plugin via **`Project Settings > Plugins`**.  

### **Option 2: Manual Installation**  
1️⃣ **Download or Clone** the repository.  
2️⃣ Copy the **`addons/signal_bus/`** folder into your **Godot project's `addons/`** directory.  
3️⃣ Enable the plugin via **`Project Settings > Plugins`**. 

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
