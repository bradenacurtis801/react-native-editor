import type { StyleProp, ViewStyle } from 'react-native';

/** Colors + font size the editor renders with — caller supplies these from its own theme, this package has no theme system of its own. */
export interface CodeEditorTheme {
	background: string;
	text: string;
	keyword: string;
	string: string;
	comment: string;
	number: string;
	plain: string;
	fontSize?: number;
}

/**
 * Every other configurable Runestone behavior beyond the theme/language/
 * editable basics — all optional, all iOS-only (no effect on the Android
 * `TextInput` fallback, which has no equivalent knobs). See `Editor.nitro.ts`
 * for what each one does natively; names here match 1:1 except the `*Hex`
 * suffix is dropped (every color here is a `#RRGGBB` hex string).
 */
export interface CodeEditorSettings {
	/** What one level of indentation is: `'tab:N'` or `'space:N'`. @default guessed from the text (`detectIndentation`) */
	indentation?: string;
	showLineNumbers?: boolean;
	/** @default false — see `Editor.nitro.ts`'s own doc comment on why. */
	automaticScrollEnabled?: boolean;
	/** @default 1 — lets the last line scroll to the top of the screen instead of stopping at the bottom edge. */
	verticalOverscrollFactor?: number;
	horizontalOverscrollFactor?: number;
	isSelectable?: boolean;
	/** @default 'no' */
	autocorrectionType?: 'default' | 'no' | 'yes';
	/** @default 'none' */
	autocapitalizationType?: 'none' | 'sentences' | 'words' | 'allCharacters';
	/** @default 'no' — smart quotes would corrupt string literals. */
	smartQuotesType?: 'default' | 'no' | 'yes';
	/** @default 'no' — smart dashes would corrupt `--`/`->` etc. */
	smartDashesType?: 'default' | 'no' | 'yes';
	/** @default 'no' */
	smartInsertDeleteType?: 'default' | 'no' | 'yes';
	/** @default 'no' */
	spellCheckingType?: 'default' | 'no' | 'yes';
	/** @default 'asciiCapable' */
	keyboardType?:
		| 'default' | 'asciiCapable' | 'numbersAndPunctuation' | 'URL'
		| 'numberPad' | 'phonePad' | 'namePhonePad' | 'emailAddress'
		| 'decimalPad' | 'twitter' | 'webSearch' | 'asciiCapableNumberPad';
	keyboardAppearance?: 'default' | 'light' | 'dark';
	/**
	 * How scrolling puts the keyboard away: `'interactive'` — it follows the finger
	 * down, as in Messages; `'onDrag'` — it goes as the drag starts; `'none'`.
	 * @default 'interactive'
	 */
	keyboardDismissMode?: 'none' | 'onDrag' | 'interactive';
	returnKeyType?:
		| 'default' | 'go' | 'google' | 'join' | 'next' | 'route' | 'search'
		| 'send' | 'yahoo' | 'done' | 'emergencyCall' | 'continue';
	/** `#RRGGBB` caret color. @default theme.text */
	insertionPointColor?: string;
	/** `#RRGGBB` selection-handle bar color. @default theme.text */
	selectionBarColor?: string;
	/** `#RRGGBBAA` selected-text background color — include an alpha byte, or it paints as a fully opaque block over the selected text instead of a translucent highlight. @default '#3399ff33' (~20% opacity) */
	selectionHighlightColor?: string;
	showTabs?: boolean;
	showSpaces?: boolean;
	showNonBreakingSpaces?: boolean;
	showLineBreaks?: boolean;
	showSoftLineBreaks?: boolean;
	tabSymbol?: string;
	spaceSymbol?: string;
	nonBreakingSpaceSymbol?: string;
	lineBreakSymbol?: string;
	softLineBreakSymbol?: string;
	/** `#RRGGBB` — color the above symbols render in. */
	invisibleCharactersColor?: string;
	gutterLeadingPadding?: number;
	gutterTrailingPadding?: number;
	gutterMinimumCharacterCount?: number;
	/** `#RRGGBB`. @default theme.background */
	gutterBackgroundColor?: string;
	/** `#RRGGBB`, transparent by default. */
	gutterHairlineColor?: string;
	/** @default 'disabled' */
	lineSelectionDisplayType?: 'disabled' | 'line' | 'lineFragment';
	/** `#RRGGBB`, transparent by default. */
	selectedLineBackgroundColor?: string;
	/** `#RRGGBB`, transparent by default. */
	selectedLinesGutterBackgroundColor?: string;
	/** @default true */
	isLineWrappingEnabled?: boolean;
	/** @default 'byWordWrapping' */
	lineBreakMode?: 'byWordWrapping' | 'byCharWrapping';
	kern?: number;
	lineHeightMultiplier?: number;
	showPageGuide?: boolean;
	/** @default 80 */
	pageGuideColumn?: number;
	/** `#RRGGBB`, transparent by default. */
	pageGuideHairlineColor?: string;
	/** `#RRGGBB`, transparent by default. */
	pageGuideBackgroundColor?: string;
	/** `#RRGGBB`, transparent by default. */
	markedTextBackgroundColor?: string;
	/** Typing an opening bracket or quote also types its closer. iOS only. @default false */
	autoClosePairs?: boolean;
	/** Pinching the text changes its size (8 to 40); `onFontSizeChange` says where it stopped. iOS only. @default false */
	pinchToZoom?: boolean;
	/** Turns on iOS's entire native find/replace UI for free. iOS 16+; a no-op below that. @default false */
	isFindInteractionEnabled?: boolean;
	/** @default 'lf' */
	lineEndings?: 'lf' | 'crlf' | 'cr';
	showMenuAfterNavigatingToHighlightedRange?: boolean;
	/** `#RRGGBBAA` background behind every match of a `find`. @default '#ffd60a55' */
	findColor?: string;
	/** `#RRGGBBAA` background behind the current match of a `find`. @default '#ff9f0aaa' */
	findCurrentColor?: string;
}

