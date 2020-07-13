defmodule RequestMock.Schema do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      import Ecto.Query
      import Ecto.Changeset
      import RequestMock.Schema
    end
  end
end
