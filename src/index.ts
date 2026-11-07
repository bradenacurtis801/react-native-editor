// Public API for react-native-editor.
//
// <CodeEditor initialText={...} language={...} theme={...} onDirtyChange={...} />
// + a ref exposing getText()/setText() — see CodeEditor.tsx for the full contract.

export { detectIndentation } from './indentation';

export {
	CodeEditor,
	type CodeEditorHandle,
	type CursorDirection,
	type CodeEditorProps,
	type CodeEditorSettings,
	type FindMatchMethod,
	type FindOptions,
	type CodeEditorTheme,
} from './CodeEditor';
