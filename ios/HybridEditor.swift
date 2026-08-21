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

// MARK: - Enum-string mappings
//
// Each of these maps a plain JS-facing string (the `EditorProps` field's own
// documented set of values) to the matching UIKit/Runestone enum case — the
// same `id -> enum` pattern `treeSitterLanguage(for:)` above already
// established for `language`. An unrecognized string falls back to a
// reasonable default rather than crashing, since these values ultimately
// come from JS and a typo there shouldn't take the editor down.

private func parsedAutocorrectionType(for id: String) -> UITextAutocorrectionType {
  switch id {
  case "no": return .no
  case "yes": return .yes
  default: return .default
  }
}

private func parsedAutocapitalizationType(for id: String) -> UITextAutocapitalizationType {
  switch id {
  case "words": return .words
  case "sentences": return .sentences
  case "allCharacters": return .allCharacters
  default: return .none
  }
}

private func parsedSmartQuotesType(for id: String) -> UITextSmartQuotesType {
  switch id {
  case "no": return .no
  case "yes": return .yes
  default: return .default
  }
}

private func parsedSmartDashesType(for id: String) -> UITextSmartDashesType {
  switch id {
  case "no": return .no
  case "yes": return .yes
  default: return .default
  }
}

private func parsedSmartInsertDeleteType(for id: String) -> UITextSmartInsertDeleteType {
  switch id {
  case "no": return .no
  case "yes": return .yes
  default: return .default
  }
}

private func parsedSpellCheckingType(for id: String) -> UITextSpellCheckingType {
  switch id {
  case "no": return .no
  case "yes": return .yes
  default: return .default
  }
}

private func parsedKeyboardType(for id: String) -> UIKeyboardType {
  switch id {
  case "asciiCapable": return .asciiCapable
  case "numbersAndPunctuation": return .numbersAndPunctuation
  case "URL": return .URL
  case "numberPad": return .numberPad
  case "phonePad": return .phonePad
  case "namePhonePad": return .namePhonePad
  case "emailAddress": return .emailAddress
  case "decimalPad": return .decimalPad
  case "twitter": return .twitter
  case "webSearch": return .webSearch
  case "asciiCapableNumberPad": return .asciiCapableNumberPad
  default: return .default
  }
}

private func parsedKeyboardAppearance(for id: String) -> UIKeyboardAppearance {
  switch id {
  case "light": return .light
  case "dark": return .dark
  default: return .default
  }
}

private func parsedReturnKeyType(for id: String) -> UIReturnKeyType {
  switch id {
  case "go": return .go
  case "google": return .google
  case "join": return .join
  case "next": return .next
  case "route": return .route
  case "search": return .search
  case "send": return .send
  case "yahoo": return .yahoo
  case "done": return .done
  case "emergencyCall": return .emergencyCall
  case "continue": return .continue
  default: return .default
  }
}

private func parsedLineSelectionDisplayType(for id: String) -> LineSelectionDisplayType {
  switch id {
  case "line": return .line
  case "lineFragment": return .lineFragment
  default: return .disabled
  }
}

private func parsedLineBreakMode(for id: String) -> LineBreakMode {
  id == "byCharWrapping" ? .byCharWrapping : .byWordWrapping
}

private func parsedLineEnding(for id: String) -> LineEnding {
  switch id {
  case "crlf": return .crlf
  case "cr": return .cr
  default: return .lf
  }
}

/// `Theme` conforming to Runestone's `Theme` protocol, backed by the 5-bucket
/// syntax color map (keyword/string/comment/number/plain) the app already
/// builds in `LocalTextViewer.tsx`'s `syntaxColors`, matched against
/// tree-sitter capture names by substring (a capture like `keyword.control`
/// or `string.special` still lands in the right bucket) — plus every other
/// `Theme` color, all configurable from JS (`EditorProps`) rather than
/// hardcoded, so the app can restyle the gutter/current-line/page-guide/
/// marked-text chrome to match its own theme without a native change.
private final class EditorTheme: Theme {
  var font: UIFont = .monospacedSystemFont(ofSize: 13, weight: .regular)
  var textColor: UIColor = .label
  var gutterBackgroundColor: UIColor = .clear
  var gutterHairlineColor: UIColor = .clear
  var lineNumberColor: UIColor = .secondaryLabel
  var lineNumberFont: UIFont = .monospacedSystemFont(ofSize: 11, weight: .regular)
  var selectedLineBackgroundColor: UIColor = .clear
  var selectedLinesLineNumberColor: UIColor = .label
  var selectedLinesGutterBackgroundColor: UIColor = .clear
  var invisibleCharactersColor: UIColor = .tertiaryLabel
  var pageGuideHairlineColor: UIColor = .clear
  var pageGuideBackgroundColor: UIColor = .clear
  var markedTextBackgroundColor: UIColor = .clear

