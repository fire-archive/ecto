Code.require_file "../../../integration_test/support/types.exs", __DIR__

defmodule Ecto.Adapters.SnappyTest do
  use ExUnit.Case, async: true

  import Ecto.Query

  alias Ecto.Queryable
  alias Ecto.Adapters.Snappy.Connection, as: SQL

  defmodule Model do
    use Ecto.Schema

    schema "model" do
      field :x, :integer
      field :y, :integer
      field :z, :integer
      field :w, {:array, :integer}

      has_many :comments, Ecto.Adapters.SnappyTest.Model2,
        references: :x,
        foreign_key: :z
      has_one :permalink, Ecto.Adapters.SnappyTest.Model3,
        references: :y,
        foreign_key: :id
    end
  end

  defmodule Model2 do
    use Ecto.Schema

    schema "model2" do
      belongs_to :post, Ecto.Adapters.SnappyTest.Model,
        references: :x,
        foreign_key: :z
    end
  end

  defmodule Model3 do
    use Ecto.Schema

    schema "model3" do
      field :list1, {:array, :string}
      field :list2, {:array, :integer}
      field :binary, :binary
    end
  end
end
