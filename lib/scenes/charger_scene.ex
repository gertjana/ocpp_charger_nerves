defmodule OcppChargerNerves.Scene.ChargerScene do
  use Scenic.Scene
  alias Scenic.Graph
  alias OcppChargerNerves.Charger, as: Charger
  import Scenic.Primitives

  @target System.get_env("MIX_TARGET") || "host"

  @y_div 17
  @x_wid 128
  #@y_wid 128

  @update_interval 1000
  @update_energy 0.003  # energy charged/second for a 11Kwh

  @spec build_graph(String.t(), String.t(), float(), String.t(), boolean()) :: Scenic.Graph.t()
  def build_graph(serial, status, energy, time, connected) do
    connect_icon = case connected do
      true -> "v"
      false -> "x"
    end
    Graph.build(font_size: 16, font: :roboto_mono)
        |> group(
          fn g ->
            g |> text("OCPP20 Charger #{connect_icon}")
          end,
          t: {3, 10}
        )
        |> group(
          fn g ->
            g
            |> line({{0,@y_div}, {@x_wid, @y_div}}, stroke: {1, :white})
            # |> line({{@x_div,@y_div}, {@x_div,@y_wid}}, stroke: {1, :white})
          end
        )
        |> group(
          fn g ->
            g
            |> text("Serial #{serial}", translate: {0,12})
            |> text("State  #{status}", translate: {0,24})
            |> text("Energy #{Float.round(energy, 2)} kWh",  translate: {0,36})
            |> text("Time   #{time}", translate: {0,48})
          end,
          t: {3,20}
        )
  end

  def init(_, _opts) do
    charger = %Charger{serial: "NC-0001", status: "Available", energy: 0.0, time: "00:00:00", connected: false}

    graph = build_graph(charger.serial, charger.status, charger.energy, charger.time, charger.connected)
              |> Graph.modify(:device_list, &update_opts(&1, hidden: @target == "host"))

    Process.send_after(self(), :update, 100)

    {:ok, {charger, graph}, push: graph}
  end

  def handle_input(input, _context, state) do
    {charger, _graph} = state
    # 1 = Cable insert # 2 swipe
    new_charger = case input do
      {:key, {"1", :press, _}}        -> Charger.toggle_cable(charger)
      {:key, {:button_1, :press, _}}  -> Charger.toggle_cable(charger)
      {:key, {"2", :press, _}}        -> Charger.toggle_swipe(charger)
      {:key, {:button_2, :press, _}}  -> Charger.toggle_swipe(charger)
      {:key, {"3", :press, _}}        -> Charger.toggle_connected(charger)
      {:key, {:button_3, :press, _}}  -> Charger.toggle_connected(charger)
      _ -> charger
    end

    new_graph = build_graph(new_charger.serial, new_charger.status, new_charger.energy, new_charger.time, new_charger.connected)
    {:noreply, {new_charger, new_graph}, push: new_graph}
  end

  def handle_info(:update, state) do
    Process.send_after(self(), :update, @update_interval)

    {charger, _graph} = state

    new_charger = case charger.status do
      "Charging" -> %{charger | energy: add_energy(charger, @update_energy), time: add_time(charger, @update_interval)  }
      "Available" -> %{charger | energy: 0.0, time: "00:00:00"}
      _ -> charger
    end

    new_graph = build_graph(new_charger.serial, new_charger.status, new_charger.energy, new_charger.time, new_charger.connected)

    {:noreply, {new_charger, new_graph}, push: new_graph}
  end

  defp add_energy(charger, value) do
    charger.energy + value
  end

  defp add_time(charger, value) do
    [head|_] = Time.from_iso8601!(charger.time) |> Time.add(value, :millisecond) |> Time.to_iso8601() |> String.split(".")
    head
  end
end
