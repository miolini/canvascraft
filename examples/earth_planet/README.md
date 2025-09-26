# EarthPlanet example

This Mix project demonstrates using CanvasCraft as a library. It renders a procedural Earth-like planet and saves it as WEBP.

Run:

```
cd examples/earth_planet
mix deps.get
iex -S mix
iex> EarthPlanet.render_and_save("earth.webp", size: 256)
:ok
```
