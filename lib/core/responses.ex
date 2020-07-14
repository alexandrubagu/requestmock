defmodule RequestMock.Core.Responses do
  @moduledoc false

  import RequestMock.Core.Utils

  require Logger

  alias RequestMock.Core.Responses.Response

  @doc """
  Create mock to disk and database
  """
  def create(params) do
    with {:ok, response} <- Response.validate(params),
         {:ok, _} <- persist_to_disk(response) do
      {:ok, response}
    end
  end

  @doc """
  Switch mock on/off
  """
  def switch(uuid, "on") do
    with {:ok, filename_path} <- response_filename_exists?(uuid),
         {:ok, file} <- File.open(filename_path, [:write]) do
      :file.pwrite(file, 0, '1')
      File.close(file)
    end
  end

  def switch(uuid, "off") do
    with {:ok, filename_path} <- response_filename_exists?(uuid),
         {:ok, file} <- File.open(filename_path, [:write]) do
      :file.pwrite(file, 0, '0')
      File.close(file)
    end
  end

  defp persist_to_disk(response) do
    with {:ok, filename_path} <- create_response_filename(response.id),
         {:ok, file} <- File.open(filename_path, [:write, :utf8]) do
      {:ok, write_response(file, response)}
    end
  end

  defp write_response(file, response) do
    Logger.info("[#{response.id}] Start writing response ...")

    Logger.info("[#{response.id}] Writing response status ...")
    IO.write(file, "1\n")

    Logger.info("[#{response.id}] Writing response http status ...")
    IO.write(file, response.status <> "\n")

    Logger.info("[#{response.id}] Writing response content_type ...")
    IO.write(file, response.content_type <> "\n")

    Logger.info("[#{response.id}] Writing response tags ...")
    IO.write(file, Jason.encode!(String.split(response.tags, ",")) <> "\n")

    Logger.info("[#{response.id}] Writing response headers ...")
    headers = response.headers

    pair_headers =
      Enum.zip(
        Map.fetch!(headers, "name"),
        Map.fetch!(headers, "value")
      )

    IO.write(file, Jason.encode!(Enum.into(pair_headers, %{})) <> "\n")

    Logger.info("[#{response.id}] Writing response body ...")
    IO.write(file, response.body <> "\n")
    Logger.info("[#{response.id}] End writing response ...")
  end
end
