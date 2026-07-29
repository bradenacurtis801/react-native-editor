import NitroModules
import Runestone
import UIKit

// Each of these adds one `static var <lang>: TreeSitterLanguage` to
// TreeSitterLanguage via `extension TreeSitterLanguage { ... }` — Runestone
// itself only defines the TreeSitterLanguage *type*, not any language
// presets, so `.javaScript`/`.python`/etc in treeSitterLanguage(for:) below
// don't resolve without importing the specific per-language module that
// declares each one (matches the product list in ReactNativeEditor.podspec).
import TreeSitterJSONRunestone
import TreeSitterJavaScriptRunestone
import TreeSitterTypeScriptRunestone
import TreeSitterCSharpRunestone
import TreeSitterPythonRunestone
import TreeSitterRubyRunestone
import TreeSitterGoRunestone
import TreeSitterRustRunestone
import TreeSitterJavaRunestone
import TreeSitterSwiftRunestone
import TreeSitterCRunestone
import TreeSitterCPPRunestone
import TreeSitterCSSRunestone
import TreeSitterHTMLRunestone
import TreeSitterYAMLRunestone
import TreeSitterSQLRunestone
import TreeSitterBashRunestone
import TreeSitterMarkdownRunestone

private extension UIColor {
  /// Parses `#rgb`/`#rrggbb`/`#rrggbbaa` — the same hex strings the JS side's
  /// theme colors already come in as (see `src/theme/colors.ts`).
  convenience init(hex: String) {
    var s = hex
    if s.hasPrefix("#") { s.removeFirst() }
    var v: UInt64 = 0
    Scanner(string: s).scanHexInt64(&v)
    switch s.count {
    case 3:
      let r = (v & 0xF00) >> 8, g = (v & 0x0F0) >> 4, b = v & 0x00F
      self.init(red: CGFloat(r) / 15, green: CGFloat(g) / 15, blue: CGFloat(b) / 15, alpha: 1)
    case 8:
      let r = (v & 0xFF00_0000) >> 24, g = (v & 0x00FF_0000) >> 16, b = (v & 0x0000_FF00) >> 8, a = v & 0x0000_00FF
      self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    default:
      let r = (v & 0xFF0000) >> 16, g = (v & 0x00FF00) >> 8, b = v & 0x0000FF
      self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }
  }
}

/// Maps `viewerUtils.getLanguage()`'s ids (app-side) to Runestone's tree-sitter
/// presets (`TreeSitterLanguages`, pulled in via the podspec's `spm_dependency`
/// calls). Anything unmapped (kotlin, xml, plaintext, unrecognized) returns nil,
/// which `EditorContainerView.configure` treats as plain text — not an error.
private func treeSitterLanguage(for id: String) -> TreeSitterLanguage? {
  switch id {
  case "javascript": return .javaScript
  case "typescript": return .typeScript
  case "csharp": return .cSharp
  case "python": return .python
  case "ruby": return .ruby
  case "go": return .go
  case "rust": return .rust
  case "java": return .java
  case "swift": return .swift
  case "c": return .c
  case "cpp": return .cpp
  case "css": return .css
  case "html": return .html
  case "json": return .json
  case "yaml": return .yaml
  case "sql": return .sql
  case "bash": return .bash
  case "markdown": return .markdown
  default: return nil
  }
}

/// `Theme` conforming to Runestone's `Theme` protocol, backed by the 5-bucket
/// color map (keyword/string/comment/number/plain) the app already builds in
/// `LocalTextViewer.tsx`'s `syntaxColors`, matched against tree-sitter capture
/// names by substring (a capture like `keyword.control` or `string.special`
/// still lands in the right bucket).
private final class EditorTheme: Theme {
  var font: UIFont = .monospacedSystemFont(ofSize: 13, weight: .regular)
  var textColor: UIColor = .label
  let gutterBackgroundColor: UIColor = .clear
  let gutterHairlineColor: UIColor = .clear
  var lineNumberColor: UIColor = .secondaryLabel
  var lineNumberFont: UIFont = .monospacedSystemFont(ofSize: 11, weight: .regular)
  let selectedLineBackgroundColor: UIColor = .clear
  var selectedLinesLineNumberColor: UIColor = .label
  let selectedLinesGutterBackgroundColor: UIColor = .clear
  var invisibleCharactersColor: UIColor = .tertiaryLabel
  let pageGuideHairlineColor: UIColor = .clear
  let pageGuideBackgroundColor: UIColor = .clear
  let markedTextBackgroundColor: UIColor = .clear

