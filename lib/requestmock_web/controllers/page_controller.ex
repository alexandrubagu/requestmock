defmodule RequestMockWeb.PageController do
  use RequestMockWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
