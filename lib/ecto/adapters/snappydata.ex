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

  def upcase_table({type, %Ecto.Migration.Index{} = index}) do 
    index = %{index | name: String.upcase to_string index.name} 
    index = %{index | prefix: String.upcase index.prefix} 
    {type, index} 
  end 

  def check_for_empty_prefix({type, %Table{} = table, columns}) do 
    table = case Map.get(table, :prefix) do 
              nil -> %{table | prefix: "APP"} 
              _ -> table 
            end 
    {type, table, columns} 
  end 

  def check_for_empty_prefix({type, %Ecto.Migration.Index{} = index}) do 
    index = case Map.get(index, :prefix) do 
              nil -> %{index | prefix: "APP"} 
              _ -> index 
            end 
    {type, index} 
  end 

  def execute_sql(repo, definition = {:create_if_not_exists, %Table{} = table, columns}, opts) do 
    sql = "SELECT tablename " <> 
      "FROM sys.systables " <> 
      "WHERE TABLESCHEMANAME = '#{table.prefix}' AND TABLENAME = '#{table.name}'" 
    unless extract_table_row(Ecto.Adapters.SQL.query!(repo, sql, [], opts)) do 
      sql = @conn.execute_ddl(definition) 
      IO.inspect sql 
      Ecto.Adapters.SQL.query!(repo, sql, [], opts) 
    end 
  end 


  def execute_sql(repo, definition, opts) do
    sql = @conn.execute_ddl(definition)
    try do
      Ecto.Adapters.SQL.query!(repo, sql, [], opts)
    rescue
      e in Snappyex.Model.SnappyException -> 
        e
    end
  end

  def extract_table_row(%Snappyex.Result{rows: [[table]]}) do
    table
  end

  def extract_table_row(%Snappyex.Result{rows: []}) do
    nil
  end
end
