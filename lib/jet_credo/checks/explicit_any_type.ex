defmodule JetCredo.Checks.ExplicitAnyType do
  @moduledoc false

  use Credo.Check,
    base_priority: :high,
    category: :refactor,
    explanations: [
      check: """
      Disallow the `any` type.

      Using the any type can make debugging very difficult,
      especially when the call chain is long.

      It is preferable to define and use a well-defined type instead of any in types.

      Example:

          # preferred
          @type reason() :: :bad_request | :not_found
          @spec request() :: :ok | {:error, :bad_request}

          # NOT preferred
          @type reason() :: term()
          @spec request() :: :ok | {:error, term()}

      See also:
      - https://github.com/Byzanteam/jet_credo/issues/1
      - https://github.com/Byzanteam/jet-tower/issues/86
      """
    ]

  @doc false
  @impl Credo.Check
  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  @type_catalogs [:type, :typep, :spec, :callback, :macrocallback]

  for type_catalog <- @type_catalogs do
    defp traverse(
           {:@, _meta, [{unquote(type_catalog), _type_meta, args}]} = ast,
           issues,
           issue_meta
         ) do
      {ast, find_any_type(unquote(type_catalog), args, issues, issue_meta)}
    end
  end

  defp traverse(ast, issues, _issue_meta) do
    {ast, issues}
  end

  defp find_any_type(type_catalog, ast, issues, issue_meta) do
    Credo.Code.prewalk(
      ast,
      fn
        {key, meta, []} = ast, acc when key in [:any, :term] ->
          options = [
            message: "Explicit `#{to_string(key)}()` type found in @#{to_string(type_catalog)}",
            trigger: "#{to_string(key)}()",
            line_no: meta[:line],
            column_no: meta[:column]
          ]

          {ast, [format_issue(issue_meta, options) | acc]}

        ast, acc ->
          {ast, acc}
      end,
      issues
    )
  end
end
