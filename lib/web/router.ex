defmodule RequestMock.Web.Router do
  use RequestMock.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RequestMock.Web do
    # Use the default browser stack
    pipe_through :browser

    # start page
    get "/", AppController, :index

    # create
    get "/create", AppController, :create
    post "/create", AppController, :create

    # listing
    get "/list", AppController, :show
    get "/view/:uuid", AppController, :view

    # how-to-use
    get "/how-to-use/:uuid", AppController, :howto
    get "/how-to-use", AppController, :howto

    # ajax
    post "/switch", AppController, :switch
    post "/delete", AppController, :delete
  end

  scope "/request", alias: RequestMock.Web do
    forward "/", Plug.Request
  end
end
