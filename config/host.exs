use Mix.Config

config :ocpp_charger_nerves, :viewport, %{
  name: :main_viewport,
  default_scene: {OcppChargerNerves.Scene.ChargerScene, nil},
  size: {256, 256},
  opts: [scale: 2.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "Nerves OCPP Charger"]
    }
  ]
}
