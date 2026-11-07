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

private func parsedKeyboardDismissMode(for id: String) -> UIScrollView.KeyboardDismissMode {
  switch id {
  case "onDrag": return .onDrag
  case "interactive": return .interactive
  default: return .none
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

private func parsedIndentStrategy(for id: String) -> IndentStrategy {
  let parts = id.split(separator: ":")
  let length = parts.count > 1 ? Int(parts[1]) ?? 4 : 4
  return parts.first == "space" ? .space(length: max(1, length)) : .tab(length: max(1, length))
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

/// What a line command does to the text: replace `range` with `text`, then select `selection`.
struct LineEdit: Equatable {
  var range: NSRange
  var text: String
  var selection: NSRange
}

/// Commands on whole lines (duplicate, move, comment), as pure functions of the text and the selection.
enum LineEditing {
  /// The lines a selection touches, whole: a selection ending just after a line break doesn't take the next line.
  static func block(in text: NSString, selection: NSRange) -> NSRange {
    var probe = selection
    if probe.length > 0 {
      let last = text.character(at: NSMaxRange(probe) - 1)
      if last == 10 || last == 13 { probe.length -= 1 }
    }
    return text.lineRange(for: probe)
  }

  /// A line's text without its line break, and the break (empty on the file's last line).
  static func split(_ line: String) -> (core: String, eol: String) {
    let ns = line as NSString
    var end = ns.length
    if end > 0, ns.character(at: end - 1) == 10 {
      end -= 1
      if end > 0, ns.character(at: end - 1) == 13 { end -= 1 }
    } else if end > 0, ns.character(at: end - 1) == 13 {
      end -= 1
    }
    return (ns.substring(to: end), ns.substring(from: end))
  }

  /// Copies the lines below themselves; the selection moves to the copy.
  static func duplicate(_ text: NSString, selection: NSRange, eol: String) -> LineEdit {
    let b = block(in: text, selection: selection)
    let s = text.substring(with: b)
    let (core, ending) = split(s)
    let inserted = ending.isEmpty ? eol + core : s
    let shift = (inserted as NSString).length
    return LineEdit(
      range: NSRange(location: NSMaxRange(b), length: 0),
      text: inserted,
      selection: NSRange(location: selection.location + shift, length: selection.length))
  }

  /// Swaps the lines with the one above or below; nil at the top or bottom of the file.
  static func move(_ text: NSString, selection: NSRange, up: Bool) -> LineEdit? {
    let b = block(in: text, selection: selection)
    let (bc, be) = split(text.substring(with: b))
    if up {
      guard b.location > 0 else { return nil }
      let prev = text.lineRange(for: NSRange(location: b.location - 1, length: 0))
      let (pc, pe) = split(text.substring(with: prev))
      return LineEdit(
        range: NSRange(location: prev.location, length: NSMaxRange(b) - prev.location),
        text: bc + pe + pc + be,
        selection: NSRange(location: selection.location - prev.length, length: selection.length))
    }
    guard NSMaxRange(b) < text.length else { return nil }
    let next = text.lineRange(for: NSRange(location: NSMaxRange(b), length: 0))
    let (nc, ne) = split(text.substring(with: next))
    return LineEdit(
      range: NSRange(location: b.location, length: NSMaxRange(next) - b.location),
      text: nc + be + bc + ne,
      selection: NSRange(location: selection.location + (nc + be).utf16.count, length: selection.length))
  }

  private static func leadingSpace(_ s: NSString) -> Int {
    var n = 0
    while n < s.length, s.character(at: n) == 32 || s.character(at: n) == 9 { n += 1 }
    return n
  }

  /// Comments the lines with `prefix`, or takes it off when every one already has it. Blank lines are left alone
  /// (unless all are blank). nil when `prefix` is empty.
  static func toggleComment(_ text: NSString, selection: NSRange, prefix: String) -> LineEdit? {
    guard !prefix.isEmpty else { return nil }
    let b = block(in: text, selection: selection)
    var lines: [(core: NSString, eol: String)] = []
    var loc = b.location
    while loc < NSMaxRange(b) {
      let r = text.lineRange(for: NSRange(location: loc, length: 0))
      let (c, e) = split(text.substring(with: r))
      lines.append((c as NSString, e))
      loc = NSMaxRange(r)
    }
    if lines.isEmpty { lines = [("" as NSString, "")] }
    let blank = { (l: NSString) in self.leadingSpace(l) == l.length }
    var targets = lines.indices.filter { !blank(lines[$0].core) }
    if targets.isEmpty { targets = Array(lines.indices) }
    let prefixLength = (prefix as NSString).length
    let uncomment = targets.allSatisfy { i in
      let l = lines[i].core
      let ws = leadingSpace(l)
      return l.length - ws >= prefixLength && l.substring(with: NSRange(location: ws, length: prefixLength)) == prefix
    }
    let indent = targets.map { leadingSpace(lines[$0].core) }.min() ?? 0
    var out = ""
    var caretDelta = 0
    for (i, line) in lines.enumerated() {
      var core = line.core
      if targets.contains(i) {
        if uncomment {
          let ws = leadingSpace(core)
          var removed = prefixLength
          if core.length > ws + prefixLength, core.character(at: ws + prefixLength) == 32 { removed += 1 }
          if selection.length == 0 {
            let offset = selection.location - b.location
            caretDelta = offset >= ws + removed ? -removed : (offset > ws ? ws - offset : 0)
          }
          core = core.replacingCharacters(in: NSRange(location: ws, length: removed), with: "") as NSString
        } else {
          let insert = prefix + " "
          if selection.length == 0 {
            let offset = selection.location - b.location
            caretDelta = offset >= indent ? (insert as NSString).length : 0
          }
          core = core.replacingCharacters(in: NSRange(location: indent, length: 0), with: insert) as NSString
        }
      }
      out += (core as String) + line.eol
    }
    let outLength = (out as NSString).length
    let selected: NSRange
    if selection.length == 0 {
      selected = NSRange(location: max(b.location, selection.location + caretDelta), length: 0)
    } else {
      let trailing = (lines.last?.eol as NSString?)?.length ?? 0
      selected = NSRange(location: b.location, length: outLength - trailing)
    }
    return LineEdit(range: b, text: out, selection: selected)
  }
}

/// The pairs typed brackets and quotes close themselves with (Runestone inserts the closer, steps over it, and wraps a selection).
private struct BracketPair: CharacterPair {
  let leading: String
  let trailing: String
}

private let bracketPairs: [CharacterPair] = [
  BracketPair(leading: "(", trailing: ")"),
  BracketPair(leading: "[", trailing: "]"),
  BracketPair(leading: "{", trailing: "}"),
  BracketPair(leading: "\"", trailing: "\""),
  BracketPair(leading: "`", trailing: "`"),
]

/// Hosts Runestone's `TextView` and tracks dirty state against the buffer it
/// was last `configure`d with (used both for the initial mount and for
/// `setText`, e.g. to restore a known-good state after a failed save).
private final class EditorContainerView: UIView, TextViewDelegate, UIGestureRecognizerDelegate {
  let textView = TextView()
  /// Pinching the text changes its size: `shownFontSize` says what it is now, `applyFontSize` shows another, `onZoomEnd` reports where it stopped.
  var shownFontSize: () -> CGFloat = { 13 }
  var applyFontSize: (CGFloat) -> Void = { _ in }
  var onZoomEnd: (CGFloat) -> Void = { _ in }
  private lazy var pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinched(_:)))
  private var pinchStart: CGFloat = 13
  var isZoomEnabled: Bool {
    get { pinch.isEnabled }
    set { pinch.isEnabled = newValue }
  }

  @objc private func pinched(_ gesture: UIPinchGestureRecognizer) {
    switch gesture.state {
    case .began:
      pinchStart = shownFontSize()
    case .changed:
      // Half-point steps: finer is invisible, and every step re-lays the text out.
      let size = min(40, max(8, (pinchStart * gesture.scale * 2).rounded() / 2))
      if size != shownFontSize() { applyFontSize(size) }
    case .ended, .cancelled:
      onZoomEnd(shownFontSize())
    default:
      break
    }
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
  private var baselineText = ""
  private var isDirty = false
  var onDirtyChange: ((Bool) -> Void)?
  var onSelectionChange: ((Int, Int, Int) -> Void)?
  var onHistoryChange: ((Bool, Bool) -> Void)?
  var onFindChange: ((Bool) -> Void)?
  private var findWatch: Timer?

  /// Tells JS when the find bar is up and when it has gone: UIKit has no event for it that a view can listen to
  /// without becoming the interaction's session delegate (Runestone's), so it is looked at while it is expected to change.
  func watchFind() {
    guard #available(iOS 16.0, *) else { return }
    findWatch?.invalidate()
    var seenOpen = false
    var ticks = 0
    findWatch = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] timer in
      guard let self else { timer.invalidate(); return }
      ticks += 1
      let open = self.textView.findInteraction?.isFindNavigatorVisible ?? false
      if open && !seenOpen {
        seenOpen = true
        self.onFindChange?(true)
      } else if !open && seenOpen {
        timer.invalidate()
        self.findWatch = nil
        self.onFindChange?(false)
      } else if !open && ticks > 20 {
        // It never came up.
        timer.invalidate()
        self.findWatch = nil
      }
    }
  }
  private var lastSelection: (Int, Int, Int)?
  private var lastHistory: (Bool, Bool)?
  private var historyObservers: [NSObjectProtocol] = []

  override init(frame: CGRect) {
    super.init(frame: frame)
    textView.editorDelegate = self
    addSubview(textView)
    pinch.delegate = self
    pinch.isEnabled = false
    textView.addGestureRecognizer(pinch)
    // Undo and redo change what can be undone without the text view being told.
    let center = NotificationCenter.default
    let names: [Notification.Name] = [.NSUndoManagerDidUndoChange, .NSUndoManagerDidRedoChange, .NSUndoManagerDidCloseUndoGroup, .NSUndoManagerCheckpoint]
    historyObservers = names.map { name in
      center.addObserver(forName: name, object: nil, queue: .main) { [weak self] note in
        guard let self, let manager = self.textView.undoManager, note.object as AnyObject? === manager else { return }
        self.reportHistory()
      }
    }
  }

  deinit { historyObservers.forEach(NotificationCenter.default.removeObserver) }

  private func reportHistory() {
    guard let manager = textView.undoManager else { return }
    let now = (manager.canUndo, manager.canRedo)
    guard lastHistory == nil || lastHistory! != now else { return }
    lastHistory = now
    onHistoryChange?(now.0, now.1)
  }

  private func reportSelection() {
    let range = textView.selectedRange
    let at = textView.textLocation(at: range.location)
    let now = ((at?.lineNumber ?? 0) + 1, (at?.column ?? 0) + 1, range.length)
    guard lastSelection == nil || lastSelection! != now else { return }
    lastSelection = now
    onSelectionChange?(now.0, now.1, now.2)
  }

  /// Applies a line command as one undo step and selects what it says.
  private func apply(_ edit: LineEdit?) {
    guard let edit else { return }
    textView.replace(edit.range, withText: edit.text)
    textView.selectedRange = edit.selection
  }

  func duplicateLines() {
    apply(LineEditing.duplicate(textView.text as NSString, selection: textView.selectedRange, eol: textView.lineEndings.symbol))
  }

  func moveLines(up: Bool) {
    apply(LineEditing.move(textView.text as NSString, selection: textView.selectedRange, up: up))
  }

  func toggleComment(prefix: String) {
    apply(LineEditing.toggleComment(textView.text as NSString, selection: textView.selectedRange, prefix: prefix))
  }

  /// Moves the caret as `direction` says, collapsing any selection.
  func moveCursor(_ direction: String) {
    let range = textView.selectedRange
    let text = textView.text as NSString
    switch direction {
    case "left", "right":
      // Over a selection, to its near edge; otherwise one character, whole (an emoji is more than one UTF-16 unit).
      if range.length > 0 {
        textView.selectedRange = NSRange(location: direction == "left" ? range.location : range.location + range.length, length: 0)
        return
      }
      let from = textView.selectedTextRange?.start ?? textView.beginningOfDocument
      guard let to = textView.position(from: from, offset: direction == "left" ? -1 : 1) else { return }
      textView.selectedTextRange = textView.textRange(from: to, to: to)
    case "up", "down":
      let from = (direction == "up" ? textView.selectedTextRange?.start : textView.selectedTextRange?.end) ?? textView.beginningOfDocument
      guard let to = textView.position(from: from, in: direction == "up" ? .up : .down, offset: 1) else { return }
      textView.selectedTextRange = textView.textRange(from: to, to: to)
    case "lineStart":
      textView.selectedRange = NSRange(location: text.lineRange(for: NSRange(location: range.location, length: 0)).location, length: 0)
    case "lineEnd":
      let line = text.lineRange(for: NSRange(location: range.location, length: 0))
      var end = line.location + line.length
      // Before the line's own break, not after it.
      while end > line.location, [10, 13].contains(text.character(at: end - 1)) { end -= 1 }
      textView.selectedRange = NSRange(location: end, length: 0)
    case "documentStart":
      textView.selectedRange = NSRange(location: 0, length: 0)
    case "documentEnd":
      textView.selectedRange = NSRange(location: text.length, length: 0)
    default:
      break
    }
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

  func textViewDidChangeSelection(_ textView: TextView) {
    reportSelection()
  }

  func textViewDidChange(_ textView: TextView) {
    reportSelection()
    reportHistory()
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
  private var editorTheme = EditorTheme()
  private var appliedThemeKey = ""
  private var shownFontSize: CGFloat = 13
  private var hasConfigured = false

  var view: UIView { container }

  override init() {
    super.init()
    container.onDirtyChange = { [weak self] isDirty in
      self?.onChangeDirty(isDirty)
    }
    container.onSelectionChange = { [weak self] line, column, length in
      self?.onChangeSelection(Double(line), Double(column), Double(length))
    }
    container.onHistoryChange = { [weak self] canUndo, canRedo in
      self?.onChangeHistory(canUndo, canRedo)
    }
    container.onFindChange = { [weak self] isOpen in
      self?.onChangeFind(isOpen)
    }
    container.shownFontSize = { [weak self] in self?.shownFontSize ?? 13 }
    container.applyFontSize = { [weak self] size in self?.applyTheme(fontSize: size, replacing: true) }
    container.onZoomEnd = { [weak self] size in self?.onChangeFontSize(Double(size)) }
  }

  var text: String = ""
  var language: String = "plaintext"
  var editable: Bool = true
  var syntaxColorsJson: String = "{}"
  var backgroundColor: String = "#000000"
  var textColor: String = "#ffffff"
  var fontSizePx: Double = 13
  var indentStrategy: String = "tab:4"
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
  var keyboardDismissMode: String = "interactive"
  var returnKeyType: String = "default"
  var insertionPointColorHex: String = "#ffffff"
  var selectionBarColorHex: String = "#ffffff"
  var selectionHighlightColorHex: String = "#3399ff33"
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
  var onChangeSelection: (_ line: Double, _ column: Double, _ length: Double) -> Void = { _, _, _ in }
  var onChangeHistory: (_ canUndo: Bool, _ canRedo: Bool) -> Void = { _, _ in }
  var onChangeFind: (_ isOpen: Bool) -> Void = { _ in }
  var onChangeFontSize: (_ fontSizePx: Double) -> Void = { _ in }
  var pinchToZoom: Bool = false
  var autoClosePairs: Bool = false

  private func applyTheme(fontSize: CGFloat, replacing: Bool) {
    // Runestone ignores a theme that is the one it already has, so a change is a new object.
    if replacing { editorTheme = EditorTheme() }
    shownFontSize = fontSize
    editorTheme.configure(
      syntaxColorsJson: syntaxColorsJson,
      textColor: UIColor(hex: textColor),
      fontSizePx: fontSize,
      gutterBackgroundColor: UIColor(hex: gutterBackgroundColorHex),
      gutterHairlineColor: UIColor(hex: gutterHairlineColorHex),
      selectedLineBackgroundColor: UIColor(hex: selectedLineBackgroundColorHex),
      selectedLinesGutterBackgroundColor: UIColor(hex: selectedLinesGutterBackgroundColorHex),
      invisibleCharactersColor: UIColor(hex: invisibleCharactersColorHex),
      pageGuideHairlineColor: UIColor(hex: pageGuideHairlineColorHex),
      pageGuideBackgroundColor: UIColor(hex: pageGuideBackgroundColorHex),
      markedTextBackgroundColor: UIColor(hex: markedTextBackgroundColorHex))
    if replacing {
      container.textView.theme = editorTheme
      // The theme only marks lines stale; this lays out the ones on screen now (the rest follow as they scroll in).
      container.textView.redisplayVisibleLines()
    }
  }

  func afterUpdate() {
    let themeKey = [syntaxColorsJson, textColor, String(fontSizePx), gutterBackgroundColorHex, gutterHairlineColorHex,
                    selectedLineBackgroundColorHex, selectedLinesGutterBackgroundColorHex, invisibleCharactersColorHex,
                    pageGuideHairlineColorHex, pageGuideBackgroundColorHex, markedTextBackgroundColorHex].joined(separator: "|")
    if themeKey != appliedThemeKey {
      appliedThemeKey = themeKey
      applyTheme(fontSize: CGFloat(fontSizePx), replacing: hasConfigured)
    }
    container.isZoomEnabled = pinchToZoom
    let bg = UIColor(hex: backgroundColor)
    container.backgroundColor = bg
    container.textView.backgroundColor = bg

    let textView = container.textView
    textView.isEditable = editable
    textView.isSelectable = isSelectable
    textView.indentStrategy = parsedIndentStrategy(for: indentStrategy)
    textView.showLineNumbers = showLineNumbers
    textView.characterPairs = autoClosePairs ? bracketPairs : []
    textView.characterPairTrailingComponentDeletionMode = autoClosePairs ? .immediatelyFollowingLeadingComponent : .disabled
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
    // `TextView` is a `UIScrollView`, so this is its own scroll-to-dismiss.
    textView.keyboardDismissMode = parsedKeyboardDismissMode(for: keyboardDismissMode)
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

  // Nitro calls these on the JS thread; UIKit's text input must be driven from the main one (off it, the keyboard's task queue asserts and aborts).
  private func onMain(_ work: @escaping () -> Void) {
    if Thread.isMainThread { work() } else { DispatchQueue.main.async(execute: work) }
  }

  func insertText(text: String) throws { onMain { [weak self] in self?.container.textView.insertText(text) } }
  func undo() throws { onMain { [weak self] in self?.container.textView.undoManager?.undo() } }
  func redo() throws { onMain { [weak self] in self?.container.textView.undoManager?.redo() } }
  func tab() throws {
    onMain { [weak self] in
      guard let textView = self?.container.textView else { return }
      let range = textView.selectedRange
      let text = textView.text as NSString
      let line = text.lineRange(for: NSRange(location: range.location, length: 0))
      let before = text.substring(with: NSRange(location: line.location, length: range.location - line.location))
      if range.length > 0 || before.allSatisfy({ $0 == " " || $0 == "\t" }) {
        textView.shiftRight()
      } else {
        switch textView.indentStrategy {
        case .tab: textView.insertText("\t")
        case .space(let length): textView.insertText(String(repeating: " ", count: length))
        }
      }
    }
  }
  func indent() throws { onMain { [weak self] in self?.container.textView.shiftRight() } }
  /// Takes one level of indentation off every selected line (the caret's line for a caret). Runestone's own
  /// `shiftLeft` does nothing unless the line starts with exactly its indent string, so a file that mixes tabs and
  /// spaces, or indents by another width, never moved: this removes a tab, or up to one level of spaces, whatever the line has.
  func outdent() throws {
    onMain { [weak self] in
      guard let textView = self?.container.textView else { return }
      let text = textView.text as NSString
      let selection = textView.selectedRange
      let lines = text.lineRange(for: selection)
      let level: Int
      switch textView.indentStrategy {
      case .tab(let length): level = length
      case .space(let length): level = length
      }
      var result = ""
      var removedFirst = 0
      var removedTotal = 0
      var cursor = lines.location
      var first = true
      while cursor < lines.location + lines.length {
        let line = text.lineRange(for: NSRange(location: cursor, length: 0))
        let string = text.substring(with: line)
        var remove = 0
        if string.hasPrefix("\t") {
          remove = 1
        } else {
          for character in string.prefix(level) { if character == " " { remove += 1 } else { break } }
        }
        result += String(string.dropFirst(remove))
        removedTotal += remove
        if first { removedFirst = remove; first = false }
        cursor = line.location + line.length
      }
      guard removedTotal > 0 else { return }
      let start = max(lines.location, selection.location - removedFirst)
      let end = max(start, selection.location + selection.length - removedTotal)
      textView.replace(lines, withText: result)
      textView.selectedRange = NSRange(location: start, length: selection.length == 0 ? 0 : end - start)
    }
  }
  func moveCursor(direction: String) throws { onMain { [weak self] in self?.container.moveCursor(direction) } }
  func duplicateLines() throws { onMain { [weak self] in self?.container.duplicateLines() } }
  func moveLines(direction: String) throws { onMain { [weak self] in self?.container.moveLines(up: direction == "up") } }
  func toggleComment(prefix: String) throws { onMain { [weak self] in self?.container.toggleComment(prefix: prefix) } }

  func applyLanguage(language: String) throws {
    onMain { [weak self] in
      guard let self else { return }
      self.language = language
      let mode: LanguageMode = treeSitterLanguage(for: language).map { TreeSitterLanguageMode(language: $0) } ?? PlainTextLanguageMode()
      self.container.textView.setLanguageMode(mode)
    }
  }

  func showFind(replace: Bool) throws {
    onMain { [weak self] in
      guard let self else { return }
      if #available(iOS 16.0, *) {
        self.container.textView.findInteraction?.presentFindNavigator(showingReplace: replace)
        self.container.watchFind()
      }
    }
  }

  func goToLine(line: Double) throws {
    onMain { [weak self] in
      guard let self else { return }
      let textView = self.container.textView
      // Runestone counts lines from 0 and refuses one past the end: clamp to the last.
      let last = max(0, (textView.text as NSString).components(separatedBy: "\n").count - 1)
      textView.goToLine(min(max(0, Int(line) - 1), last))
    }
  }

  func writeBuffer(text: String) throws {
    self.text = text
    container.configure(text: text, language: language, theme: editorTheme)
  }
}
