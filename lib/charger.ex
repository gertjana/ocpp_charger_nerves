defmodule OcppChargerNerves.Charger do
  defstruct [serial: "", status: "Available", energy: 0.0, time: "00:00:00", connected: false]


  @spec toggle_cable(%OcppChargerNerves.Charger{}) :: %OcppChargerNerves.Charger{}
  def toggle_cable(charger) do
    case {charger.connected, charger.status} do
      {false, _} -> charger
      {true, "Available"} -> %{charger | status: "Occupied"}
      {true, "Occupied"} -> %{charger | status: "Available"}
      _ -> charger
    end
  end

  @spec toggle_swipe(%OcppChargerNerves.Charger{}) :: %OcppChargerNerves.Charger{}
  def toggle_swipe(charger) do
    case {charger.connected, charger.status} do
      {false, _} -> charger
      {true, "Charging"} -> %{charger | status: "Occupied"}
      {true, "Occupied"} -> %{charger | status: "Charging"}
      _ -> charger
    end
  end

  @spec toggle_connected(%OcppChargerNerves.Charger{}) :: %OcppChargerNerves.Charger{}
  def toggle_connected(charger) do
    %{charger | connected: !charger.connected}
  end
end
