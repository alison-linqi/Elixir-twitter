defmodule Twitter.Repo.Migrations.CreateHashtags do
  use Ecto.Migration

  def change do
    create table(:hashtags) do
      add :htname, :string

      timestamps()
    end

  end
end
