defmodule RequestMock.Repo do
  use Ecto.Repo,
    otp_app: :request_mock,
    adapter: Ecto.Adapters.Postgres
end
