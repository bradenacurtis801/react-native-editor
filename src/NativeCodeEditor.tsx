import { forwardRef, useImperativeHandle, useRef } from 'react';
import { StyleSheet } from 'react-native';
import { callback, getHostComponent } from 'react-native-nitro-modules';

import EditorViewConfig from '../nitrogen/generated/shared/json/EditorConfig.json';
import type { Editor, EditorMethods, EditorProps } from '../nitro/Editor.nitro';
import { detectIndentation } from './indentation';
import type { CodeEditorHandle, CodeEditorProps, CodeEditorSettings, CursorDirection } from './types';

// ─────────────────────────── iOS: native Runestone view ────────────────────

const NativeEditor = getHostComponent<EditorProps, EditorMethods>(
	'Editor',
	() => EditorViewConfig,
);

/** Mirrors every default `HybridEditor.swift` itself falls back to — kept in sync by hand (Nitro props have no cross-language default mechanism), not re-derived at runtime. */
const SETTINGS_DEFAULTS: Required<Omit<CodeEditorSettings, 'indentation' | 'insertionPointColor' | 'selectionBarColor' | 'gutterBackgroundColor'>> = {
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
	keyboardDismissMode: 'interactive',
	returnKeyType: 'default',
	selectionHighlightColor: '#3399ff33',
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

export const NativeCodeEditor = forwardRef<CodeEditorHandle, CodeEditorProps>(
	({ initialText, language, editable = true, theme, settings, onDirtyChange, onSelectionChange, onHistoryChange, onFindChange, style }, ref) => {
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
			insertText: (text: string) => hybridRef.current?.insertText(text),
			undo: () => hybridRef.current?.undo(),
			redo: () => hybridRef.current?.redo(),
			tab: () => hybridRef.current?.tab(),
			indent: () => hybridRef.current?.indent(),
			outdent: () => hybridRef.current?.outdent(),
			moveCursor: (direction: CursorDirection) => hybridRef.current?.moveCursor(direction),
			setLanguage: (language: string) => hybridRef.current?.applyLanguage(language),
			showFind: (replace: boolean) => hybridRef.current?.showFind(replace),
			goToLine: (line: number) => hybridRef.current?.goToLine(line),
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
				indentStrategy={settings?.indentation ?? detectIndentation(initialText)}
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
				keyboardDismissMode={s.keyboardDismissMode}
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
				onChangeSelection={callback((line: number, column: number, length: number) => onSelectionChange?.(line, column, length))}
				onChangeHistory={callback((canUndo: boolean, canRedo: boolean) => onHistoryChange?.(canUndo, canRedo))}
				onChangeFind={callback((isOpen: boolean) => onFindChange?.(isOpen))}
			/>
		);
	},
);

const styles = StyleSheet.create({
	fill: { flex: 1 },
});
