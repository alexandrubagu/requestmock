defmodule RequestMock.Web.AppController do
  use RequestMock.Web, :controller
  require Logger

  @anonymous :anonymous_mocks

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, params) do
    case conn.method do
      "POST" ->
        create_mock(conn, params)

      _ ->
        render(conn, "create.html")
    end
  end

  defp get_session_mocks(conn) do
    case get_session(conn, @anonymous) do
      {:ok, json_mocks} -> Jason.decode(json_mocks)
      _ -> :not_found
    end
  end

  defp create_mock(conn, params) do
    result =
      case Mockapp.Response.Manager.create(params) do
        {:ok, response} ->
          Logger.info("response #{response} was generated")

          case get_session_mocks(conn) do
            :not_found ->
              Logger.info("no session found")
              {:ok, put_session(conn, @anonymous, Jason.encode([response]))}

            {:ok, mocks} ->
              Logger.info("add generated response to session")
              {:ok, put_session(conn, @anonymous, Jason.encode(mocks ++ [response]))}

            {:error, _} ->
              Logger.info("Something went wrong... reset session")
              {:ok, put_session(conn, @anonymous, Jason.encode([]))}
          end

        :error ->
          {:error, "Can't create mock"}
      end

    case result do
      {:ok, conn} ->
        redirect(conn, to: Routes.app_path(conn, :show))

      {:error, error} ->
        conn
        |> assign(:error, error)
        |> render("create.html")
    end
  end

  def show(conn, _params) do
    conn =
      case get_session_mocks(conn) do
        :not_found ->
          assign(conn, :mocks, [])

        {:ok, mocks_uuid} ->
          existing_mocks = Enum.filter(mocks_uuid, &Mockapp.Response.Manager.exists?(&1))

          mocks =
            Enum.map(existing_mocks, fn uuid ->
              {uuid, Mockapp.Response.Manager.read(uuid)}
            end)

          mocks =
            Enum.filter(mocks, fn {_, mock} ->
              Mockapp.Response.Entity.is_struct?(mock)
            end)

          conn
          |> assign(:mocks, mocks)

        {:error, _} ->
          Logger.info("Something went wrong... reset session")

          conn
          |> assign(:mocks, [])
          |> put_session(@anonymous, Jason.encode([]))
      end

    conn
    |> render("show.html")
  end

  def view(conn, params) do
    uuid = Map.fetch!(params, "uuid")

    if Mockapp.Response.Manager.exists?(uuid) do
      requests = Mockapp.Request.Manager.get(uuid)

      IO.inspect(requests)

      conn
      |> assign(:mock, uuid)
      |> assign(:requests, requests)
      |> render("view.html")
    else
      redirect(conn, to: Routes.app_path(conn, :show))
    end
  end

  def howto(conn, params) do
    request_mock = Map.get(params, "uuid")

    conn =
      case get_session_mocks(conn) do
        :not_found ->
          assign(conn, :mocks, [])

        {:ok, mocks_uuid} ->
          mocks =
            Enum.filter(mocks_uuid, fn mock ->
              Mockapp.Response.Manager.exists?(mock) && mock != request_mock
            end)

          conn
          |> assign(:mocks, mocks)

        {:error, _} ->
          Logger.info("Something went wrong... reset session")

          conn
          |> assign(:mocks, [])
          |> put_session(@anonymous, Jason.encode([]))
      end

    conn
    |> assign(:mock, request_mock)
    |> assign(:url, "http://www.requestmock.com/request/")
    |> put_layout("howto.html")
    |> render("howto.html")
  end

  def switch(conn, params) do
    uuid = Map.fetch!(params, "mock")
    state = Map.fetch!(params, "state")

    if Mockapp.Response.Manager.exists?(uuid) do
      Mockapp.Response.Manager.switch(uuid, state)
      send_resp(conn, 200, "ok")
    else
      send_resp(conn, 500, "error")
    end
  end

  def delete(conn, params) do
    uuid = Map.fetch!(params, "mock")

    if Mockapp.Response.Manager.exists?(uuid) do
      with :ok <- Mockapp.Response.Manager.delete(uuid),
           :ok <- Mockapp.Request.Manager.delete(uuid),
           do: send_resp(conn, 200, "ok")
    else
      send_resp(conn, 500, "error")
    end
  end
end
