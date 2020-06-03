defmodule RequestMock.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      RequestMock.Repo,
      # Start the Telemetry supervisor
      RequestMock.Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: RequestMock.PubSub},
      # Start the Endpoint (http/https)
      RequestMock.Web.Endpoint
      # Start a worker by calling: RequestMock.Worker.start_link(arg)
      # {RequestMock.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RequestMock.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RequestMock.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end