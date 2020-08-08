defmodule Twitter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Twitter.Repo,
      # Start the endpoint when the application starts
      TwitterWeb.Endpoint
      # Starts a worker by calling: Twitter.Worker.start_link(arg)
      # {Twitter.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Twitter.Supervisor]
    result = Supervisor.start_link(children, opts)
    Twitter.Engine.start_link()
    Twitter.Init.create_n_users(100, 10)
    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwitterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
