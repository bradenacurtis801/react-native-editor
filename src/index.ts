// Public API for react-native-editor.
//
// <CodeEditor initialText={...} language={...} theme={...} onDirtyChange={...} />
// + a ref exposing getText()/setText() — see CodeEditor.tsx for the full contract.

export {
	CodeEditor,
	type CodeEditorHandle,
	type CursorDirection,
	type CodeEditorProps,
	type CodeEditorTheme,
} from './CodeEditor';
