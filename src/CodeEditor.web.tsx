export type { CodeEditorHandle, CodeEditorProps, CodeEditorSettings, CodeEditorTheme, CursorDirection } from './types';

/** Web build of `CodeEditor.tsx` — always the plain `TextInput` fallback,
 * and never imports `NativeCodeEditor` (see that file's comment). Same
 * uncontrolled `getText`/`setText` contract as on native. */
export { FallbackCodeEditor as CodeEditor } from './FallbackCodeEditor';
