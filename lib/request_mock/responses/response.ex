defmodule RequestMock.Responses.Response do
  @moduledoc false

  require Logger

  use RequestMock.Schema

  @required ~w(status http_status content_type tags headers body)a
  embedded_schema do
    field :status, :integer
    field :http_status, :integer
    field :content_type, :string
    field :tags, {:array, :string}
    field :headers, :integer
    field :body, :string
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