  private var syntaxColors: [String: UIColor] = [:]

  func configure(
    syntaxColorsJson: String,
    textColor: UIColor,
    fontSizePx: CGFloat,
    gutterBackgroundColor: UIColor,
    gutterHairlineColor: UIColor,
    selectedLineBackgroundColor: UIColor,
    selectedLinesGutterBackgroundColor: UIColor,
    invisibleCharactersColor: UIColor,
    pageGuideHairlineColor: UIColor,
    pageGuideBackgroundColor: UIColor,
    markedTextBackgroundColor: UIColor
  ) {
    self.textColor = textColor
    self.lineNumberColor = textColor.withAlphaComponent(0.4)
    self.selectedLinesLineNumberColor = textColor
    self.font = .monospacedSystemFont(ofSize: fontSizePx, weight: .regular)
    self.lineNumberFont = .monospacedSystemFont(ofSize: max(fontSizePx - 2, 9), weight: .regular)
    self.gutterBackgroundColor = gutterBackgroundColor
    self.gutterHairlineColor = gutterHairlineColor
    self.selectedLineBackgroundColor = selectedLineBackgroundColor
    self.selectedLinesGutterBackgroundColor = selectedLinesGutterBackgroundColor
    self.invisibleCharactersColor = invisibleCharactersColor
    self.pageGuideHairlineColor = pageGuideHairlineColor
    self.pageGuideBackgroundColor = pageGuideBackgroundColor
    self.markedTextBackgroundColor = markedTextBackgroundColor
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
///
/// Everything below `fontSizePx` is a direct passthrough to a `TextView`/
/// `Theme` property of the same (or documented) name — see `Editor.nitro.ts`
/// for what each one does; this file is deliberately not re-documenting each
/// one, just wiring it through. All of it is applied fresh on every
/// `afterUpdate()` (idempotent property writes, not one-time setup), so any
/// prop can be changed live from JS without a re-mount.
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
  var editable: Bool = true
  var syntaxColorsJson: String = "{}"
  var backgroundColor: String = "#000000"
  var textColor: String = "#ffffff"
  var fontSizePx: Double = 13
  var showLineNumbers: Bool = true
  var automaticScrollEnabled: Bool = false
  var verticalOverscrollFactor: Double = 1
  var horizontalOverscrollFactor: Double = 0
  var isSelectable: Bool = true
  var autocorrectionType: String = "no"
  var autocapitalizationType: String = "none"
  var smartQuotesType: String = "no"
  var smartDashesType: String = "no"
  var smartInsertDeleteType: String = "no"
  var spellCheckingType: String = "no"
  var keyboardType: String = "asciiCapable"
  var keyboardAppearance: String = "default"
  var returnKeyType: String = "default"
  var insertionPointColorHex: String = "#ffffff"
  var selectionBarColorHex: String = "#ffffff"
  var selectionHighlightColorHex: String = "#3399ff"
  var showTabs: Bool = false
  var showSpaces: Bool = false
  var showNonBreakingSpaces: Bool = false
  var showLineBreaks: Bool = false
  var showSoftLineBreaks: Bool = false
  var tabSymbol: String = "\u{2192}"
  var spaceSymbol: String = "\u{00B7}"
  var nonBreakingSpaceSymbol: String = "\u{00B7}"
  var lineBreakSymbol: String = "\u{00AC}"
  var softLineBreakSymbol: String = "\u{203A}"
  var invisibleCharactersColorHex: String = "#808080"
  var gutterLeadingPadding: Double = 3
  var gutterTrailingPadding: Double = 3
  var gutterMinimumCharacterCount: Double = 2
  var gutterBackgroundColorHex: String = "#000000"
  var gutterHairlineColorHex: String = "#00000000"
  var lineSelectionDisplayType: String = "disabled"
  var selectedLineBackgroundColorHex: String = "#00000000"
  var selectedLinesGutterBackgroundColorHex: String = "#00000000"
  var isLineWrappingEnabled: Bool = true
  var lineBreakMode: String = "byWordWrapping"
  var kern: Double = 0
  var lineHeightMultiplier: Double = 1
  var showPageGuide: Bool = false
  var pageGuideColumn: Double = 80
  var pageGuideHairlineColorHex: String = "#00000000"
  var pageGuideBackgroundColorHex: String = "#00000000"
  var markedTextBackgroundColorHex: String = "#00000000"
  var isFindInteractionEnabled: Bool = false
  var lineEndings: String = "lf"
  var showMenuAfterNavigatingToHighlightedRange: Bool = true
  var onChangeDirty: (_ isDirty: Bool) -> Void = { _ in }

  func afterUpdate() {
    editorTheme.configure(
      syntaxColorsJson: syntaxColorsJson,
      textColor: UIColor(hex: textColor),
      fontSizePx: CGFloat(fontSizePx),
      gutterBackgroundColor: UIColor(hex: gutterBackgroundColorHex),
      gutterHairlineColor: UIColor(hex: gutterHairlineColorHex),
      selectedLineBackgroundColor: UIColor(hex: selectedLineBackgroundColorHex),
      selectedLinesGutterBackgroundColor: UIColor(hex: selectedLinesGutterBackgroundColorHex),
      invisibleCharactersColor: UIColor(hex: invisibleCharactersColorHex),
      pageGuideHairlineColor: UIColor(hex: pageGuideHairlineColorHex),
      pageGuideBackgroundColor: UIColor(hex: pageGuideBackgroundColorHex),
      markedTextBackgroundColor: UIColor(hex: markedTextBackgroundColorHex))
    let bg = UIColor(hex: backgroundColor)
    container.backgroundColor = bg
    container.textView.backgroundColor = bg

    let textView = container.textView
    textView.isEditable = editable
    textView.isSelectable = isSelectable
    textView.showLineNumbers = showLineNumbers
    textView.isAutomaticScrollEnabled = automaticScrollEnabled
    textView.verticalOverscrollFactor = CGFloat(verticalOverscrollFactor)
    textView.horizontalOverscrollFactor = CGFloat(horizontalOverscrollFactor)
    textView.autocorrectionType = parsedAutocorrectionType(for: autocorrectionType)
    textView.autocapitalizationType = parsedAutocapitalizationType(for: autocapitalizationType)
    textView.smartQuotesType = parsedSmartQuotesType(for: smartQuotesType)
    textView.smartDashesType = parsedSmartDashesType(for: smartDashesType)
    textView.smartInsertDeleteType = parsedSmartInsertDeleteType(for: smartInsertDeleteType)
    textView.spellCheckingType = parsedSpellCheckingType(for: spellCheckingType)
    textView.keyboardType = parsedKeyboardType(for: keyboardType)
    textView.keyboardAppearance = parsedKeyboardAppearance(for: keyboardAppearance)
    textView.returnKeyType = parsedReturnKeyType(for: returnKeyType)
    textView.insertionPointColor = UIColor(hex: insertionPointColorHex)
    textView.selectionBarColor = UIColor(hex: selectionBarColorHex)
    textView.selectionHighlightColor = UIColor(hex: selectionHighlightColorHex)
    textView.showTabs = showTabs
    textView.showSpaces = showSpaces
    textView.showNonBreakingSpaces = showNonBreakingSpaces
    textView.showLineBreaks = showLineBreaks
    textView.showSoftLineBreaks = showSoftLineBreaks
    textView.tabSymbol = tabSymbol
    textView.spaceSymbol = spaceSymbol
    textView.nonBreakingSpaceSymbol = nonBreakingSpaceSymbol
    textView.lineBreakSymbol = lineBreakSymbol
    textView.softLineBreakSymbol = softLineBreakSymbol
    textView.gutterLeadingPadding = CGFloat(gutterLeadingPadding)
    textView.gutterTrailingPadding = CGFloat(gutterTrailingPadding)
    textView.gutterMinimumCharacterCount = Int(gutterMinimumCharacterCount)
    textView.lineSelectionDisplayType = parsedLineSelectionDisplayType(for: lineSelectionDisplayType)
    textView.isLineWrappingEnabled = isLineWrappingEnabled
    textView.lineBreakMode = parsedLineBreakMode(for: lineBreakMode)
    textView.kern = CGFloat(kern)
    textView.lineHeightMultiplier = CGFloat(lineHeightMultiplier)
    textView.showPageGuide = showPageGuide
    textView.pageGuideColumn = Int(pageGuideColumn)
    textView.lineEndings = parsedLineEnding(for: lineEndings)
    textView.showMenuAfterNavigatingToHighlightedRange = showMenuAfterNavigatingToHighlightedRange
    // iOS 16+ only — `isFindInteractionEnabled` doesn't exist below that.
    if #available(iOS 16.0, *) {
      textView.isFindInteractionEnabled = isFindInteractionEnabled
    }

    if !hasConfigured {
      hasConfigured = true
      container.configure(text: text, language: language, theme: editorTheme)
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
