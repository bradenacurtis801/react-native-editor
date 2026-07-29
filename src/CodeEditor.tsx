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

export interface CodeEditorProps {
	/** Seeds the initial buffer. Changing this after mount does NOT reset the buffer — this is an uncontrolled component (see `CodeEditorHandle`). */
	initialText: string;
	/** Tree-sitter grammar id, e.g. "json" | "swift" | "plaintext". Unrecognized ids fall back to plain text. */
	language: string;
	editable?: boolean;
	theme: CodeEditorTheme;
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

const NativeCodeEditor = forwardRef<CodeEditorHandle, CodeEditorProps>(
	({ initialText, language, editable = true, theme, onDirtyChange, style }, ref) => {
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
