defmodule Twitter.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :userid, :string, null: false, size: 20
      add :password, :string, null: false, size: 20

      timestamps()
    end

    create unique_index(:users, [:userid])
  end
end
