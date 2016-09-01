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

  defp normalize(query, operation \\ :all) do
    {query, _params, _key} = Ecto.Query.Planner.prepare(query, operation, Ecto.Adapters.Snappy)
    Ecto.Query.Planner.normalize(query, operation, Ecto.Adapters.Snappy)
  end

  test "from" do
    query = Model 
    |> select([r], r.x)
    |> normalize
    assert SQL.all(query) == ~s{SELECT m0."x" FROM "model" AS m0}
  end
  
  test "select" do
    query = Model 
    |> select([r], {r.x, r.y}) 
    |> normalize
    assert SQL.all(query) == ~s{SELECT m0."x", m0."y" FROM "model" AS m0}

    query = Model 
    |> select([r], [r.x, r.y]) 
    |> normalize
    assert SQL.all(query) == ~s{SELECT m0."x", m0."y" FROM "model" AS m0}

    query = Model 
    |> select([r], struct(r, [:x, :y]))
    |> normalize
    assert SQL.all(query) == ~s{SELECT m0."x", m0."y" FROM "model" AS m0}
  end
end
