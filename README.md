# 🚦 SignalBus

![Godot Engine](https://img.shields.io/badge/Made%20With-Godot%204-478cbf?style=for-the-badge&logo=godotengine&logoColor=white)
![Godot v4.3](https://img.shields.io/badge/Godot-v4.4-478cbf?style=for-the-badge&logo=godotengine&logoColor=white)
![Godot Asset Library](https://img.shields.io/badge/Available%20on-Godot%20Asset%20Library-blue?style=for-the-badge)

**SignalBus** is **Godot** editor plugin that enables the creation of global signals! Global signals, unlike traditional do not belong to any specific class. Instead, they are globally accessible from
anywhere in the engine using the **SignalBus** singleton, enabling users to connect objects far more flexibly. 

---

## ✨ Features
✔ **User Friendly** – Create and manage signals directly from the editor.  
✔ **Decoupled Architecture** – Reduce dependencies between nodes and scripts.  
✔ **Flexible Signal Handling** – Emit and connect to signals across the entire project.  
✔ **Lightweight** – Easily added to any project with no other requirements.  

---

## 🛠 When to Use SignalBus
✅ **Use SignalBus when:**
- Several unrelated classes define the same signal.
- Dealing with complex node hierarchies.
- Global events that need to be accessed by any object.

⚠️ **Note:** SignalBus **does not replace** Godot’s built-in signal system. For simple, node-specific signals, use the default signal mechanism.

---

## 📥 Installation
### **Option 1: Install from the Godot Asset Library** (Recommended)  
1️⃣ Open the **Godot Asset Library** from the Godot Editor.  
2️⃣ Search for **SignalBus** and click **Download**.  
3️⃣ Enable the plugin via **`Project Settings > Plugins`**.  

### **Option 2: Manual Installation**  
1️⃣ **Download or Clone** the repository.  
2️⃣ Copy the **`addons/signal_bus/`** folder into your **Godot project's `addons/`** directory.  
3️⃣ In **Godot**, go to **`Project Settings > Plugins`**, find **`SignalBus`**, and **enable** it.  

---

## 📝 License
This plugin is open-source and licensed under **MIT License**. Feel free to use, modify, and distribute it as needed.

📢 Feedback is welcome! 🚀
