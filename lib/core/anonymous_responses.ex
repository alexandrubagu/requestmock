defmodule RequestMock.Core.AnonymousResponses do
  @moduledoc false

  alias RequestMock.Repo
  alias RequestMock.Core.AnonymousResponses.AnonymousResponses

  def create(uuid) do
    uuid
    |> AnonymousResponses.create()
    |> Repo.insert()
  end

  def delete(uuids) do
    uuids
    |> AnonymousResponses.having_uuid_in(uuids)
    |> Repo.delete_all()
  end

  def days_ago(days) do
    AnonymousResponses
    |> AnonymousResponses.days_ago(days)
    |> Repo.all()
  end
end
