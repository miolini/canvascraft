# This file configures Credo for your project.
%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/", "mix.exs"],
        excluded: ["_build/", "deps/"]
      },
      checks: %{
        enabled: [
          {Credo.Check.Consistency.LineEndings, []},
          {Credo.Check.Consistency.SpaceAroundOperators, []},
          {Credo.Check.Consistency.SpaceInParentheses, []},
          {Credo.Check.Design.TagTODO, []},
          {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 100},
          {Credo.Check.Readability.ModuleDoc, []},
          {Credo.Check.Readability.ParenthesesInCondition, []},
          {Credo.Check.Readability.TrailingBlankLine, []},
          {Credo.Check.Readability.TrailingWhiteSpace, []},
          {Credo.Check.Refactor.CyclomaticComplexity, []},
          {Credo.Check.Refactor.Nesting, []},
          {Credo.Check.Warning.UnusedStringOperation, []},
          {Credo.Check.Warning.UnusedKeywordOperation, []},
          {Credo.Check.Warning.UnusedListOperation, []}
        ]
      }
    }
  ]
}
