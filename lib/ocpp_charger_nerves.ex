defmodule OcppChargerNerves.Application do
  @moduledoc false

  alias OcppChargerNerves.Charger

  @target Mix.target()

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: OcppChargerNerves.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  def children("host") do
    main_viewport_config = Application.get_env(:ocpp_charger_nerves, :viewport)

    [
      {Scenic, viewports: [main_viewport_config]},
      {Charger, [{:serial, "NC-0001"}]}
    ]
  end

  def children(_target) do
    main_viewport_config = Application.get_env(:ocpp_charger_nerves, :viewport)

    [
      {Scenic, viewports: [main_viewport_config]}
    ]
  end
end
