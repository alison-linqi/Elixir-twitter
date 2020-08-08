defmodule Twitter.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :uid, :string
      add :user, :string
      add :following, :string

      timestamps()
    end

  end
end
