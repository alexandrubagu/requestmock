defmodule Database.Response.Manager do
  @moduledoc false

  use GenServer
  import Ecto.Query
  require Logger

  alias Database.Schema.AnonymousResponse
  alias RequestMock.Repo

  @timer 2 * 60 * 60 * 1000
  @chunk_limit 500
  @select_limit 10_000
  @schedulers_online System.schedulers_online() * 2

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    schedule_cleanup()
    {:ok, []}
  end

  def schedule_cleanup do
    Process.send_after(self(), :cleanup, @timer)
  end

  def persist(pid, uuid) do
    GenServer.call(pid, {:persist, uuid})
  end

  def handle_cast({:persist, uuid}, state) do
    changeset =
      AnonymousResponse.changeset(
        %AnonymousResponse{},
        %{:uuid => uuid}
      )

    Logger.info("Insert #{uuid} into database ...")
    Repo.insert(changeset)

    {:noreply, state}
  end

  def handle_cast({:multi_delete, mocks}, state) do
    query =
      from r in AnonymousResponse,
        where: r.uuid in ^mocks

    Repo.delete_all(query)

    {:noreply, state}
  end

  def handle_info(:cleanup, state) do
    chuncked_mocks =
      get_all_anonymous()
      |> Enum.chunk(@chunk_limit, @chunk_limit, [])

    stream =
      Task.Supervisor.async_stream_nolink(
        Database.Task.Supervisor,
        chuncked_mocks,
        fn mocks ->
          GenServer.cast(Mockapp.Response.Manager, {:multi_delete, mocks})
          GenServer.cast(Mockapp.Request.Manager, {:multi_delete, mocks})
          GenServer.cast(Database.Response.Manager, {:multi_delete, mocks})
          Process.sleep(100)
        end,
        max_concurrency: @schedulers_online
      )

    Stream.run(stream)

    schedule_cleanup()

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def get_all_anonymous do
    datetime =
      Timex.now()
      |> Timex.shift(days: -2)

    query =
      from r in AnonymousResponse,
        where: r.inserted_at < ^datetime,
        select: r.uuid,
        limit: @select_limit

    Repo.all(query)
  end
end
