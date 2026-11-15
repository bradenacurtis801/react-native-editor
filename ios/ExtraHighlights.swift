/// Highlight patterns added after a language preset's own (`withExtraHighlights`): captures the grammar's query leaves out, for a theme
/// that colors them apart. Each was compiled against its grammar together with the preset's query before it went in (a pattern that
/// does not compile makes the whole query fail, and the language shows no colors at all) — so check a change the same way.
///
/// - `keyword.import`: `import` / `from` of an import statement.
/// - `keyword.storage`: words that declare something (`def`, `class`, `const`, `function`, `interface`…), as VS Code draws them apart from
///   control flow.
/// - `variable.module`: the names of modules in an import.
/// - `type.class`: the class a class extends.
/// - `variable.builtin`: `self` and `cls` in Python.
enum ExtraHighlights {
  static let queries: [String: String] = [
    "python": python,
    "javascript": javaScript,
    "jsx": javaScript,
    "typescript": typeScript,
    "tsx": typeScript,
  ]

  private static let python = """
  (import_statement "import" @keyword.import)
  (import_from_statement ["from" "import"] @keyword.import)
  (import_statement name: (dotted_name (identifier) @variable.module))
  (import_statement name: (aliased_import name: (dotted_name (identifier) @variable.module)))
  (import_from_statement module_name: (dotted_name (identifier) @variable.module))
  ["def" "class" "lambda" "global" "nonlocal"] @keyword.storage
  ((identifier) @variable.builtin (#match? @variable.builtin "^(self|cls)$"))
  (class_definition name: (identifier) @type.class)
  (class_definition superclasses: (argument_list (identifier) @type.class))
  """

  private static let javaScript = """
  (import_statement "import" @keyword.import)
  (import_statement "from" @keyword.import)
  (namespace_import (identifier) @variable.module)
  ["const" "let" "var" "function" "class" "extends" "new" "typeof" "instanceof" "in" "of" "delete" "async" "static" "get" "set"] @keyword.storage
  (class_heritage (identifier) @type.class)
  """

  private static let typeScript = """
  (import_statement "import" @keyword.import)
  (import_statement "from" @keyword.import)
  (namespace_import (identifier) @variable.module)
  ["const" "let" "var" "function" "class" "extends" "new" "typeof" "instanceof" "in" "of" "delete" "async" "static" "get" "set" "interface" "type" "enum" "namespace" "declare" "abstract" "implements" "readonly" "public" "private" "protected" "keyof"] @keyword.storage
  (extends_clause value: (identifier) @type.class)
  """
}
