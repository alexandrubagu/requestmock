defmodule RequestMock.Requests.Request do
  @moduledoc false

  use RequestMock.Schema

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
end
