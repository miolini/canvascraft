# This file was generated for initial linting setup.
%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/", "mix.exs"],
        excluded: [~r"_build/", ~r"deps/"]
      },
      checks: [
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 100},
        # Enable more checks as the codebase grows
      ]
    }
  ]
}
