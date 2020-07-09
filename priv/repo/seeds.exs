defmodule Seeds do
  use GenServer

  @opts [
    max_concurrency: System.schedulers_online() * 2 + 2
  ]

  def run do
    pid = Process.whereis(Database.Response.Manager)

    1..3_000_000
    |> Task.async_stream(
      fn _ ->
        GenServer.call(pid, {:persist, Ecto.UUID.generate()})
      end,
      @opts
    )
    |> Stream.run()
  end
end

Seeds.run()
