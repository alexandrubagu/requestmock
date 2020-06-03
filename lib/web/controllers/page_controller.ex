defmodule RequestMock.Web.PageController do
  use RequestMock.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
