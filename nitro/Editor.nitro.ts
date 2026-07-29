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
	/** Fires whenever the buffer transitions between matching/not-matching its initial `text` — cheap dirty-tracking without streaming every keystroke to JS. */
	onChangeDirty: (isDirty: boolean) => void;
}

export interface EditorMethods extends HybridViewMethods {
	/** Pull the current buffer content — call on save, not on every keystroke. */
	readBuffer(): string;
	/** Replace the buffer content (e.g. after a failed save, to restore a known-good state). */
	writeBuffer(text: string): void;
}

export type Editor = HybridView<EditorProps, EditorMethods>;
