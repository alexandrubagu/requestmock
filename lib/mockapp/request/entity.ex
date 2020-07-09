defmodule Mockapp.Request.Entity do
  @moduledoc false

  require Logger
  defstruct [:datetime, :ip, :method, :content_type, :user_agent, :path, :body_params, :query_string]

  def is_struct?(mock) do
    with true <- is_map(mock),
         true <- Map.has_key?(mock, :__struct__),
         true <- mock.__struct__ == Mockapp.Request.Entity
    do
      true
    else
      _ -> false
    end
  end
end
