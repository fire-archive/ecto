if Code.ensure_loaded?(Snappyex) do

  defmodule Ecto.Adapters.Snappy.Connection do
    @moduledoc false

    @default_port 1531
    @behaviour Ecto.Adapters.SQL.Connection

    def child_spec(opts) do
      opts =
        opts
        |> Keyword.update(:port, @default_port, &normalize_port/1)
        |> Keyword.put(:types, true)

      Snappyex.child_spec(opts)
    end

    defp normalize_port(port) when is_binary(port), do: String.to_integer(port)
    defp normalize_port(port) when is_integer(port), do: port

  end
end
