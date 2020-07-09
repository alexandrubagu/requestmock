defmodule RequestMock.Web.AppView do
  @moduledoc false

  use RequestMock.Web, :view

  def csrf_token(), do: Plug.CSRFProtection.get_csrf_token()

  def title("index.html"), do: "RequestMock - Create, Inspect and Debug HTTP requests"
  def title("create.html"), do: "RequestMock - Create HTTP mocks"
  def title("howto.html"), do: "RequestMock- How to integrate the mock"
  def title("show.html"), do: "RequestMock - Show mock"
  def title("view.html"), do: "RequestMock - View created HTTP mocks"
  def title(_), do: ""

  def description("index.html"),
    do:
      "RequestMock allows you to set up custom endpoints to test and inspect HTTP requests & responses which came from different libraries, webhooks and APIs"

  def description("create.html"),
    do:
      "RequestMock allows to create HTTP mocks to test and debug incomming HTTP requests from different applications, libraries, webhooks and APIs"

  def description("howto.html"),
    do: "RequestMock allows to integrate the mock into your applications, libraries and APIs"

  def description("show.html"),
    do:
      "RequestMock grants permision to view HTTP mocks created which can be embeded into your apps, libraries and APIs"

  def description("view.html"), do: "RequestMock allows to view created HTTP mocks"
  def description(_), do: ""
end
