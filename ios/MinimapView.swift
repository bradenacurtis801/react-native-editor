import UIKit

/// The file in miniature down the editor's right edge, with a slider over the lines that show; touching or dragging it scrolls there.
///
/// `.full` (and `.compact`, the same in less width) is VS Code's minimap: every line a fixed two points tall with a bar for its text, so only a window of a long file fits,
/// and the window scrolls along with the editor (the slider stays inside it). It is drawn in chunks of lines, only those near the
/// window and only when they are needed, so a file of any length costs a few bitmaps.
/// `.strip` is narrow and shows the whole file squeezed to fit, as marks only (like VS Code's overview ruler).
///
/// One line is one row, by line number — not by pixels, which depend on line heights that are only estimates until a line has been
/// laid out. Pictures are drawn off the main thread; scrolling only moves layers.
final class MinimapView: UIView {
  enum Mode: Equatable {
    /// Marks and the slider only, narrow, the whole file.
    case strip
    /// The real minimap in less room, for a phone: words as far as its width goes.
    case compact
    /// Bars for the text as well, a window that scrolls with the editor.
    case full

    var width: CGFloat {
      switch self {
      case .strip: return 12
      case .compact: return 48
      case .full: return 72
      }
    }
  }

  var mode: Mode = .full {
    didSet {
      guard mode != oldValue else { return }
      removeAllChunks()
      stripLayer.contents = nil
      invalidate()
    }
  }
  /// The bars' colour.
  var barColor = UIColor.gray.withAlphaComponent(0.45) {
    didSet { if barColor != oldValue { invalidate() } }
  }
  /// The slider's colour.
  var sliderColor = UIColor.gray.withAlphaComponent(0.2) {
    didSet {
      sliderLayer.backgroundColor = sliderColor.cgColor
      sliderLayer.borderColor = sliderColor.withAlphaComponent(0.6).cgColor
    }
  }
  /// Where the finger is, as a 0-based line: `centered` says to put it in the middle of the editor, otherwise at the top.
  var onScrub: ((_ line: Int, _ centered: Bool) -> Void)?

  /// What a line looks like from far away.
  private struct Shapes {
    /// The words of line `i` are `lineWord[i] ..< lineWord[i + 1]` of the arrays below: a stretch of text with no space in it and one
    /// colour — where it starts (columns, a tab counted as four), how many columns it runs, and its colour in `palette`.
    var lineWord: [Int] = [0]
    var wordStart: [UInt16] = []
    var wordLength: [UInt16] = []
    var wordColor: [UInt8] = []
    var palette: [UIColor] = []
    var kinds: [Int] = []
    var tints: [Int: UIColor] = [:]
    var count: Int { lineWord.count - 1 }
  }

  private let content = CALayer()
  private let stripLayer = CALayer()
  private let sliderLayer = CALayer()
  private let queue = DispatchQueue(label: "react-native-editor.minimap", qos: .userInitiated)
  private let displayScale = UIScreen.main.scale
  private var shapes = Shapes()
  /// Bumped whenever what is drawn is out of date; a picture that comes back from an older one is dropped.
  private var generation = 0
  /// The editor's window: its first line (1-based), how many lines it holds (blank space after the end counts, so this may be
  /// more than there are), and the first line when it is scrolled as far as it goes.
  private var viewport: (top: Int, capacity: Double, maxTop: Int)?
  private var chunks: [Int: CALayer] = [:]
  private var drawnSize = CGSize.zero

  /// `.full`: points a line takes, and lines in a chunk of the picture.
  private static let fullRowHeight: CGFloat = 2
  private static let chunkLines = 400

