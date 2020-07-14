# defmodule Mockapp.Response.Manager do
#   @moduledoc false

#   use GenServer
#   require Logger

#   alias RequestMock.Responses.Response

#   @schedulers_online System.schedulers_online() * 5

#   def start_link(_) do
#     GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
#   end

#   def init(:ok) do
#     {:ok, []}
#   end

#   def handle_cast({:multi_delete, mocks}, state) do
#     stream =
#       Task.Supervisor.async_stream_nolink(
#         Mockapp.Task.Supervisor,
#         mocks,
#         fn mock ->
#           delete(mock)
#         end,
#         max_concurrency: @schedulers_online
#       )

#     Stream.run(stream)
#     {:noreply, state}
#   end

#   #################
#   # End GenServer #
#   #################

#   @doc """
#   Read mock from disk
#   """
#   def read(uuid) do
#     task =
#       Task.Supervisor.async_nolink(Mockapp.Task.Supervisor, fn ->
#         with {:ok, _} <- Ecto.UUID.cast(uuid),
#              path <- absolute_file_path(uuid),
#              true <- File.exists?(path) do
#           Logger.info("Start reading response #{uuid} ...")

#           case File.open(path, [:read, :utf8], &read_from_disk/1) do
#             {:ok, mock} ->
#               Logger.info("End reading response #{uuid} ...")
#               mock

#             {:error, reason} ->
#               Logger.info("Can't read response #{uuid} - reason #{inspect(reason)} ...")
#               :error
#           end
#         else
#           _ -> :error
#         end
#       end)

#     Task.await(task)
#   end

#   @doc """
#   Delete mock from disk
#   """
#   def delete(uuid) do
#     task =
#       Task.Supervisor.async_nolink(Mockapp.Task.Supervisor, fn ->
#         with {:ok, _} <- Ecto.UUID.cast(uuid),
#              path <- absolute_file_path(uuid),
#              true <- File.exists?(path),
#              {:ok, _} <- File.rm_rf(path) do
#           :ok
#         else
#           _ -> :error
#         end
#       end)

#     Task.await(task)
#   end

#   defp read_from_disk(file) do
#     attrs = %{
#       status: IO.read(file, :line),
#       http_status: IO.read(file, :line),
#       content_type: IO.read(file, :line),
#       tags: IO.read(file, :line),
#       headers: IO.read(file, :line),
#       body: IO.read(file, :all)
#     }

#     Response.validate(attrs)
#   end

# end
