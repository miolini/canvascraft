defmodule CanvasCraft.GoldenHelper do
  @moduledoc false

  @tolerance 2

  def compare_png_binary(got_binary, expected_path) when is_binary(got_binary) do
    {:ok, expected} = File.read(expected_path)
    got = String.trim_trailing(got_binary, "\n") |> String.trim_trailing("\r")
    expected = String.trim_trailing(expected, "\n") |> String.trim_trailing("\r")
    compare_bytes(got, expected)
  end

  def compare_png_files(got_path, expected_path) do
    {:ok, got} = File.read(got_path)
    {:ok, expected} = File.read(expected_path)
    got = String.trim_trailing(got, "\n") |> String.trim_trailing("\r")
    expected = String.trim_trailing(expected, "\n") |> String.trim_trailing("\r")
    compare_bytes(got, expected)
  end

  defp compare_bytes(a, b) when byte_size(a) == byte_size(b) do
    diffs = for {x, y} <- Enum.zip(:binary.bin_to_list(a), :binary.bin_to_list(b)), reduce: 0 do
      acc ->
        d = abs(x - y)
        acc + if d > @tolerance, do: 1, else: 0
    end

    if diffs == 0 do
      :ok
    else
      {:error, {:pixel_delta_exceeded, diffs}}
    end
  end

  defp compare_bytes(_, _), do: {:error, :size_mismatch}
end