  override init(frame: CGRect) {
    super.init(frame: frame)
    isOpaque = false
    clipsToBounds = true
    isAccessibilityElement = false
    stripLayer.contentsGravity = .topLeft
    stripLayer.contentsScale = displayScale
    sliderLayer.backgroundColor = sliderColor.cgColor
    sliderLayer.cornerRadius = 2
    sliderLayer.borderWidth = 1
    sliderLayer.borderColor = sliderColor.withAlphaComponent(0.6).cgColor
    layer.addSublayer(content)
    layer.addSublayer(stripLayer)
    layer.addSublayer(sliderLayer)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func layoutSubviews() {
    super.layoutSubviews()
    if bounds.size != drawnSize {
      drawnSize = bounds.size
      invalidate()
    }
    layoutMap()
  }

  /// The text and what each line is (`kinds`, a `tints` colour per kind that has one): the lines are scanned in the background and
  /// the pictures drawn again. A newer call overtakes an older one still scanning.
  func update(text: String, kinds: [Int], tints: [Int: UIColor], colorize: ((String) -> NSAttributedString?)? = nil) {
    generation += 1
    let current = generation
    queue.async { [weak self] in
      // A newer change has come in already: don't spend the time on this one.
      if let self, self.generation != current { return }
      var next = Self.scan(text, colored: colorize?(text))
      next.kinds = kinds
      next.tints = tints
      DispatchQueue.main.async {
        guard let self, self.generation == current else { return }
        self.shapes = next
        self.invalidate()
      }
    }
  }

  /// The editor's window: the first line showing (1-based), how many lines it holds, and the first line it can be scrolled to.
  func setViewport(top: Int, capacity: Double, maxTop: Int) {
    viewport = (top, capacity, maxTop)
    layoutMap()
  }

  // MARK: Geometry

  private var rowHeight: CGFloat {
    if mode != .strip { return Self.fullRowHeight }
    return shapes.count > 0 ? min(2, bounds.height / CGFloat(shapes.count)) : 2
  }

  /// Lines the map covers: the file, and the blank space the editor can scroll into after its end — so the slider can go there too.
  private var mapLines: Double {
    guard let viewport, mode != .strip else { return Double(shapes.count) }
    return max(Double(shapes.count), Double(viewport.maxTop - 1) + viewport.capacity)
  }

  private var contentHeight: CGFloat { CGFloat(mapLines) * rowHeight }

  private var sliderHeight: CGFloat { max(CGFloat(viewport?.capacity ?? 1) * rowHeight, 14) }

  /// How far the map is scrolled: none when it fits, else in step with how far along the editor is, so the slider is always inside it.
  private var offset: CGFloat {
    guard let viewport, mode != .strip, contentHeight > bounds.height else { return 0 }
    let span = viewport.maxTop - 1
    let progress = span > 0 ? min(max(CGFloat(viewport.top - 1) / CGFloat(span), 0), 1) : 0
    return progress * (contentHeight - bounds.height)
  }

  private var chunkHeight: CGFloat { CGFloat(Self.chunkLines) * Self.fullRowHeight }

  private func layoutMap() {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    defer { CATransaction.commit() }
    guard shapes.count > 0 else {
      sliderLayer.isHidden = true
      return
    }
    let shift = offset
    content.frame = CGRect(x: 0, y: -shift, width: bounds.width, height: contentHeight)
    stripLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
    stripLayer.isHidden = mode != .strip
    content.isHidden = mode == .strip
    if mode != .strip { refreshChunks(visibleFrom: shift, to: shift + bounds.height) }
    guard let viewport else {
      sliderLayer.isHidden = true
      return
    }
    let height = sliderHeight
    let top = CGFloat(max(viewport.top - 1, 0)) * rowHeight - shift
    sliderLayer.isHidden = false
    sliderLayer.frame = CGRect(x: 0, y: min(max(top, 0), max(bounds.height - height, 0)), width: bounds.width, height: height)
  }

  // MARK: Drawing

  /// What is on screen is out of date (new text, a new size, other colours): draws it again, keeping the old picture till the new one is in.
  private func invalidate() {
    generation += 1
    guard shapes.count > 0, bounds.width > 0 else { return }
    if mode == .strip {
      drawStrip()
    } else {
      for index in chunks.keys { drawChunk(index) }
    }
    layoutMap()
  }

  private func drawStrip() {
    let current = generation
    let snapshot = shapes
    let size = bounds.size
    let scale = displayScale
    let bar = barColor
    queue.async { [weak self] in
      let image = Self.renderWholeFile(snapshot, size: size, scale: scale, bar: bar)
      DispatchQueue.main.async {
        guard let self, self.generation == current else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.stripLayer.contents = image
        CATransaction.commit()
      }
    }
  }

  /// Makes layers for the chunks near the part showing and drops the ones that are far away.
  private func refreshChunks(visibleFrom top: CGFloat, to bottom: CGFloat) {
    let count = (shapes.count + Self.chunkLines - 1) / Self.chunkLines
    let first = max(0, Int(top / chunkHeight) - 1)
    let last = min(count - 1, Int(bottom / chunkHeight) + 1)
    for index in chunks.keys where index < first || index > last {
      chunks[index]?.removeFromSuperlayer()
      chunks[index] = nil
    }
    guard first <= last else { return }
    for index in first ... last {
      if chunks[index] == nil {
        let layer = CALayer()
        layer.contentsGravity = .topLeft
        layer.contentsScale = displayScale
        content.addSublayer(layer)
        chunks[index] = layer
        drawChunk(index)
      }
      let from = index * Self.chunkLines
      let lines = min(shapes.count, from + Self.chunkLines) - from
      chunks[index]?.frame = CGRect(x: 0, y: CGFloat(from) * Self.fullRowHeight, width: bounds.width, height: CGFloat(lines) * Self.fullRowHeight)
    }
  }

  private func removeAllChunks() {
    for layer in chunks.values { layer.removeFromSuperlayer() }
    chunks = [:]
  }

  private func drawChunk(_ index: Int) {
    let current = generation
    let snapshot = shapes
    let width = bounds.width
    let scale = displayScale
    let mode = self.mode
    let bar = barColor
    queue.async { [weak self] in
      let image = Self.renderChunk(snapshot, chunk: index, width: width, scale: scale, mode: mode, bar: bar)
      DispatchQueue.main.async {
        guard let self, self.generation == current, let layer = self.chunks[index] else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.contents = image
        CATransaction.commit()
      }
    }
  }

  // MARK: Touch

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { scrub(touches) }
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { scrub(touches) }

  private func scrub(_ touches: Set<UITouch>) {
    guard let touch = touches.first, shapes.count > 0 else { return }
    let y = touch.location(in: self).y
    guard contentHeight > bounds.height else {
      // All of it fits: the line under the finger goes to the middle.
      onScrub?(min(max(Int(y / rowHeight), 0), shapes.count - 1), true)
      return
    }
    // The map is scrolled with the editor, so the finger sets how far along the file it is, as on a scroll bar, with the slider under it.
    let track = bounds.height - sliderHeight
    let progress = track > 0 ? min(max((y - sliderHeight / 2) / track, 0), 1) : 0
    let maxTop = viewport?.maxTop ?? shapes.count
    onScrub?(Int((progress * CGFloat(max(maxTop - 1, 0))).rounded()), false)
  }

  // MARK: Work off the main thread

  /// Per line, its words: where each starts, how far it runs and what colour it is (from `colored`, the text highlighted; none = one colour).
  private static func scan(_ text: String, colored: NSAttributedString?) -> Shapes {
    var shapes = Shapes()
    // The colour of each stretch of the text, as an index into the palette.
    var runs: [(end: Int, color: UInt8)] = []
    if let colored, colored.length > 0 {
      colored.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: colored.length), options: []) { value, range, _ in
        let color = (value as? UIColor) ?? UIColor.gray
        var index = shapes.palette.firstIndex(of: color)
        if index == nil, shapes.palette.count < 255 {
          shapes.palette.append(color)
          index = shapes.palette.count - 1
        }
        runs.append((range.location + range.length, UInt8(index ?? 0)))
      }
    }
    var run = 0
    var column = 0
    var wordStart = -1
    var wordColor: UInt8 = 0
    var previousWasReturn = false

