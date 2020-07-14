defmodule RequestMock.Core.Responses.Response do
  @moduledoc false

  require Logger

  use RequestMock.Schema

  @required ~w(status http_status content_type tags headers body)a
  embedded_schema do
    field :status, :integer, default: 0
    field :http_status, :integer, default: 404
    field :content_type, :string, default: "text/plain"
    field :tags, {:array, :string}, default: []
    field :headers, {:array, :map}, default: []
    field :body, :string, default: ""
  end

  def validate(params) do
    case changeset(%__MODULE__{}, params) do
      %{valid?: true} = changeset -> {:ok, apply_changes(changeset)}
      changeset -> {:error, changeset}
    end
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_number(:status, greater_than_or_equal_to: 100, less_than_or_equal_to: 999)
  end
end
