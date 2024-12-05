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

### Adding Signals
To define a new signal and add it to the SignalBus:
```gdscript
SignalBus.add_signal_to_bus("example_signal")
