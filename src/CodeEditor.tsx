import {
	forwardRef,
	useCallback,
	useImperativeHandle,
	useRef,
} from 'react';
import {
	Platform,
	StyleSheet,
	TextInput,
	View,
	type StyleProp,
	type ViewStyle,
} from 'react-native';
import { callback, getHostComponent } from 'react-native-nitro-modules';

import EditorViewConfig from '../nitrogen/generated/shared/json/EditorConfig.json';
import type { Editor, EditorMethods, EditorProps } from '../nitro/Editor.nitro';

// ─────────────────────────── public types ─────────────────────────────────

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
	returnKeyType?:
		| 'default' | 'go' | 'google' | 'join' | 'next' | 'route' | 'search'
		| 'send' | 'yahoo' | 'done' | 'emergencyCall' | 'continue';
	/** `#RRGGBB` caret color. @default theme.text */
	insertionPointColor?: string;
	/** `#RRGGBB` selection-handle bar color. @default theme.text */
	selectionBarColor?: string;
	/** `#RRGGBB` selected-text background color. */
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
	/** Turns on iOS's entire native find/replace UI for free. iOS 16+; a no-op below that. @default false */
	isFindInteractionEnabled?: boolean;
	/** @default 'lf' */
	lineEndings?: 'lf' | 'crlf' | 'cr';
	showMenuAfterNavigatingToHighlightedRange?: boolean;
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
	style?: StyleProp<ViewStyle>;
}

/** Imperative handle — the buffer lives natively (iOS) or in local state (Android fallback), not in JS-controlled `value` state, so content is pulled on demand (e.g. on Save) rather than streamed through `onChangeText` on every keystroke. */
export interface CodeEditorHandle {
	getText(): string;
	setText(text: string): void;
}

// ─────────────────────────── iOS: native Runestone view ────────────────────

const NativeEditor = getHostComponent<EditorProps, EditorMethods>(
	'Editor',
	() => EditorViewConfig,
);

/** Mirrors every default `HybridEditor.swift` itself falls back to — kept in sync by hand (Nitro props have no cross-language default mechanism), not re-derived at runtime. */
const SETTINGS_DEFAULTS: Required<Omit<CodeEditorSettings, 'insertionPointColor' | 'selectionBarColor' | 'gutterBackgroundColor'>> = {
	showLineNumbers: true,
	automaticScrollEnabled: false,
	verticalOverscrollFactor: 1,
	horizontalOverscrollFactor: 0,
	isSelectable: true,
	autocorrectionType: 'no',
	autocapitalizationType: 'none',
	smartQuotesType: 'no',
	smartDashesType: 'no',
	smartInsertDeleteType: 'no',
	spellCheckingType: 'no',
	keyboardType: 'asciiCapable',
	keyboardAppearance: 'default',
	returnKeyType: 'default',
	selectionHighlightColor: '#3399ff',
	showTabs: false,
	showSpaces: false,
	showNonBreakingSpaces: false,
	showLineBreaks: false,
	showSoftLineBreaks: false,
	tabSymbol: '→',
	spaceSymbol: '·',
	nonBreakingSpaceSymbol: '·',
	lineBreakSymbol: '¬',
	softLineBreakSymbol: '›',
	invisibleCharactersColor: '#808080',
	gutterLeadingPadding: 3,
	gutterTrailingPadding: 3,
	gutterMinimumCharacterCount: 2,
	gutterHairlineColor: '#00000000',
	lineSelectionDisplayType: 'disabled',
	selectedLineBackgroundColor: '#00000000',
	selectedLinesGutterBackgroundColor: '#00000000',
	isLineWrappingEnabled: true,
	lineBreakMode: 'byWordWrapping',
	kern: 0,
	lineHeightMultiplier: 1,
	showPageGuide: false,
	pageGuideColumn: 80,
	pageGuideHairlineColor: '#00000000',
	pageGuideBackgroundColor: '#00000000',
	markedTextBackgroundColor: '#00000000',
	isFindInteractionEnabled: false,
	lineEndings: 'lf',
	showMenuAfterNavigatingToHighlightedRange: true,
};

