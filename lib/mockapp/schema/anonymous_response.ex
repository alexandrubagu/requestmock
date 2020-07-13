defmodule Database.Schema.AnonymousResponse do
  @moduledoc """
  Schema for persisting anonymous responses uuid
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "anonymous_responses" do
		field :uuid, :string
		timestamps()
  end

  def changeset(request,  params \\ %{}) do
    request
    |> cast(params, [:uuid])
    |> unique_constraint(:uuid)
  end
end
