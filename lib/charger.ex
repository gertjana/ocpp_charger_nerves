defmodule OcppChargerNerves.Charger do
  use GenServer

  alias OcppModel.V20.Behaviours, as: B
  alias OcppModel.V20.EnumTypes, as: ET
  alias OcppModel.V20.Messages, as: M
  alias OcppModel.V20.FieldTypes, as: FT

  @behaviour B.Charger

  # Struct
  defstruct [serial: "", status: "Available", energy: 0.0, time: "00:00:00", connected: false]

  # GenServer clients

  def start_link(default_state) do
    GenServer.start_link(__MODULE__, default_state)
  end

  @spec handle([]) :: []
  def handle(message) do
    GenServer.call(__MODULE__, message)
  end

  # GenServer callbacks

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call([2, id, action, payload], _from, state) do
    response = case B.Charger.handle(__MODULE__, action, payload) do
                 {:ok, response_payload} -> [3, id, response_payload]
                 {:error, error, desc} ->         [4, id, Atom.to_string(error), desc, {}]
               end
    {:reply, response, state}
  end

  @impl GenServer
  def handle_cast([3, id, payload], state) do
    IO.puts "Received answer for id #{id}: #{inspect(payload)}"
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast([4, id, err, desc, det], state) do
    IO.puts "Received error for id #{id}: #{err}, #{desc}, #{det}"
    {:noreply, state}
  end


  # Charger callbacks

  @impl B.Charger
  def change_availability(req) do
    if ET.validate?(:operationalStatusEnumType, req.operationalStatus) do
       {:ok, %M.ChangeAvailabilityResponse{status: "Accepted",
                statusInfo: %FT.StatusInfoType{reasonCode: "charger is inoperative"}}}
    else
      {:error, :invalid_operational_status}
    end
  end

  @impl B.Charger
  def data_transfer(_req), do: {:ok, %M.DataTransferResponse{status: "Accepted"}}

  @impl B.Charger
  def unlock_connector(_req), do:
    {:ok, %M.UnlockConnectorResponse{status: "Unlocked",
                                     statusInfo: %FT.StatusInfoType{reasonCode: "cable unlocked"}}}


  @spec toggle_cable(%OcppChargerNerves.Charger{}) :: %OcppChargerNerves.Charger{}
  def toggle_cable(charger) do
    case {charger.connected, charger.status} do
      {false, _} -> charger
      {true, "Available"} -> %{charger | status: "Occupied"}
      {true, "Occupied"} -> %{charger | status: "Available"} # stop session
      _ -> charger
    end
  end

  @spec toggle_swipe(%OcppChargerNerves.Charger{}) :: %OcppChargerNerves.Charger{}
  def toggle_swipe(charger) do
    case {charger.connected, charger.status} do
      {false, _} -> charger
      {true, "Charging"} -> %{charger | status: "Occupied"}
      {true, "Occupied"} -> %{charger | status: "Charging"} # start session
      _ -> charger
    end
  end

  @spec toggle_connected(%OcppChargerNerves.Charger{}) :: %OcppChargerNerves.Charger{}
  def toggle_connected(charger) do
    %{charger | connected: !charger.connected}
  end
end
