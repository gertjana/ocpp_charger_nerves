defmodule OcppChargerNerves.Application do
  @moduledoc false

  alias OcppChargerNerves.Charger
  alias OcppChargerNerves.Handler
  alias OcppChargerNerves.WebSocketClient

  @target Mix.target()

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: OcppChargerNerves.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  def children("host") do
    main_viewport_config = Application.get_env(:ocpp_charger_nerves, :viewport)

    [
      {Charger, [{:serial, Application.get_env(:ocpp_charger_nerves, :charger_serial)}]},
      {Handler, []},
      {WebSocketClient, [{:url, Application.get_env(:ocpp_charger_nerves, :charger_system_url)}]},
      {Scenic, viewports: [main_viewport_config]}
    ]
  end

  def children(_target) do
    main_viewport_config = Application.get_env(:ocpp_charger_nerves, :viewport)

    [
      {Charger, [{:serial, Application.get_env(:ocpp_charger_nerves, :charger_serial)}]},
      {Handler, []},
      {WebSocketClient, [{:url, Application.get_env(:ocpp_charger_nerves, :charger_system_url)}]},
      {Scenic, viewports: [main_viewport_config]}
    ]
  end
end
