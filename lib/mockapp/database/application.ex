# defmodule Database.Application do
#   @moduledoc false

#   use Application

#   def start(_type, _args) do
#     import Supervisor.Spec, warn: false

#     children = [
#       supervisor(RequestMock.Repo, []),
#       supervisor(Task.Supervisor, [[name: Database.Task.Supervisor, restart: :transient]]),
#       worker(Database.Response.Manager, [])
#     ]

#     opts = [strategy: :one_for_one, name: Database.Supervisor]
#     Supervisor.start_link(children, opts)
#   end
# end
