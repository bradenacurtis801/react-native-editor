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
/// - `type.class` / `constant.name`: a class being instantiated (`new Foo()`, `Foo()`), and an ALL_CAPS name — both are captured by the preset
///   as `constructor` / `constant`, which tie with its catch-all `variable` in the same way.
/// - `function.call` / `function.definition`: the same names the preset already captures as plain `function`, but with a name of two parts.
///   The presets' own queries end with `(identifier) @variable`, which captures the very same text with the same number of name parts, and
///   Runestone breaks that tie by capture order — so a function's name could come out as a variable. A longer name always wins.
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
  (function_definition name: (identifier) @function.definition)
  (call function: (identifier) @function.call (#not-match? @function.call "^[A-Z]"))
  (call function: (identifier) @type.class (#match? @type.class "^[A-Z]"))
  ((identifier) @constant.name (#match? @constant.name "^[A-Z][A-Z_0-9]+$"))
  """

  private static let javaScript = """
  (import_statement "import" @keyword.import)
  (import_statement "from" @keyword.import)
  (namespace_import (identifier) @variable.module)
  ["const" "let" "var" "function" "class" "extends" "new" "typeof" "instanceof" "in" "of" "delete" "async" "static" "get" "set"] @keyword.storage
  (class_heritage (identifier) @type.class)
  (function name: (identifier) @function.definition)
  (function_declaration name: (identifier) @function.definition)
  (variable_declarator name: (identifier) @function.definition value: [(function) (arrow_function)])
  (assignment_expression left: (identifier) @function.definition right: [(function) (arrow_function)])
  (call_expression function: (identifier) @function.call (#not-match? @function.call "^[A-Z]"))
  (call_expression function: (identifier) @type.class (#match? @type.class "^[A-Z]"))
  (new_expression constructor: (identifier) @type.class)
  ((identifier) @constant.name (#match? @constant.name "^[A-Z][A-Z_0-9]+$"))
  """

  private static let typeScript = """
  (import_statement "import" @keyword.import)
  (import_statement "from" @keyword.import)
  (namespace_import (identifier) @variable.module)
  ["const" "let" "var" "function" "class" "extends" "new" "typeof" "instanceof" "in" "of" "delete" "async" "static" "get" "set" "interface" "type" "enum" "namespace" "declare" "abstract" "implements" "readonly" "public" "private" "protected" "keyof"] @keyword.storage
  (extends_clause value: (identifier) @type.class)
  (function name: (identifier) @function.definition)
  (function_declaration name: (identifier) @function.definition)
  (variable_declarator name: (identifier) @function.definition value: [(function) (arrow_function)])
  (assignment_expression left: (identifier) @function.definition right: [(function) (arrow_function)])
  (call_expression function: (identifier) @function.call (#not-match? @function.call "^[A-Z]"))
  (call_expression function: (identifier) @type.class (#match? @type.class "^[A-Z]"))
  (new_expression constructor: (identifier) @type.class)
  ((identifier) @constant.name (#match? @constant.name "^[A-Z][A-Z_0-9]+$"))
  """
}
