defmodule WebSocketClient do
  use WebSockex
  require Logger

  def start_link(state) do
    url = Application.get_env(:ocpp_charger_nervers, :charger_system_url)
    Logger.debug("Starting websocket client to #{url}")

    WebSockex.start_link(url, __MODULE__, state, extra_headers: [{"Sec-Websocket-Protocol", "ocpp2.0"}])
  end

  def handle_frame({type, msg}, state) do
    Logger.debug "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    Logger.debug "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end
end
