defmodule Twitter.Data.Retweet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "retweets" do
    field :content, :string
    field :original, :string
    field :user, :string

    timestamps()
  end

  @doc false
  def changeset(retweet, attrs) do
    retweet
    |> cast(attrs, [:user, :original, :content])
    |> validate_required([:user, :original, :content])
  end
end
