defmodule Twitter.Repo.Migrations.CreateTweets do
  use Ecto.Migration

  def change do
    create table(:tweets) do
      add :writer, :string, null: false
      add :hashtag, :string
      add :mention, :string
      add :content, :string, null: false, size: 200

      timestamps()
    end

  end
end