/** How a find matches its text. */
export type FindMatchMethod = 'contains' | 'fullWord' | 'startsWith' | 'endsWith' | 'regex';

export interface FindOptions {
	/** @default 'contains' */
	method?: FindMatchMethod;
	/** @default false */
	caseSensitive?: boolean;
}

export interface CodeEditorProps {
	/** Seeds the initial buffer. Changing this after mount does NOT reset the buffer — this is an uncontrolled component (see `CodeEditorHandle`). */
	initialText: string;
	/** Tree-sitter grammar id, e.g. "json" | "swift" | "plaintext". Unrecognized ids fall back to plain text. */
	language: string;
	editable?: boolean;
	theme: CodeEditorTheme;
	/** iOS-only; ignored on the Android fallback. Omitted fields use Runestone/this package's own defaults — see each field's own doc comment. */
	settings?: CodeEditorSettings;
	/** Fires whenever the buffer transitions between matching/not-matching `initialText`. */
	onDirtyChange?: (isDirty: boolean) => void;
	/** The caret or selection moved. `line` and `column` are 1-based, of the selection's start; `length` is the selected character count. iOS only. */
	onSelectionChange?: (line: number, column: number, length: number) => void;
	/** Whether undo and redo have anything to do — fires when either changes. iOS only. */
	onHistoryChange?: (canUndo: boolean, canRedo: boolean) => void;
	/** The find bar opened or closed. iOS only. */
	onFindChange?: (isOpen: boolean) => void;
	/** The find in progress found `count` matches, `index` (1-based, 0 for none) being the current one. Fires as the query, the text or the current match changes. iOS only. */
	onFindResult?: (count: number, index: number) => void;
	/** The text scrolled, or the number of lines changed: the first and last line showing and the line count (all 1-based). Fires only when one of them changes. iOS only. */
	onScroll?: (topLine: number, bottomLine: number, lineCount: number) => void;
	/** A pinch ended at this font size — keep it and pass it back as `theme.fontSize`. Needs `settings.pinchToZoom`. iOS only. */
	onFontSizeChange?: (fontSize: number) => void;
	/** A map of the whole file down the right edge with a slider over what shows; touch or drag it to scroll. `'strip'` is a narrow one (marks and the slider only), `'compact'` the real minimap in less room (for a phone), `'full'` the real minimap. iOS only. @default 'off' */
	minimap?: 'off' | 'strip' | 'compact' | 'full';
	/** How each line kind (a number above 0) is drawn: a colour behind the line's whole row, and one in the gutter, as `#RRGGBB` or `#RRGGBBAA`. Lines get their kind from `setLineKinds`. iOS only. */
	lineStyles?: Record<number, { background?: string; gutterBackground?: string }>;
	/** The kind a line gets when Return splits a line of another kind: `{ 3: 1 }`. A kind that is not listed passes to the new line unchanged. iOS only. */
	newLineKinds?: Record<number, number>;
	style?: StyleProp<ViewStyle>;
}

