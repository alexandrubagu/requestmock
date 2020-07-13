defmodule RequestMock.AnonymousResponses.AnonymousResponses do
  @moduledoc """
  Schema for persisting anonymous responses uuid
  """

  use RequestMock.Schema

  @required ~w(uuid)a
  schema "anonymous_responses" do
    field :uuid, :string
    timestamps()
  end

  def create(uuid), do: changeset(%__MODULE__{}, %{uuid: uuid})
  def having_uuid_in(queryable, list), do: where(queryable, [q], q.uuid in ^list)

  def days_ago(queryable, days) when is_number(days) do
    now = NaiveDateTime.utc_now()
    days_ago = NaiveDateTime.add(now, -days)

    from r in queryable,
      where: r.inserted_at < ^days_ago,
      select: r.uuid,
      limit: 5_000
  end

  @doc false
  defp changeset(request, params) do
    request
    |> cast(params, @required)
    |> unique_constraint(@required)
  end
end
