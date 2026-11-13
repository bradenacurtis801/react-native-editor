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

  /// A copy that nothing changes, for work on another queue.
  func snapshot() -> EditorTheme {
    let copy = EditorTheme()
    copy.font = font
    copy.textColor = textColor
    copy.gutterBackgroundColor = gutterBackgroundColor
    copy.gutterHairlineColor = gutterHairlineColor
    copy.lineNumberColor = lineNumberColor
    copy.lineNumberFont = lineNumberFont
    copy.selectedLineBackgroundColor = selectedLineBackgroundColor
    copy.selectedLinesLineNumberColor = selectedLinesLineNumberColor
    copy.selectedLinesGutterBackgroundColor = selectedLinesGutterBackgroundColor
    copy.invisibleCharactersColor = invisibleCharactersColor
    copy.pageGuideHairlineColor = pageGuideHairlineColor
    copy.pageGuideBackgroundColor = pageGuideBackgroundColor
    copy.markedTextBackgroundColor = markedTextBackgroundColor
    copy.syntaxColors = syntaxColors
    return copy
  }

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

/// Which match of a find is the current one: pure, so it is checked off the device.
enum FindNav {
  /// The first match that starts at or after `location`, wrapping to the first; nil with none.
  static func start(_ matches: [NSRange], from location: Int) -> Int? {
    if matches.isEmpty { return nil }
    return matches.firstIndex { $0.location >= location } ?? 0
  }

  /// The match after `current`, or the first one at or after the selection when the selection is not on `current` (the caret was moved).
  static func next(_ matches: [NSRange], current: Int, selection: NSRange) -> Int? {
    if matches.isEmpty { return nil }
    if current >= 0, current < matches.count, matches[current] == selection { return (current + 1) % matches.count }
    return matches.firstIndex { $0.location >= selection.location } ?? 0
  }

