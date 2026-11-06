import type {
	HybridView,
	HybridViewMethods,
	HybridViewProps,
} from 'react-native-nitro-modules';

/**
 * The native code editor view (Nitro HybridView). iOS-only for now — no
 * `android` entry in `nitro.json`'s autolinking, so nitrogen generates no
 * Kotlin spec and the JS wrapper (`src/CodeEditor.tsx`) never mounts this
 * view on Android, falling back to a plain `TextInput` there instead.
 *
 * `text` only seeds the initial buffer — edits stay native-side (Runestone
 * owns the buffer for tree-sitter's incremental reparse) and are pulled out
 * imperatively via `readBuffer()` rather than round-tripping every keystroke
 * through JS the way a controlled `TextInput` would.
 *
 * Note: `EditorMethods` below is named `readBuffer`/`writeBuffer`, not
 * `getText`/`setText` — nitrogen auto-generates a `getText()`/`setText()`
 * C++ accessor pair for the `text` prop itself, and a method with the same
 * name+signature is a duplicate member in the generated spec (caught at
 * Xcode compile time, not by nitrogen or tsc). Any future prop named `text`
 * (or `X` alongside a method `getX`/`setX`) will hit the same collision.
 */
export interface EditorProps extends HybridViewProps {
	/** Initial buffer content. Changing this after mount does NOT reset the buffer — use `writeBuffer` for that. */
	text: string;
	/** Tree-sitter grammar id (matches `viewerUtils.getLanguage`'s ids, e.g. "json" | "swift" | "plaintext"). */
	language: string;
	editable: boolean;
	/** JSON blob: `{ keyword, string, comment, number, plain }` hex colors — same shape as the app's existing `syntaxColors` map. */
	syntaxColorsJson: string;
	backgroundColor: string;
	textColor: string;
	fontSizePx: number;
	/** What one level of indentation is, for Tab and indent / outdent: `'tab:N'` (a tab, shown N wide) or `'space:N'` (N spaces). @default 'tab:4' */
	indentStrategy: string;
	/** Gutter line numbers. @default true */
	showLineNumbers: boolean;
	/**
	 * Runestone's own built-in "keep the caret visible" scrolling — on
	 * typing AND on any caret move, including a plain tap (see
	 * `TextView.isAutomaticScrollEnabled`'s own doc comment: "when typing or
	 * moving the caret"). Off by default here: it fights patterns like
	 * adding blank lines between two functions, where you want to keep
	 * seeing the content above rather than have the view jump to follow the
	 * caret after every keystroke or tap.
	 * @default false
	 */
	automaticScrollEnabled: boolean;

	// --- Scrolling / overscroll ---------------------------------------
	/** Extra scroll room past the real end of the text, as a fraction of the view's own height/width — `1` lets the last line scroll all the way to the top of the screen instead of stopping at the bottom edge. `TextView.verticalOverscrollFactor`/`horizontalOverscrollFactor`. @default 1 for vertical, 0 for horizontal */
	verticalOverscrollFactor: number;
	horizontalOverscrollFactor: number;

	// --- Selection / input behavior -------------------------------------
	/** Whether text can be selected at all (independent of `editable` — e.g. selectable-but-not-editable for a read-only viewer). @default true */
	isSelectable: boolean;
	/** 'default' | 'no' | 'yes'. @default 'no' — autocorrect fighting code identifiers is almost never wanted. */
	autocorrectionType: string;
	/** 'none' | 'sentences' | 'words' | 'allCharacters'. @default 'none' */
	autocapitalizationType: string;
	/** 'default' | 'no' | 'yes'. @default 'no' — smart quotes would corrupt string literals. */
	smartQuotesType: string;
	/** 'default' | 'no' | 'yes'. @default 'no' — smart dashes would corrupt `--`/`->` etc. */
	smartDashesType: string;
	/** 'default' | 'no' | 'yes'. @default 'no' */
	smartInsertDeleteType: string;
	/** 'default' | 'no' | 'yes'. @default 'no' */
	spellCheckingType: string;
	/** A `UIKeyboardType` case name, e.g. 'default' | 'asciiCapable' | 'numbersAndPunctuation' | 'URL' | 'numberPad' | 'phonePad' | 'namePhonePad' | 'emailAddress' | 'decimalPad' | 'twitter' | 'webSearch' | 'asciiCapableNumberPad'. @default 'asciiCapable' */
	keyboardType: string;
	/** 'default' | 'light' | 'dark'. @default 'default' */
	keyboardAppearance: string;
	/** How scrolling puts the keyboard away: 'none' | 'onDrag' | 'interactive' (the keyboard follows the finger down, as in Messages). @default 'interactive' */
	keyboardDismissMode: string;
	/** A `UIReturnKeyType` case name, e.g. 'default' | 'go' | 'search' | 'send' | 'done' | ... — rarely meaningful for a multiline code editor, exposed for completeness. @default 'default' */
	returnKeyType: string;
	/** `#RRGGBB` caret color. */
	insertionPointColorHex: string;
	/** `#RRGGBB` selection-handle bar color. */
	selectionBarColorHex: string;
	/** `#RRGGBB` selected-text background color. */
	selectionHighlightColorHex: string;

