defmodule RequestMock.Web.Plug.Request do
  @moduledoc false

  import Plug.Conn

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _opts) do
    with uuid <- List.first(conn.path_info),
         true <- Mockapp.Response.Manager.exists?(uuid),
         mock <- Mockapp.Response.Manager.read(uuid),
         true <- Mockapp.Response.Entity.is_struct?(mock) do
      IO.inspect(Mockapp.Response.Manager.exists?(uuid))
      IO.inspect(Mockapp.Response.Manager.exists?(uuid))
      IO.inspect(Mockapp.Response.Manager.exists?(uuid))

      if mock.status == 1 do
        Mockapp.Request.Manager.create(uuid, conn)
        send_response(conn, mock.http_status, mock.content_type, mock.body)
      else
        send_not_found(conn)
      end
    else
      _ -> send_not_found(conn)
    end
  end

  def send_not_found(conn) do
    send_response(conn, 404)
  end

  def send_response(conn, status, content_type \\ "text/plain", content \\ "") do
    conn
    |> put_resp_content_type(content_type)
    |> send_resp(status, content)
  end
end
