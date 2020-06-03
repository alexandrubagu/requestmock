defmodule RequestMock.Repo do
  use Ecto.Repo,
    otp_app: :requestmock,
    adapter: Ecto.Adapters.Postgres
end
