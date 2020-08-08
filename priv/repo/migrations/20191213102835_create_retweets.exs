defmodule Twitter.Repo.Migrations.CreateRetweets do
  use Ecto.Migration

  def change do
    create table(:retweets) do
      add :user, :string
      add :original, :string
      add :content, :string

      timestamps()
    end

  end
end
