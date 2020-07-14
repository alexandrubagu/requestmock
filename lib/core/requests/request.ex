defmodule RequestMock.Core.Requests.Request do
  @moduledoc false

  use RequestMock.Schema

  @required ~w(datetime ip method content_type user_agent path body_params query_string)a
  embedded_schema do
    field :datetime, :naive_datetime
    field :ip, :string
    field :method, :string
    field :content_type, :string
    field :user_agent, :string
    field :path, :string
    field :body_params, :map
    field :query_string, :string
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, @required)
    |> validate_required(@required)
  end
end
