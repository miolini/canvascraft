# KitchenSink example

Demonstrates CanvasCraft DSL: layout, shapes, gradients, antialiasing, text placeholders, UI widgets.

Run:

```
cd examples/kitchensink
mix deps.get
env CANVAS_CRAFT_ENABLE_NIF=1 mix run -e 'KitchenSink.render("kitchen.webp")'
```
