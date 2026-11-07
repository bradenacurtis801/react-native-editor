import { forwardRef, useCallback, useImperativeHandle, useRef } from 'react';
import { StyleSheet, TextInput, View } from 'react-native';

import type { CodeEditorHandle, CodeEditorProps } from './types';

// ─────────────────────────── Android (and other): TextInput fallback ───────
//
// No native backend yet (see AGENTS.md-style follow-up: a comparable native
// Android editor can be dropped in later behind this same component without
// touching callers). Plain but functional: monospace TextInput, same
// uncontrolled get/set-on-demand contract as the native path above.
// `settings` has no effect here — none of it maps onto a plain `TextInput`.

export const FallbackCodeEditor = forwardRef<CodeEditorHandle, CodeEditorProps>(
	({ initialText, editable = true, theme, onDirtyChange, style }, ref) => {
		const textRef = useRef(initialText);

		useImperativeHandle(ref, () => ({
			getText: () => textRef.current,
			setText: (text: string) => { textRef.current = text; },
			// No editing commands on the plain TextInput.
			insertText: () => {},
			undo: () => {},
			redo: () => {},
			tab: () => {},
			indent: () => {},
			outdent: () => {},
			moveCursor: () => {},
			setLanguage: () => {},
			showFind: () => {},
			find: () => {},
			findNext: () => {},
			findPrevious: () => {},
			replaceMatch: () => {},
			replaceAllMatches: () => {},
			clearFind: () => {},
			goToLine: () => {},
			duplicateLines: () => {},
			moveLines: () => {},
			toggleComment: () => {},
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

const styles = StyleSheet.create({
	fill: { flex: 1 },
	fallbackInput: {
		flex: 1,
		fontFamily: 'monospace',
		textAlignVertical: 'top',
		padding: 8,
	},
});