  private var syntaxColors: [String: UIColor] = [:]

  func configure(syntaxColorsJson: String, textColor: UIColor, fontSizePx: CGFloat) {
    self.textColor = textColor
    self.lineNumberColor = textColor.withAlphaComponent(0.4)
    self.selectedLinesLineNumberColor = textColor
    self.font = .monospacedSystemFont(ofSize: fontSizePx, weight: .regular)
    self.lineNumberFont = .monospacedSystemFont(ofSize: max(fontSizePx - 2, 9), weight: .regular)
    guard let data = syntaxColorsJson.data(using: .utf8),
          let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String] else { return }
    syntaxColors = dict.reduce(into: [:]) { $0[$1.key] = UIColor(hex: $1.value) }
  }

  func textColor(for highlightName: String) -> UIColor? {
    if highlightName.contains("keyword") { return syntaxColors["keyword"] }
    if highlightName.contains("string") { return syntaxColors["string"] }
    if highlightName.contains("comment") { return syntaxColors["comment"] }
    if highlightName.contains("number") || highlightName.contains("constant") { return syntaxColors["number"] }
    return syntaxColors["plain"]
  }
}

/// Hosts Runestone's `TextView` and tracks dirty state against the buffer it
/// was last `configure`d with (used both for the initial mount and for
/// `setText`, e.g. to restore a known-good state after a failed save).
private final class EditorContainerView: UIView, TextViewDelegate {
  let textView = TextView()
  private var baselineText = ""
  private var isDirty = false
  var onDirtyChange: ((Bool) -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    textView.editorDelegate = self
    textView.showLineNumbers = true
    addSubview(textView)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func layoutSubviews() {
    super.layoutSubviews()
    textView.frame = bounds
  }

  func configure(text: String, language: String, theme: EditorTheme) {
    baselineText = text
    if isDirty { isDirty = false; onDirtyChange?(false) }
    let state = treeSitterLanguage(for: language).map { TextViewState(text: text, theme: theme, language: $0) }
      ?? TextViewState(text: text, theme: theme)
    textView.setState(state)
  }

  func textViewDidChange(_ textView: TextView) {
    let dirty = textView.text != baselineText
    guard dirty != isDirty else { return }
    isDirty = dirty
    onDirtyChange?(dirty)
  }
}

/// iOS implementation of the `Editor` Nitro HybridView, wrapping Runestone.
/// `text`/`language` only seed the buffer on the first prop commit — later
/// changes to those props are no-ops; use `setText` to replace the buffer.
class HybridEditor: HybridEditorSpec {
  private let container = EditorContainerView()
  private let editorTheme = EditorTheme()
  private var hasConfigured = false

  var view: UIView { container }

  override init() {
    super.init()
    container.onDirtyChange = { [weak self] isDirty in
      self?.onChangeDirty(isDirty)
    }
  }

  var text: String = ""
  var language: String = "plaintext"
  var editable: Bool = true {
    didSet { container.textView.isEditable = editable }
  }
  var syntaxColorsJson: String = "{}"
  var backgroundColor: String = "#000000"
  var textColor: String = "#ffffff"
  var fontSizePx: Double = 13
  var onChangeDirty: (_ isDirty: Bool) -> Void = { _ in }

  func afterUpdate() {
    editorTheme.configure(
      syntaxColorsJson: syntaxColorsJson,
      textColor: UIColor(hex: textColor),
      fontSizePx: CGFloat(fontSizePx))
    let bg = UIColor(hex: backgroundColor)
    container.backgroundColor = bg
    container.textView.backgroundColor = bg

    if !hasConfigured {
      hasConfigured = true
      container.configure(text: text, language: language, theme: editorTheme)
      container.textView.isEditable = editable
    }
  }

  func readBuffer() throws -> String {
    container.textView.text
  }

  func writeBuffer(text: String) throws {
    self.text = text
    container.configure(text: text, language: language, theme: editorTheme)
  }
}