    func endWord() {
      guard wordStart >= 0 else { return }
      shapes.wordStart.append(UInt16(clamping: wordStart))
      shapes.wordLength.append(UInt16(clamping: max(column - wordStart, 1)))
      shapes.wordColor.append(wordColor)
      wordStart = -1
    }
    func endLine() {
      endWord()
      shapes.lineWord.append(shapes.wordStart.count)
      column = 0
    }

    var offset = 0
    for unit in text.utf16 {
      defer { offset += 1 }
      if unit == 10 {
        if !previousWasReturn { endLine() } else { previousWasReturn = false }
        continue
      }
      if unit == 13 {
        endLine()
        previousWasReturn = true
        continue
      }
      previousWasReturn = false
      if unit == 32 || unit == 9 {
        endWord()
        column += unit == 9 ? 4 : 1
        continue
      }
      // The second half of a surrogate pair is part of the character before it.
      if unit & 0xFC00 == 0xDC00 { continue }
      while run < runs.count - 1 && offset >= runs[run].end { run += 1 }
      let color = run < runs.count ? runs[run].color : 0
      if wordStart < 0 {
        wordStart = column
        wordColor = color
      } else if color != wordColor {
        endWord()
        wordStart = column
        wordColor = color
      }
      column += 1
    }
    endLine()
    return shapes
  }

  /// The strip: the whole file squeezed into `size`, as marks.
  private static func renderWholeFile(_ shapes: Shapes, size: CGSize, scale: CGFloat, bar: UIColor) -> CGImage? {
    guard shapes.count > 0, size.width > 0, size.height > 0 else { return nil }
    let rowHeight = min(2, size.height / CGFloat(shapes.count))
    // Two pixels or more a line: a mark for each. Fewer: several lines share a pixel row.
    if rowHeight * scale >= 2 {
      return renderLines(shapes, from: 0, to: shapes.count, size: size, scale: scale, mode: .strip, bar: bar, rowHeight: rowHeight)
    }
    return renderDensity(shapes, size: size, scale: scale, mode: .strip, bar: bar, rowHeight: rowHeight)
  }

  /// A chunk of the full minimap: its lines, two points each.
  private static func renderChunk(_ shapes: Shapes, chunk: Int, width: CGFloat, scale: CGFloat, mode: Mode, bar: UIColor) -> CGImage? {
    let from = chunk * chunkLines
    let to = min(shapes.count, from + chunkLines)
    guard from < to, width > 0 else { return nil }
    let size = CGSize(width: width, height: CGFloat(to - from) * fullRowHeight)
    return renderLines(shapes, from: from, to: to, size: size, scale: scale, mode: mode, bar: bar, rowHeight: fullRowHeight)
  }

  private static let inset: CGFloat = 2

  private static func renderLines(_ shapes: Shapes, from: Int, to: Int, size: CGSize, scale: CGFloat, mode: Mode, bar: UIColor, rowHeight: CGFloat) -> CGImage? {
    let format = UIGraphicsImageRendererFormat()
    format.scale = scale
    format.opaque = false
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    let usable = size.width - inset * 2
    return renderer.image { context in
      let cg = context.cgContext
      for line in from ..< to {
        let y = CGFloat(line - from) * rowHeight
        if let tint = shapes.tints[shapes.kinds[line]] {
          cg.setFillColor(tint.cgColor)
          cg.fill(CGRect(x: 0, y: y, width: size.width, height: rowHeight))
        }
        guard mode != .strip else { continue }
        for word in shapes.lineWord[line] ..< shapes.lineWord[line + 1] {
          // A point a column: a word as wide as it is long, clipped at the right edge.
          let from = CGFloat(shapes.wordStart[word])
          guard from < usable else { break }
          let width = min(CGFloat(shapes.wordLength[word]), usable - from)
          let color = shapes.palette.isEmpty ? bar : shapes.palette[Int(shapes.wordColor[word])].withAlphaComponent(0.85)
          cg.setFillColor(color.cgColor)
          cg.fill(CGRect(x: inset + from, y: y + rowHeight * 0.2, width: width, height: rowHeight * 0.6))
        }
      }
    }.cgImage
  }

  private typealias Premultiplied = (r: Float, g: Float, b: Float, a: Float)

  private static func components(_ color: UIColor) -> Premultiplied {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    return (Float(r), Float(g), Float(b), Float(a))
  }

  /// One pixel row stands for several lines. A column of it is as dark as the share of those lines that have text there, and the row
  /// takes the tint of the kind most of its tinted lines are — so nothing piles up into a solid block, and a change always shows.
  private static func renderDensity(_ shapes: Shapes, size: CGSize, scale: CGFloat, mode: Mode, bar: UIColor, rowHeight: CGFloat) -> CGImage? {
    let width = Int((size.width * scale).rounded())
    let linesPerPixel = Double(shapes.count) / Double(max(1, Int((CGFloat(shapes.count) * rowHeight * scale).rounded(.up))))
    let pixelsPerLine = 1 / linesPerPixel
    let height = max(1, Int((Double(shapes.count) * pixelsPerLine).rounded(.up)))
    guard width > 0 else { return nil }

    var lines = [Int](repeating: 0, count: height)
    var votes: [Int: [Int: Int]] = [:]
    for line in 0 ..< shapes.count {
      let row = min(height - 1, Int(Double(line) * pixelsPerLine))
      lines[row] += 1
      let kind = shapes.kinds[line]
      if kind != 0, shapes.tints[kind] != nil { votes[row, default: [:]][kind, default: 0] += 1 }
    }

    var pixels = [UInt8](repeating: 0, count: width * height * 4)
    for row in 0 ..< height {
      var under: Premultiplied = (0, 0, 0, 0)
      if let tally = votes[row], let kind = tally.max(by: { $0.value < $1.value })?.key, let tint = shapes.tints[kind] {
        let c = components(tint)
        under = (c.r * c.a, c.g * c.a, c.b * c.a, c.a)
      }
      for x in 0 ..< width {
        let out = under
        let i = (row * width + x) * 4
        pixels[i] = UInt8(max(0, min(255, out.r * 255)))
        pixels[i + 1] = UInt8(max(0, min(255, out.g * 255)))
        pixels[i + 2] = UInt8(max(0, min(255, out.b * 255)))
        pixels[i + 3] = UInt8(max(0, min(255, out.a * 255)))
      }
    }
    return pixels.withUnsafeMutableBytes { buffer -> CGImage? in
      let context = CGContext(
        data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
      return context?.makeImage()
    }
  }
}