  /// The match before `current`, or the last one before the selection when the selection is not on `current`.
  static func previous(_ matches: [NSRange], current: Int, selection: NSRange) -> Int? {
    if matches.isEmpty { return nil }
    if current >= 0, current < matches.count, matches[current] == selection { return (current - 1 + matches.count) % matches.count }
    return matches.lastIndex { $0.location < selection.location } ?? matches.count - 1
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
  var onScroll: ((Int, Int, Int) -> Void)?
  let minimap = MinimapView()
  /// Made on the main thread when the minimap is drawn: highlights a text with the language and colours as they are now, or nil for none.
  var minimapColorizer: (() -> ((String) -> NSAttributedString?)?)?
  private var minimapRefresh: DispatchWorkItem?
  /// `nil` is no minimap.
  var minimapMode: MinimapView.Mode? {
    didSet {
      guard minimapMode != oldValue else { return }
      lastMap = nil
      minimap.isHidden = minimapMode == nil
      if let minimapMode { minimap.mode = minimapMode }
      setNeedsLayout()
      refreshMinimap()
      reportScroll()
    }
  }
  private var lastScroll: (Int, Int, Int)?
  private var lineCount = 1
  private var scrollObserver: NSKeyValueObservation?
  private var lastHistory: (Bool, Bool)?
  private var historyObservers: [NSObjectProtocol] = []

  override init(frame: CGRect) {
    super.init(frame: frame)
    textView.editorDelegate = self
    addSubview(textView)
    scrollObserver = textView.observe(\.contentOffset) { [weak self] _, _ in self?.reportScroll() }
    addSubview(minimap)
    minimap.isHidden = true
    minimap.onScrub = { [weak self] row, centered in self?.scrub(toLine: row, centered: centered) }
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

  /// The lines at the top and bottom of what shows, and how many there are, told to JS when any of them changes.
  /// Found by asking the text which line is under the top and the bottom edge (not from the text itself).
  /// The 1-based line at `y` in the content. From the line heights, not a hit test: a hit test only knows lines that are laid out, and
  /// when the scroll position changes the lines it moved to are not laid out yet.
  private func line(atY y: CGFloat) -> Int {
    textView.lineNumber(atContentOffsetY: y) + 1
  }

  private var lastMap: (Int, Int, Int)?

  private func reportScroll() {
    guard onScroll != nil || minimapMode != nil, textView.bounds.height > 0 else { return }
    let inset = textView.adjustedContentInset
    let top = line(atY: textView.contentOffset.y + inset.top)
    if minimapMode != nil { reportMinimapViewport(top: top, inset: inset) }
    guard onScroll != nil else { return }
    let bottom = max(top, line(atY: textView.contentOffset.y + textView.bounds.height - inset.bottom - 1))
    let now = (top, min(bottom, lineCount), lineCount)
    guard lastScroll == nil || lastScroll! != now else { return }
    lastScroll = now
    onScroll?(now.0, now.1, now.2)
  }

  /// Tells the minimap where the window is: its top line, how many lines it holds (an average line, wrapped rows and all, so blank space
  /// after the end counts too), and the top line when scrolled as far as it goes.
  private func reportMinimapViewport(top: Int, inset: UIEdgeInsets) {
    let average = max(textView.linesHeight / CGFloat(max(textView.lineCount, 1)), 1)
    let capacity = Double((textView.bounds.height - inset.top - inset.bottom) / average)
    let lowest = max(textView.contentSize.height - textView.bounds.height + inset.bottom, -inset.top)
    let maxTop = max(line(atY: lowest + inset.top), top)
    let now = (top, Int(capacity * 10), maxTop)
    guard lastMap == nil || lastMap! != now else { return }
    lastMap = now
    minimap.setViewport(top: top, capacity: capacity, maxTop: maxTop)
  }

  /// Draws the minimap again from the text and the lines' kinds, shortly after the last change.
  func refreshMinimap() {
    guard minimapMode != nil else { return }
    minimapRefresh?.cancel()
    let work = DispatchWorkItem { [weak self] in self?.drawMinimap() }
    minimapRefresh = work
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: work)
  }

  private func drawMinimap() {
    guard minimapMode != nil else { return }
    let kinds = (0 ..< lineCount).map { textView.lineDecoration(atRow: $0) }
    var tints: [Int: UIColor] = [:]
    for (kind, style) in textView.lineDecorationStyles {
      if let color = style.gutterBackground ?? style.background { tints[kind] = color }
    }
    minimap.update(text: textView.text, kinds: kinds, tints: tints, colorize: minimapColorizer?())
  }

  /// Scrolls so the 0-based `row` is in the middle of the view, or at the top of it.
  private func scrub(toLine row: Int, centered: Bool) {
    let inset = textView.adjustedContentInset
    let lowest = max(-inset.top, textView.contentSize.height - textView.bounds.height + inset.bottom)
    let lineTop = textView.contentOffsetY(ofLine: row)
    let wanted = centered ? lineTop - textView.bounds.height / 2 : lineTop - inset.top
    let y = min(max(wanted, -inset.top), lowest)
    textView.contentOffset = CGPoint(x: textView.contentOffset.x, y: y)
  }

  private func refreshLineCount(of text: String) {
    lineCount = (textView.textLocation(at: (text as NSString).length)?.lineNumber ?? 0) + 1
    refreshMinimap()
    reportScroll()
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

  // MARK: Find

  /// The find in progress: its query, every match, and which one is current (0-based, -1 for none).
  private var findQuery: SearchQuery?
  private var findMatches: [NSRange] = []
  private var findIndex = -1
  private var findRefresh: DispatchWorkItem?
  var findColor = UIColor(hex: "#ffd60a55")
  var findCurrentColor = UIColor(hex: "#ff9f0aaa")
  /// The number of matches and the current one, 1-based (0 when there is none).
  var onFindResult: ((Int, Int) -> Void)?

  private func matchMethod(_ name: String) -> SearchQuery.MatchMethod {
    switch name {
    case "fullWord": return .fullWord
    case "startsWith": return .startsWith
    case "endsWith": return .endsWith
    case "regex": return .regularExpression
    default: return .contains
    }
  }

  /// Searches again (after the query or the text changed) and shows the result; `select` also moves the selection to the current match.
  private func runFind(from location: Int, select: Bool) {
    guard let query = findQuery else { return }
    // A pattern that can match nothing (`a*`) would "find" empty ranges everywhere.
    findMatches = textView.search(for: query).map(\.range).filter { $0.length > 0 }
    findIndex = FindNav.start(findMatches, from: location) ?? -1
    showFind(select: select)
  }

  private func showFind(select: Bool) {
    textView.highlightedRanges = findMatches.enumerated().map { i, range in
      HighlightedRange(range: range, color: i == findIndex ? findCurrentColor : findColor, cornerRadius: 3)
    }
    if select, findIndex >= 0 {
      let range = findMatches[findIndex]
      textView.selectedRange = range
      textView.scrollRangeToVisible(range)
    }
    onFindResult?(findMatches.count, findIndex + 1)
  }

  func find(query: String, method: String, caseSensitive: Bool) {
    guard !query.isEmpty else { clearFind(); return }
    findQuery = SearchQuery(text: query, matchMethod: matchMethod(method), isCaseSensitive: caseSensitive)
    runFind(from: textView.selectedRange.location, select: true)
  }

  func findStep(forward: Bool) {
    guard findQuery != nil, !findMatches.isEmpty else { return }
    let selection = textView.selectedRange
    let target = forward
      ? FindNav.next(findMatches, current: findIndex, selection: selection)
      : FindNav.previous(findMatches, current: findIndex, selection: selection)
    guard let target else { return }
    findIndex = target
    showFind(select: true)
  }

  /// Replaces the current match (one undo step) and moves on to the next.
  func replaceCurrent(with replacement: String) {
    guard let query = findQuery, findIndex >= 0, findIndex < findMatches.count else { return }
    let results = textView.search(for: query, replacingMatchesWith: replacement).filter { $0.range.length > 0 }
    guard findIndex < results.count else { return }
    let result = results[findIndex]
    textView.replace(result.range, withText: result.replacementText)
    runFind(from: result.range.location + (result.replacementText as NSString).length, select: true)
  }

  /// Replaces every match in one undo step.
  func replaceAll(with replacement: String) {
    guard let query = findQuery else { return }
    let results = textView.search(for: query, replacingMatchesWith: replacement).filter { $0.range.length > 0 }
    guard !results.isEmpty else { return }
    textView.replaceText(in: BatchReplaceSet(replacements: results.map { .init(range: $0.range, text: $0.replacementText) }))
    runFind(from: 0, select: false)
  }

  func clearFind() {
    findRefresh?.cancel()
    findQuery = nil
    findMatches = []
    findIndex = -1
    textView.highlightedRanges = []
    onFindResult?(0, 0)
  }

  /// The text changed under a find: its matches are looked for again once typing pauses, without moving the selection.
  private func refreshFindSoon() {
    guard findQuery != nil else { return }
    findRefresh?.cancel()
    let work = DispatchWorkItem { [weak self] in
      guard let self else { return }
      self.runFind(from: self.textView.selectedRange.location, select: false)
    }
    findRefresh = work
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: work)
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
    let mapWidth = minimapMode?.width ?? 0
    textView.frame = CGRect(x: 0, y: 0, width: bounds.width - mapWidth, height: bounds.height)
    minimap.frame = CGRect(x: bounds.width - mapWidth, y: 0, width: mapWidth, height: bounds.height)
  }

  func configure(text: String, language: String, theme: EditorTheme) {
    baselineText = text
    if isDirty { isDirty = false; onDirtyChange?(false) }
    let state = treeSitterLanguage(for: language).map { TextViewState(text: text, theme: theme, language: $0) }
      ?? TextViewState(text: text, theme: theme)
    textView.setState(state)
    refreshLineCount(of: text)
  }

  func textViewDidChangeSelection(_ textView: TextView) {
    reportSelection()
  }

  func textViewDidChange(_ textView: TextView) {
    reportSelection()
    reportHistory()
    refreshFindSoon()
    let current = textView.text
    refreshLineCount(of: current)
    let dirty = current != baselineText
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
  private var appliedDecorationKey = ""
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
    container.onScroll = { [weak self] top, bottom, count in self?.onChangeScroll(Double(top), Double(bottom), Double(count)) }
    container.minimapColorizer = { [weak self] in
      guard let self, let language = treeSitterLanguage(for: self.language) else { return nil }
      let theme = self.editorTheme.snapshot()
      return { text in
        // A very large file stays one colour rather than being parsed again and again.
        guard text.utf16.count <= 400_000 else { return nil }
        return StringSyntaxHighlighter(theme: theme, language: language).syntaxHighlight(text)
      }
    }
    container.onFindResult = { [weak self] count, index in
      self?.onChangeFindResult(Double(count), Double(index))
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
  var onChangeFindResult: (_ count: Double, _ index: Double) -> Void = { _, _ in }
  var findColorHex: String = "#ffd60a55"
  var findCurrentColorHex: String = "#ff9f0aaa"
  var onChangeFind: (_ isOpen: Bool) -> Void = { _ in }
  var onChangeFontSize: (_ fontSizePx: Double) -> Void = { _ in }
  var minimap: String = "off"
  var lineStylesJson: String = "{}"
  var newLineKindsJson: String = "{}"
  var onChangeScroll: (_ topLine: Double, _ bottomLine: Double, _ lineCount: Double) -> Void = { _, _, _ in }
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
      container.refreshMinimap()
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
    container.findColor = UIColor(hex: findColorHex)
    container.findCurrentColor = UIColor(hex: findCurrentColorHex)
    // iOS 16+ only — `isFindInteractionEnabled` doesn't exist below that.
    if #available(iOS 16.0, *) {
      textView.isFindInteractionEnabled = isFindInteractionEnabled
    }
    container.minimapMode = parsedMinimapMode(for: minimap)
    let barBase = UIColor(hex: textColor)
    container.minimap.barColor = barBase.withAlphaComponent(0.45)
    container.minimap.sliderColor = barBase.withAlphaComponent(0.18)
    let decorationKey = lineStylesJson + "|" + newLineKindsJson
    if decorationKey != appliedDecorationKey {
      appliedDecorationKey = decorationKey
      applyLineDecorationStyles()
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

  func findText(query: String, method: String, caseSensitive: Bool) throws {
    onMain { [weak self] in self?.container.find(query: query, method: method, caseSensitive: caseSensitive) }
  }
  func findNext() throws { onMain { [weak self] in self?.container.findStep(forward: true) } }
  func findPrevious() throws { onMain { [weak self] in self?.container.findStep(forward: false) } }
  func replaceMatch(replacement: String) throws { onMain { [weak self] in self?.container.replaceCurrent(with: replacement) } }
  func replaceAllMatches(replacement: String) throws { onMain { [weak self] in self?.container.replaceAll(with: replacement) } }
  func clearFind() throws { onMain { [weak self] in self?.container.clearFind() } }

  func applyLanguage(language: String) throws {
    onMain { [weak self] in
      guard let self else { return }
      self.language = language
      let mode: LanguageMode = treeSitterLanguage(for: language).map { TreeSitterLanguageMode(language: $0) } ?? PlainTextLanguageMode()
      self.container.textView.setLanguageMode(mode)
      self.container.refreshMinimap()
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

  /// The line kinds' colours and what a new line's kind is, from the two JSON props.
  private func applyLineDecorationStyles() {
    var styles: [Int: LineDecorationStyle] = [:]
    if let data = lineStylesJson.data(using: .utf8),
       let object = try? JSONSerialization.jsonObject(with: data) as? [String: [String: String]] {
      for (key, value) in object {
        guard let kind = Int(key) else { continue }
        styles[kind] = LineDecorationStyle(
          background: value["background"].map { UIColor(hex: $0) },
          gutterBackground: value["gutterBackground"].map { UIColor(hex: $0) })
      }
    }
    var newKinds: [Int: Int] = [:]
    if let data = newLineKindsJson.data(using: .utf8),
       let object = try? JSONSerialization.jsonObject(with: data) as? [String: Int] {
      for (key, value) in object {
        if let kind = Int(key) { newKinds[kind] = value }
      }
    }
    let textView = container.textView
    textView.lineDecorationForNewLine = { newKinds[$0] ?? $0 }
    textView.lineDecorationStyles = styles
    container.refreshMinimap()
  }

  private func parsedMinimapMode(for value: String) -> MinimapView.Mode? {
    switch value {
    case "strip": return .strip
    case "compact": return .compact
    case "full": return .full
    default: return nil
    }
  }

  func setLineKinds(runs: [Double]) throws {
    onMain { [weak self] in
      guard let self else { return }
      var parsed: [LineDecorationRun] = []
      var index = 0
      while index + 2 < runs.count {
        parsed.append(LineDecorationRun(firstRow: Int(runs[index]) - 1, count: Int(runs[index + 1]), kind: Int(runs[index + 2])))
        index += 3
      }
      self.container.textView.setLineDecorations(parsed)
      self.container.refreshMinimap()
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
