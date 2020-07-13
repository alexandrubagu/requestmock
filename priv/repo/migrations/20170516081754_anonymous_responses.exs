defmodule RequestMock.Repo.Migrations.Requests do
  use Ecto.Migration

  def up do
    create table(:anonymous_responses) do
      add :uuid, :string
      timestamps()
    end

    create unique_index(:anonymous_responses, [:uuid])
  end

  def down do
    drop index(:anonymous_responses, [:uuid])
    drop table(:anonymous_responses)
  end
end
