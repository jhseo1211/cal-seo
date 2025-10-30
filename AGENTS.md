# Repository Guidelines

## Project Structure & Module Organization
The Godot project root is this repository; launch `project.godot` from the editor to load all settings. `Calculator.tscn` is the only scene and instantiates the UI plus the attached `Calculator.gd` script, which handles input parsing and button wiring. Asset files such as `icon.svg` live beside the scene to keep resource paths simple. Store any new scripts under `res://` (this folder maps to the repo root) and group related scenes in subfolders to keep the Godot FileSystem panel tidy.

## Build, Test, and Development Commands
Use Godot 4.5 tooling, matching the `config/features` entry. Typical workflows:
```shell
godot4 --editor project.godot   # open the editor UI
godot4 --path .                  # run the project with the current main scene
godot4 --headless --path .       # launch without a window for CI smoke checks
```
Update the main scene via Project Settings if you introduce additional entry points.

## Coding Style & Naming Conventions
Follow Godot's GDScript style: tab-based indentation, single blank lines between functions, and snake_case for variables, functions, and node paths (e.g., `input_a`, `_on_op_pressed`). Use explicit type hints for exported or onready variables when practical. Keep user-facing strings localized-friendly; the existing UI text is Korean, so reuse `tr()` if you add new labels.

## Testing Guidelines
Automated tests are not yet configured. For new features, add scene-specific assertions via Godot's built-in unit testing or a GUT suite placed under `res://tests/`, and run them headlessly (`godot4 --headless --run res://tests/test_runner.gd`). At minimum, validate arithmetic and error states manually in the editor before submitting changes.

## Commit & Pull Request Guidelines
Commit messages currently use short, imperative summaries, sometimes prefixed with an emoji for context. Keep the subject under 72 characters and describe intent, not implementation. For pull requests, include: a concise summary of behavior changes, reproduction or test steps, and screenshots or short clips when UI is affected. Link any tracked issues and note follow-up work when applicable.

## Scene & UI Tips
UI nodes are arranged in a `MarginContainer > VBoxContainer` hierarchy. When extending the interface, prefer container-based layouts to keep scaling responsive, and expose new controls through onready properties in `Calculator.gd` to centralize signal wiring.
