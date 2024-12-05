# SignalBus - Plugin for Godot

SignalBus is a Godot plugin that provides a centralized signal management system, helping you decouple signals from specific scripts and simplifying one-to-many or many-to-many communication between nodes.

## Features
- Manage signals globally with a centralized signal bus.
- Decouple signals from specific nodes or scripts.
- Emit and connect to signals across your project using a single system.
- Useful for "one-to-many" or "many-to-many" communication.

## When to Use SignalBus
- Use SignalBus when signals benefit from being decoupled from specific scripts or nodes.
- Ideal for scenarios where multiple nodes need to emit or connect to the same signal, such as event handling or game state updates.
- **Note:** SignalBus is not a replacement for all signals in Godot. For simple, node-specific signals, continue using Godot's built-in signal system.

## Installation
1. Download or clone the repository.
2. Copy the `addons/signal_bus/` folder into your Godot project's `addons/` directory.
3. In the Godot editor, go to `Project Settings > Plugins`, find the `SignalBus` plugin, and enable it.

## Usage

### Adding Bus Signals
To define a new signal and add it to the SignalBus:
```gdscript
SignalBus.add_signal_to_bus("on_player_hit", [
        {"name": "damage", "type": TYPE_INT},
        {"name": "source", "type": TYPE_OBJECT},
    ])
```

### Connect Bus Signals
To connect a script method to a signal in SignalBus
```gdscript
  func _ready():
    SignalBus.connect("on_bus_signal_added", connect_new_signal)

  func connect_new_signal(name: String):
    # Looking for 'on_player_attack' signal
    if name == "on_player_attack":
      SignalBus.connect("on_player_attack", player_attacking)

  # Called whenever 'on_player_attack' signal is emitted
  func player_attacking():
    print("player is attacking!")
```

### Emit Bus Signals
To emit a signal in the SignalBus:
```gdscript
SignalBus.emit_signal("on_player_hit")
```

### Removing Bus Signals
To remove an existing signal from the SignalBus:
```gdscript
SignalBus.remove_signal_from_bus("on_player_hit")
```
