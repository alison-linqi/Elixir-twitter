defmodule Twitter.Data.Hashtag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hashtags" do
    field :htname, :string

    timestamps()
  end

  @doc false
  def changeset(hashtag, attrs) do
    hashtag
    |> cast(attrs, [:htname])
    |> validate_required([:htname])
  end
end
