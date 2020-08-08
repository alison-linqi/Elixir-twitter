defmodule Twitter.Data.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Twitter.Data.User

  schema "users" do
    field :password, :string
    field :userid, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:userid, :password])
    |> validate_required([:userid, :password])
    |> unique_constraint(:userid)
    |> validate_length(:userid, min: 5, max: 20)
    |> validate_length(:password, min: 6, max: 20)
  end
end