const NativeCodeEditor = forwardRef<CodeEditorHandle, CodeEditorProps>(
	({ initialText, language, editable = true, theme, settings, onDirtyChange, style }, ref) => {
		// The React `ref` on a Nitro HostComponent is just the RN view instance
		// (no custom methods) — `readBuffer`/`writeBuffer` live on the
		// HybridObject, reached separately via `hybridRef`. See getHostComponent.ts.
		// (Named readBuffer/writeBuffer natively, not getText/setText — nitrogen
		// auto-generates a getText()/setText() accessor pair for the `text` prop
		// itself, which collides with a same-named method. See Editor.nitro.ts.)
		const hybridRef = useRef<Editor | null>(null);

		useImperativeHandle(ref, () => ({
			getText: () => hybridRef.current?.readBuffer() ?? initialText,
			setText: (text: string) => hybridRef.current?.writeBuffer(text),
		}), [initialText]);

		const syntaxColorsJson = JSON.stringify({
			keyword: theme.keyword,
			string: theme.string,
			comment: theme.comment,
			number: theme.number,
			plain: theme.plain,
		});

		const s = { ...SETTINGS_DEFAULTS, ...settings };

		return (
			<NativeEditor
				hybridRef={callback((r: Editor) => { hybridRef.current = r; })}
				style={[styles.fill, style]}
				text={initialText}
				language={language}
				editable={editable}
				syntaxColorsJson={syntaxColorsJson}
				backgroundColor={theme.background}
				textColor={theme.text}
				fontSizePx={theme.fontSize ?? 13}
				showLineNumbers={s.showLineNumbers}
				automaticScrollEnabled={s.automaticScrollEnabled}
				verticalOverscrollFactor={s.verticalOverscrollFactor}
				horizontalOverscrollFactor={s.horizontalOverscrollFactor}
				isSelectable={s.isSelectable}
				autocorrectionType={s.autocorrectionType}
				autocapitalizationType={s.autocapitalizationType}
				smartQuotesType={s.smartQuotesType}
				smartDashesType={s.smartDashesType}
				smartInsertDeleteType={s.smartInsertDeleteType}
				spellCheckingType={s.spellCheckingType}
				keyboardType={s.keyboardType}
				keyboardAppearance={s.keyboardAppearance}
				returnKeyType={s.returnKeyType}
				insertionPointColorHex={settings?.insertionPointColor ?? theme.text}
				selectionBarColorHex={settings?.selectionBarColor ?? theme.text}
				selectionHighlightColorHex={s.selectionHighlightColor}
				showTabs={s.showTabs}
				showSpaces={s.showSpaces}
				showNonBreakingSpaces={s.showNonBreakingSpaces}
				showLineBreaks={s.showLineBreaks}
				showSoftLineBreaks={s.showSoftLineBreaks}
				tabSymbol={s.tabSymbol}
				spaceSymbol={s.spaceSymbol}
				nonBreakingSpaceSymbol={s.nonBreakingSpaceSymbol}
				lineBreakSymbol={s.lineBreakSymbol}
				softLineBreakSymbol={s.softLineBreakSymbol}
				invisibleCharactersColorHex={s.invisibleCharactersColor}
				gutterLeadingPadding={s.gutterLeadingPadding}
				gutterTrailingPadding={s.gutterTrailingPadding}
				gutterMinimumCharacterCount={s.gutterMinimumCharacterCount}
				gutterBackgroundColorHex={settings?.gutterBackgroundColor ?? theme.background}
				gutterHairlineColorHex={s.gutterHairlineColor}
				lineSelectionDisplayType={s.lineSelectionDisplayType}
				selectedLineBackgroundColorHex={s.selectedLineBackgroundColor}
				selectedLinesGutterBackgroundColorHex={s.selectedLinesGutterBackgroundColor}
				isLineWrappingEnabled={s.isLineWrappingEnabled}
				lineBreakMode={s.lineBreakMode}
				kern={s.kern}
				lineHeightMultiplier={s.lineHeightMultiplier}
				showPageGuide={s.showPageGuide}
				pageGuideColumn={s.pageGuideColumn}
				pageGuideHairlineColorHex={s.pageGuideHairlineColor}
				pageGuideBackgroundColorHex={s.pageGuideBackgroundColor}
				markedTextBackgroundColorHex={s.markedTextBackgroundColor}
				isFindInteractionEnabled={s.isFindInteractionEnabled}
				lineEndings={s.lineEndings}
				showMenuAfterNavigatingToHighlightedRange={s.showMenuAfterNavigatingToHighlightedRange}
				onChangeDirty={callback((isDirty: boolean) => onDirtyChange?.(isDirty))}
			/>
		);
	},
);

// ─────────────────────────── Android (and other): TextInput fallback ───────
//
// No native backend yet (see AGENTS.md-style follow-up: a comparable native
// Android editor can be dropped in later behind this same component without
// touching callers). Plain but functional: monospace TextInput, same
// uncontrolled get/set-on-demand contract as the native path above.
// `settings` has no effect here — none of it maps onto a plain `TextInput`.

const FallbackCodeEditor = forwardRef<CodeEditorHandle, CodeEditorProps>(
	({ initialText, editable = true, theme, onDirtyChange, style }, ref) => {
		const textRef = useRef(initialText);

		useImperativeHandle(ref, () => ({
			getText: () => textRef.current,
			setText: (text: string) => { textRef.current = text; },
		}), []);

		const handleChangeText = useCallback((text: string) => {
			const wasDirty = textRef.current !== initialText;
			textRef.current = text;
			const isDirty = text !== initialText;
			if (isDirty !== wasDirty) onDirtyChange?.(isDirty);
		}, [initialText, onDirtyChange]);

		return (
			<View style={[styles.fill, style]}>
				<TextInput
					defaultValue={initialText}
					onChangeText={handleChangeText}
					editable={editable}
					multiline
					autoCapitalize="none"
					autoCorrect={false}
					spellCheck={false}
					style={[
						styles.fallbackInput,
						{
							backgroundColor: theme.background,
							color: theme.text,
							fontSize: theme.fontSize ?? 13,
						},
					]}
				/>
			</View>
		);
	},
);

// ─────────────────────────── public component ──────────────────────────────

/** `<CodeEditor>` — Runestone-backed on iOS, a plain `TextInput` fallback elsewhere. One import, one API, regardless of platform. */
export const CodeEditor: typeof NativeCodeEditor =
	Platform.OS === 'ios' ? NativeCodeEditor : FallbackCodeEditor;

const styles = StyleSheet.create({
	fill: { flex: 1 },
	fallbackInput: {
		flex: 1,
		fontFamily: 'monospace',
		textAlignVertical: 'top',
		padding: 8,
	},
});
