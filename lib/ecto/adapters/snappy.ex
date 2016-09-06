defmodule Ecto.Adapters.SnappyData do
  @moduledoc """
  """

  # Inherit all behaviour from Ecto.Adapters.SQL
  use Ecto.Adapters.SQL, :snappyex

  # And provide a custom storage implementation
  #@behaviour Ecto.Adapter.Storage
  #@behaviour Ecto.Adapter.Structure

  @doc false
  def supports_ddl_transaction? do
    false
  end
  alias Ecto.Migration.{Table, Index, Reference, Constraint}
  @conn __MODULE__.Connection

  def execute_ddl(repo, definition, opts) do
    definition = definition
    |> check_for_empty_prefix
    |> upcase_table
    execute_sql(repo, definition, opts)
    :ok
  end

  def upcase_table({type, %Table{} = table, columns}) do
    table = %{table | name: String.upcase to_string table.name}
    table = %{table | prefix: String.upcase table.prefix}
    {type, table, columns}
  end

  def check_for_empty_prefix({type, %Table{} = table, columns}) do
    table = case Map.get(table, :prefix) do
              nil -> %{table | prefix: "APP"}
              _ -> table
            end
    {type, table, columns}
  end

  def execute_sql(repo, definition = {:create_if_not_exists, %Table{} = table, columns}, opts) do
      sql = "SELECT tablename " <>
        "FROM sys.systables " <>
        "WHERE TABLESCHEMANAME = '#{table.prefix}' AND TABLENAME = '#{table.name}'"
      unless if_table_exists(Ecto.Adapters.SQL.query!(repo, sql, [], opts)) do
        sql = @conn.execute_ddl(definition)
        IO.inspect sql
        Ecto.Adapters.SQL.query!(repo, sql, [], opts)
      end
  end

  def execute_sql(repo, definition, opts) do
    sql = @conn.execute_ddl(definition)
    Ecto.Adapters.SQL.query!(repo, sql, [], opts)
  end

  def if_table_exists([[table]]) do
    table
  end

  def if_table_exists([]) do
    nil
  end
end
