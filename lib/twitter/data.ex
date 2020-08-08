defmodule Twitter.Data do
	alias Twitter.Repo
	alias Twitter.Data.Tweet
	alias Twitter.Data.User

	def list_users do
		Repo.all(User)
	end

	def change_password(%User{} = user) do
		User.changeset(user, %{})
	end

	def update_password(%User{} = user, attrs) do
		user
		|> User.changeset(attrs)
		|> Repo.update()
	end

	def create_user(attrs \\ %{}) do
		user = %User{} |> User.changeset(attrs)
		Twitter.Client.start_link(user.changes.userid, user.changes.password)
		user |> Repo.insert()
	end

	def get_user!(id), do: Repo.get!(User, id)

	def get_userid!(userid), do: Repo.get_by(User, userid: userid)

	def delete_user(%User{} = user) do
		user |> Repo.delete()
	end

	def sign_in(%{"userid" => userid, "password" => password}) do
		user = Repo.get_by(User, userid: userid)

		cond do
			user != nil && user.password == password ->
				{:ok, user}
			true ->
				{:error, :unauthorized}
		end
	end
end