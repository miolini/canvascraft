Mix.ensure_application!(:benchee)

alias CanvasCraft.Backends.Skia

threshold = System.get_env("BENCH_REGRESSION_THRESHOLD", "1.10") |> String.to_float()
baseline_path = System.get_env("BENCH_BASELINE", "bench/ci_baseline.json")

# Define a small, stable suite for CI
suite = Benchee.run(%{
  "skia_fill_rect" => fn ->
    {:ok, surf} = Skia.new_surface(64, 64, [])
    :ok = Skia.fill_rect(surf, 0, 0, 64, 64, {255,255,255,255})
  end,
  "skia_export_webp" => fn ->
    {:ok, surf} = Skia.new_surface(64, 64, [])
    {:ok, _bin} = Skia.export_webp(surf, [])
  end
}, time: 0.3, warmup: 0.1, print: [fast_warning: false])

results_ns =
  for sc <- suite.scenarios, into: %{} do
    name = sc.job_name
    median_ns = sc.statistics.run_time.statistics[:median]
    {name, median_ns}
  end

results_us = for {k, ns} <- results_ns, into: %{}, do: {k, ns / 1000.0}

read_json = fn path ->
  case File.read(path) do
    {:ok, bin} ->
      case Jason.decode(bin) do
        {:ok, data} when is_map(data) -> data
        _ -> %{}
      end
    _ -> %{}
  end
end

print_warn = fn msg -> IO.puts("::warning::" <> msg) end
print_note = fn msg -> IO.puts("::notice::" <> msg) end

baseline = read_json.(baseline_path)

if map_size(baseline) == 0 do
  print_note.("No benchmark baseline found at #{baseline_path}; skipping regression check.")
else
  Enum.each(results_us, fn {name, median_us} ->
    case baseline[name] do
      nil -> print_note.("No baseline for #{name}; current median #{Float.round(median_us, 2)}us")
      base_us when is_number(base_us) ->
        ratio = median_us / base_us
        delta_pct = (ratio - 1.0) * 100.0
        if ratio > threshold do
          print_warn.(
            "Benchmark regression: #{name} median #{Float.round(median_us, 2)}us > baseline #{Float.round(base_us, 2)}us (#{Float.round(delta_pct, 1)}%)"
          )
        else
          change = if delta_pct >= 0, do: "+#{Float.round(delta_pct, 1)}%", else: "#{Float.round(delta_pct, 1)}%"
          print_note.("#{name}: within threshold vs baseline (#{change})")
        end
    end
  end)
end

# Always print summary
IO.puts("\nCI Bench Summary (median, microseconds):")
Enum.each(results_us, fn {name, us} -> IO.puts("  - #{name}: #{Float.round(us, 2)}us") end)
