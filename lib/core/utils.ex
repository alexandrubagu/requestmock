defmodule RequestMock.Core.Utils do
  @moduledoc false

  @anonymous_responses_path Application.compile_env(:request_mock, [:requests, :anonymous])

  def create_response_filename(uuid) do
    filename_path = absolute_filename_path(uuid)

    case File.touch(filename_path) do
      :ok -> {:ok, filename_path}
      {:error, _} = error -> error
    end
  end

  def response_filename_exists?(uuid) do
    filename_path = absolute_filename_path(uuid)

    case File.exists?(filename_path) do
      true -> {:ok, filename_path}
      false -> {:error, "Filename path #{filename_path} doesn't exists"}
    end
  end

  defp absolute_filename_path(uuid), do: Enum.join([@anonymous_responses_path, uuid], "/")
end
