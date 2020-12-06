use Mix.Config

config :ocpp_charger_nerves, :viewport, %{
  name: :main_viewport,
  default_scene: {OcppChargerNerves.Scene.ChargerScene, nil},
  # Match these to your display
  size: {128, 128},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Nerves.Waveshare,
      opts: [
        # only :sku138191 at the moment
        device_sku: :sku138191,
        # :color18bit (default) | :color16bit | :color12bit
        color_depth: :color18bit,
        # :rgb | :bgr (default)
        color_order: :bgr,
        # :l2r_u2d | :l2r_d2u | :r2l_u2d | :r2l_d2u | :u2d_l2r | :u2d_r2l (default) | :d2u_l2r | :d2u_r2l
        scan_dir: :u2d_r2l,
        # :ppm | :rgb24 (default) | :rgb565 | :mono | :mono_column_scan
        capture_format: :rgb24,
        refresh_interval: 50,
        spi_speed_hz: 20_000_000,
        # remapping input keys
        input_mappings: %{}
      ],
      name: :waveshare
    }
  ]
}
