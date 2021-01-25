defmodule LogstashLoggerBackend do
  @behaviour :gen_event

  @impl true
  def init({__MODULE__, name}) do
    LogstashLoggerCollector.start_link(name)
    {:ok, configure(name, [], %{})}
  end

  @impl true
  def handle_call({:configure, opts}, %{name: name} = state) do
    {:ok, :ok, configure(name, opts, state)}
  end

  defp configure(name, opts, _) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    level = Keyword.get(opts, :level)
    url = Keyword.get(opts, :url)
    username = Keyword.get(opts, :username)
    password = Keyword.get(opts, :password)
    more_info = Keyword.get(env, :more_info) || %{}
    metadata = Keyword.get(env, :metadata) || []

    %{
      name: name,
      level: level,
      url: url,
      username: username,
      password: password,
      more_info: more_info,
      metadata: metadata
    }
  end

  @impl true
  def handle_event({level, _gl, {Logger, msg, timestamp, metadata}}, %{level: min_level} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      log_event(level, msg, timestamp, metadata, state)
    end

    {:ok, state}
  end

  defp log_event(level, msg, _ts, md, %{
         name: name,
         more_info: more_info,
         metadata: fields
       }) do
    body = %{
      "@timestamp" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "message" => to_string(msg),
      "level" => to_string(level)
    }

    body = Map.merge(body, more_info)
    final_body = add_content_from_metadata(body, md, fields)
    LogstashLoggerCollector.handle_msg(name, final_body)
  end

  defp add_content_from_metadata(body, md, fields) do
    Enum.reduce(fields, body, fn field, acc ->
      value = Keyword.get(md, field)

      if value == nil do
        acc
      else
        Map.put(acc, field, value)
      end
    end)
  end
end