/** Imperative handle — the buffer lives natively (iOS) or in local state (Android fallback), not in JS-controlled `value` state, so content is pulled on demand (e.g. on Save) rather than streamed through `onChangeText` on every keystroke. */
export interface CodeEditorHandle {
	getText(): string;
	setText(text: string): void;
	/** Types `text` at the caret, replacing the selection, as the keyboard would (one undo step). */
	insertText(text: string): void;
	undo(): void;
	redo(): void;
	/** The Tab key: indents the selected lines, or the caret's line when it is in its leading whitespace; otherwise types one level of indentation. */
	tab(): void;
	/** Indent / take one level off the selected lines (the caret's line when nothing is selected). */
	indent(): void;
	outdent(): void;
	moveCursor(direction: CursorDirection): void;
	/** Changes the syntax highlighting to `language` (the `language` prop's ids) without touching the text, selection or undo history. */
	setLanguage(language: string): void;
	/** Opens iOS's find bar, with the replace field when `replace` — needs `settings.isFindInteractionEnabled`. */
	showFind(replace: boolean): void;
	/** Finds `query`: every match is highlighted and the first from the caret is selected and scrolled to; the result comes through `onFindResult`. An empty query clears the find. iOS only. */
	find(query: string, options?: FindOptions): void;
	/** The next / previous match of the find, wrapping round. */
	findNext(): void;
	findPrevious(): void;
	/** Replaces the current match (`$1` stands for a regex group) and moves to the next; one undo step. */
	replaceMatch(replacement: string): void;
	/** Replaces every match of the find; one undo step. */
	replaceAllMatches(replacement: string): void;
	/** Ends the find: the highlights go and the selection stays. */
	clearFind(): void;
	/** Puts the caret at the start of the 1-based `line`, scrolled into view; past the end goes to the last line. */
	goToLine(line: number): void;
	/** Gives lines their kind (see `lineStyles`): each run is `[firstLine, count, kind]`, lines 1-based. Every line not in a run gets none. A kind stays with its line as the text around it is edited; `setText` clears them all, so send them again after it. iOS only. */
	setLineKinds(runs: [firstLine: number, count: number, kind: number][]): void;
	/** Copies the selected lines (the caret's line) below themselves; the selection moves to the copy. */
	duplicateLines(): void;
	/** Swaps the selected lines with the line above or below. */
	moveLines(direction: 'up' | 'down'): void;
	/** Comments the selected lines with `prefix` (e.g. `//` or `#`), or uncomments them when every one has it. */
	toggleComment(prefix: string): void;
}

export type CursorDirection = 'left' | 'right' | 'up' | 'down' | 'lineStart' | 'lineEnd' | 'documentStart' | 'documentEnd';
