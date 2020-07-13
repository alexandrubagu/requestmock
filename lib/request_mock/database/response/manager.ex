# defmodule Database.Response.Manager do
#   @moduledoc false

#   use GenServer
#   import Ecto.Query
#   require Logger

#   alias Database.Schema.AnonymousResponse
#   alias RequestMock.Repo

#   @timer 2 * 60 * 60 * 1000
#   @chunk_limit 500
#   @select_limit 10_000
#   @schedulers_online System.schedulers_online() * 2

#   def start_link do
#     GenServer.start_link(__MODULE__, [], name: __MODULE__)
#   end

#   def init(_) do
#     schedule_cleanup()
#     {:ok, []}
#   end

#   def schedule_cleanup do
#     Process.send_after(self(), :cleanup, @timer)
#   end

#   def handle_info(:cleanup, state) do
#     chunked_mocks = Enum.chunk_every(get_all_anonymous(), @chunk_limit, @chunk_limit, [])

#     stream =
#       Task.Supervisor.async_stream_nolink(
#         Database.Task.Supervisor,
#         chunked_mocks,
#         fn mocks ->
#           GenServer.cast(Mockapp.Response.Manager, {:multi_delete, mocks})
#           GenServer.cast(Mockapp.Request.Manager, {:multi_delete, mocks})
#           GenServer.cast(Database.Response.Manager, {:multi_delete, mocks})
#           Process.sleep(100)
#         end,
#         max_concurrency: @schedulers_online
#       )

#     Stream.run(stream)

#     schedule_cleanup()

#     {:noreply, state}
#   end

#   def handle_info(_msg, state) do
#     {:noreply, state}
#   end
# end
