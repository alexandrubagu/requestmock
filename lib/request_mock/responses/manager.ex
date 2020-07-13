defmodule Mockapp.Response.Manager do
  @moduledoc false

  use GenServer
  require Logger

  @schedulers_online System.schedulers_online() * 5

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, []}
  end

  def handle_cast({:multi_delete, mocks}, state) do
    stream =
      Task.Supervisor.async_stream_nolink(
        Mockapp.Task.Supervisor,
        mocks,
        fn mock ->
          delete(mock)
        end,
        max_concurrency: @schedulers_online
      )

    Stream.run(stream)
    {:noreply, state}
  end

  #################
  # End GenServer #
  #################

  @doc """
  Create mock to disk and database
  """
  def create(params) do
    case Mockapp.Response.Entity.validate(params) do
      :ok ->
        task =
          Task.Supervisor.async_nolink(Mockapp.Task.Supervisor, fn ->
            with uuid <- Ecto.UUID.generate(),
                 {:ok, _} <- persist_to_disk(uuid, params),
                 :ok <- GenServer.cast(Database.Response.Manager, {:persist, uuid}) do
              {:ok, uuid}
            else
              _ -> :error
            end
          end)

        Task.await(task)

      _ ->
        :error
    end
  end

  @doc """
  Read mock from disk
  """
  def read(uuid) do
    task =
      Task.Supervisor.async_nolink(Mockapp.Task.Supervisor, fn ->
        with {:ok, _} <- Ecto.UUID.cast(uuid),
             path <- absolute_file_path(uuid),
             true <- File.exists?(path) do
          Logger.info("Start reading response #{uuid} ...")

          case File.open(path, [:read, :utf8], &read_from_disk/1) do
            {:ok, mock} ->
              Logger.info("End reading response #{uuid} ...")
              mock

            {:error, reason} ->
              Logger.info("Can't read response #{uuid} - reason #{inspect(reason)} ...")
              :error
          end
        else
          _ -> :error
        end
      end)

    Task.await(task)
  end

  @doc """
  Delete mock from disk
  """
  def delete(uuid) do
    task =
      Task.Supervisor.async_nolink(Mockapp.Task.Supervisor, fn ->
        with {:ok, _} <- Ecto.UUID.cast(uuid),
             path <- absolute_file_path(uuid),
             true <- File.exists?(path),
             {:ok, _} <- File.rm_rf(path) do
          :ok
        else
          _ -> :error
        end
      end)

    Task.await(task)
  end

  @doc """
  Switch mock on/off
  """
  def switch(uuid, state) do
    task =
      Task.Supervisor.async_nolink(Mockapp.Task.Supervisor, fn ->
        path = absolute_file_path(uuid)

        File.open(path, [:write, :read], fn file ->
          case state do
            "true" -> :file.pwrite(file, 0, '1')
            "false" -> :file.pwrite(file, 0, '0')
            _ -> :error
          end
        end)
      end)

    Task.await(task)
  end

  @doc """
  Check if mock exists
  """
  def exists?(uuid) do
    with {:ok, _} <- Ecto.UUID.cast(uuid),
         file <- absolute_file_path(uuid) do
      File.exists?(file)
    else
      _ -> false
    end
  end

  @doc """
  Get response absolute path
  """
  def absolute_file_path(uuid) do
    mocks_dir =
      :mockapp
      |> Application.get_env(:responses)
      |> Keyword.fetch!(:anonymous)

    Enum.join([mocks_dir, uuid], "/")
  end

  defp read_from_disk(file) do
    # response struct
    response = struct(Mockapp.Response.Entity)

    # read status
    status = parse_file(file, :line, 0, &Mockapp.Response.Entity.parse_number(&1))

    # read http_status
    http_status = parse_file(file, :line, 404, &Mockapp.Response.Entity.parse_number(&1))

    # read content-type
    content_type = parse_file(file, :line, "text/plain", &String.trim(&1))

    # read tags
    tags = parse_file(file, :line, [], &Mockapp.Response.Entity.parse_json(&1))

    # read headers
    headers = parse_file(file, :line, [], &Mockapp.Response.Entity.parse_json(&1))

    # read body
    body = parse_file(file, :all, "", &String.trim(&1))

    # update response
    %{
      response
      | status: status,
        http_status: http_status,
        content_type: content_type,
        tags: tags,
        headers: headers,
        body: body
    }
  end

  defp parse_file(file, line_or_chars, default, func)
       when line_or_chars in [:line, :all] and is_function(func) do
    case IO.read(file, line_or_chars) do
      :eof -> default
      value -> func.(value)
    end
  end

  defp persist_to_disk(response_id, params) do
    with path <- absolute_file_path(response_id),
         :ok <- File.touch(path) do
      Logger.info("Creating #{path} ...")
      Logger.info("[#{response_id}] Start writing response ...")

      File.open(path, [:write, :utf8], fn file ->
        write_response(file, response_id, params)
      end)

      Logger.info("[#{response_id}] End writing response ...")
      {:ok, response_id}
    else
      error ->
        Logger.info("Can't create file: #{absolute_file_path(response_id)}")
        {:error, error}
    end
  end

  defp write_response(file, response_id, params) do
    Logger.info("[#{response_id}] Writing response status ...")
    IO.write(file, "1\n")

    Logger.info("[#{response_id}] Writing response http status ...")
    IO.write(file, params["status"] <> "\n")

    Logger.info("[#{response_id}] Writing response content_type ...")
    IO.write(file, params["content-type"] <> "\n")

    Logger.info("[#{response_id}] Writing response tags ...")
    IO.write(file, Jason.encode!(String.split(params["tags"], ",")) <> "\n")

    Logger.info("[#{response_id}] Writing response headers ...")
    headers = params["headers"]

    pair_headers =
      Enum.zip(
        Map.fetch!(headers, "name"),
        Map.fetch!(headers, "value")
      )

    IO.write(file, Jason.encode!(Enum.into(pair_headers, %{})) <> "\n")

    Logger.info("[#{response_id}] Writing response body ...")
    IO.write(file, params["body"] <> "\n")
  end
end