	// --- Invisible characters -------------------------------------------
	showTabs: boolean;
	showSpaces: boolean;
	showNonBreakingSpaces: boolean;
	showLineBreaks: boolean;
	showSoftLineBreaks: boolean;
	tabSymbol: string;
	spaceSymbol: string;
	nonBreakingSpaceSymbol: string;
	lineBreakSymbol: string;
	softLineBreakSymbol: string;
	/** `#RRGGBB` — color the above symbols render in (`Theme.invisibleCharactersColor`). */
	invisibleCharactersColorHex: string;

	// --- Gutter / line numbers -------------------------------------------
	gutterLeadingPadding: number;
	gutterTrailingPadding: number;
	gutterMinimumCharacterCount: number;
	/** `#RRGGBB`, `Theme.gutterBackgroundColor`. @default same as `backgroundColor` */
	gutterBackgroundColorHex: string;
	/** `#RRGGBB`, `Theme.gutterHairlineColor`. */
	gutterHairlineColorHex: string;

	// --- Current-line highlight -------------------------------------------
	/** 'disabled' | 'line' | 'lineFragment'. @default 'disabled' */
	lineSelectionDisplayType: string;
	/** `#RRGGBB`, `Theme.selectedLineBackgroundColor`. */
	selectedLineBackgroundColorHex: string;
	/** `#RRGGBB`, `Theme.selectedLinesGutterBackgroundColor`. */
	selectedLinesGutterBackgroundColorHex: string;

	// --- Layout / wrapping -------------------------------------------
	/** @default true */
	isLineWrappingEnabled: boolean;
	/** 'byWordWrapping' | 'byCharWrapping'. @default 'byWordWrapping' */
	lineBreakMode: string;
	kern: number;
	lineHeightMultiplier: number;
	showPageGuide: boolean;
	pageGuideColumn: number;
	/** `#RRGGBB`, `Theme.pageGuideHairlineColor`. */
	pageGuideHairlineColorHex: string;
	/** `#RRGGBB`, `Theme.pageGuideBackgroundColor`. */
	pageGuideBackgroundColorHex: string;

	// --- Marked text (e.g. mid-composition Chinese/Japanese input) -----
	/** `#RRGGBB`, `Theme.markedTextBackgroundColor`. */
	markedTextBackgroundColorHex: string;

	// --- Find/replace -------------------------------------------
	/** Turns on iOS's entire native find/replace UI (the system find bar) for free — no custom search UI needed. iOS 16+; a no-op below that. @default false */
	isFindInteractionEnabled: boolean;
	/** 'lf' | 'crlf' | 'cr' — line ending inserted for new line breaks. @default 'lf' */
	lineEndings: string;
	showMenuAfterNavigatingToHighlightedRange: boolean;

	/** Fires whenever the buffer transitions between matching/not-matching its initial `text` — cheap dirty-tracking without streaming every keystroke to JS. */
	onChangeDirty: (isDirty: boolean) => void;
	/** The caret or selection moved (or the text changed under it). `line` and `column` are 1-based, of the selection's start; `length` is how many characters are selected (0 for a caret). */
	onChangeSelection: (line: number, column: number, length: number) => void;
	/** What undo and redo can do now — fires when either changes, so a button can enable and disable. */
	onChangeHistory: (canUndo: boolean, canRedo: boolean) => void;
	/** The find bar opened or closed (`showFind`, or the system's own). */
	onChangeFind: (isOpen: boolean) => void;
}

export interface EditorMethods extends HybridViewMethods {
	/** Pull the current buffer content — call on save, not on every keystroke. */
	readBuffer(): string;
	/** Replace the buffer content (e.g. after a failed save, to restore a known-good state). */
	writeBuffer(text: string): void;
	/** Types `text` at the caret, replacing the selection — as the keyboard would, so it is one undo step and respects the editor's own handling of it. */
	insertText(text: string): void;
	undo(): void;
	redo(): void;
	/** Indents the selected lines (the caret's line when nothing is selected) by one level. */
	/** The Tab key: indents the selected lines — or the caret's line when the caret is in its leading whitespace or the line is empty — and otherwise types one level of indentation at the caret. */
	tab(): void;
	indent(): void;
	/** Takes one level of indentation off the selected lines. */
	outdent(): void;
	/** Moves the caret, collapsing a selection: 'left' | 'right' | 'up' | 'down' | 'lineStart' | 'lineEnd' | 'documentStart' | 'documentEnd'. */
	moveCursor(direction: string): void;
	/** Changes the syntax highlighting to `language` (the same ids as the `language` prop; an unknown id is plain text) without touching the text, the selection or the undo history. */
	applyLanguage(language: string): void;
	/** Opens iOS's find bar (with the replace field when `replace`). Needs `isFindInteractionEnabled`; iOS 16+, else a no-op. */
	showFind(replace: boolean): void;
	/** Puts the caret at the start of the 1-based `line` and scrolls to it; a line past the end goes to the last one. */
	goToLine(line: number): void;
}

export type Editor = HybridView<EditorProps, EditorMethods>;
