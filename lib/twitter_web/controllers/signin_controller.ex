defmodule TwitterWeb.SigninController do
  use TwitterWeb, :controller
  alias Twitter.Data.User
  alias Twitter.Data
  alias Twitter.Repo
  alias Twitter.Engine, as: Engine
  alias Twitter.Client

  def index(conn, _params) do
    #Twitter.init.create_n_users(100, 10)
  	users = Data.list_users()
    render(conn, "index.html", users: users)
  end

  def login(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "login.html", changeset: changeset)
  end

  def verify(conn, %{"user" => user}) do
    case Data.sign_in(user) do
      {:ok, user_params} ->
        conn
        |> put_flash(:info, "Log in sucessfully!")
        |> redirect(to: Routes.signin_path(conn, :homepage, user_params.id))

      {:error, :unauthorized} ->
        conn
        |> put_flash(:info, "User not exists or wrong password!")
        |> redirect(to: Routes.signin_path(conn, :login))
    end
  end

  def new(conn, _params) do
  	changeset = User.changeset(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
  	 case Data.create_user(user_params) do
  	 	{:ok, _} ->
  	 		conn
  	 		|> put_flash(:info, "User created!")
  	 		|> redirect(to: Routes.signin_path(conn, :login))

  	 	{:error, %Ecto.Changeset{} = changeset} ->
  	 		render(conn, "new.html", changeset: changeset)
  	 end
  end

  def homepage(conn, %{"id" => id}) do
  	user = Data.get_user!(id)
    render(conn, "homepage.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
  	user = Data.get_user!(id)
    IO.puts "111111 #{inspect user}"
  	changeset = Data.change_password(user)
  	render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
  	user = Data.get_user!(id)
  	case Data.update_password(user, user_params) do
  	 	{:ok, _} ->
  	 		conn
  	 		|> put_flash(:info, "Password updated!")
  	 		|> redirect(to: Routes.signin_path(conn, :homepage, user))

  	 	{:error, %Ecto.Changeset{} = changeset} ->
  	 		render(conn, "edit.html", user: user, changeset: changeset)
  	end
  end

  def delete(conn, %{"id" => id}) do
  	user = Data.get_user!(id)
  	{:ok, _user} = Data.delete_user(user)
    Engine.delete_account(user.userid)

  	conn
  	|> put_flash(:info, "User deleted")
  	|> redirect(to: Routes.signin_path(conn, :index))
  end
end
