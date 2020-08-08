defmodule TwitterWeb.Router do
  use TwitterWeb, :router

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

  scope "/", TwitterWeb do
    pipe_through :browser

    get "/", SigninController, :index
    get "/signin", SigninController, :login
    post "/signin/verify", SigninController, :verify
    get "/users/new", SigninController, :new
    post "/users", SigninController, :create
    get "/users/:id", SigninController, :homepage
    get "/users/:id/edit", SigninController, :edit
    put "/users/:id", SigninController, :update
    delete "/users/:id", SigninController, :delete

    get "/sessions/:id", SessionController, :following
    post "/sessions", SessionController, :newfollowing
    get "/sessions/:id/writetweet", SessionController, :writetweet
    post "/sessions/send", SessionController, :sendtweet
    get "/retweet", SessionController, :retweet
    post "/sendretweet", SessionController, :sendretweet
    get "/hashtag", SessionController, :hashtag
    post "/result", SessionController, :hashtagresult

  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitterWeb do
  #   pipe_through :api
  # end
end
