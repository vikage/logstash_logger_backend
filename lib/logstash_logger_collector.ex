defmodule LogstashLoggerCollector do
  @log_period 60_000
  use GenServer
  require Logger

  def start_link(config_name) do
    name = process_name(config_name)
    GenServer.start_link(__MODULE__, [config_name], name: name)
  end

  @impl true
  def init([config_name]) do
    Logger.info("#{__MODULE__} with name #{config_name} start at #{inspect(self())}")

    env = Application.get_env(:logger, config_name, [])
    url = Keyword.get(env, :url)
    username = Keyword.get(env, :username)
    password = Keyword.get(env, :password)
    batch_size = Keyword.get(env, :batch_size) || 100

    schedule_send_log_period()

    {:ok,
     %{messages: [], url: url, username: username, password: password, batch_size: batch_size}}
  end

  def handle_msg(config_name, msg) do
    name = process_name(config_name)
    pid = Process.whereis(name)
    GenServer.cast(pid, {:handle_msg, msg})
  end

  @impl true
  def handle_cast({:handle_msg, msg}, %{messages: messages, batch_size: batch_size} = state) do
    messages = [msg | messages]

    if Enum.count(messages) >= batch_size do
      Process.send(self(), :send_msg, [])
    end

    {:noreply, %{state | messages: messages}}
  end

  @impl true
  def handle_info(
        :send_msg,
        %{
          messages: messages,
          url: url,
          username: username,
          password: password,
          batch_size: batch_size
        } = state
      ) do
    logs = Enum.take(messages, batch_size)
    auth_body = Base.encode64("#{username}:#{password}")
    auth = "Basic #{auth_body}"
    body_data = Poison.encode!(logs)

    case HTTPoison.post(url, body_data, [
           {"Content-Type", "application/json"},
           {"Authorization", auth}
         ]) do
      {:ok, _} ->
        remain = Enum.drop(messages, batch_size)
        {:noreply, %{state | messages: remain}}

      {:error, reason} ->
        :io.format("Send log to ELK error #{inspect(reason)}")
        {:noreply, %{state | messages: messages}}
    end
  end

  def handle_info(:time_to_send, state) do
    Process.send(self(), :send_msg, [])
    schedule_send_log_period()
    {:noreply, state}
  end

  defp schedule_send_log_period() do
    Process.send_after(self(), :time_to_send, @log_period)
  end

  defp process_name(config_name) do
    String.to_atom("#{__MODULE__}_#{config_name}")
  end
end
