defmodule Twitter.Data.Tweet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tweets" do
    field :content, :string
    field :hashtag, :string
    field :mention, :string
    field :writer, :string

    timestamps()
  end

  @doc false
  def changeset(tweet, attrs) do
    tweet
    |> cast(attrs, [:writer, :hashtag, :mention, :content])
    |> validate_required([:writer, :content])
  end
end
