defmodule Twitter.Data.Follow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "follows" do
    field :following, :string
    field :uid, :string
    field :user, :string

    timestamps()
  end

  @doc false
  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [:uid, :user, :following])
    |> validate_required([:uid, :user, :following])
  end
end
