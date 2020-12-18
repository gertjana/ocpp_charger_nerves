defmodule OcppChargerNerves.Handler do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def start_link(default_state) do
    GenServer.start_link(__MODULE__, default_state, name: :handler)
  end

  def jsonToTerm(message) do
    GenServer.call(__MODULE__, :json_to_term, message)
  end

end
