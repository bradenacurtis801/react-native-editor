import { Platform } from 'react-native';

import { FallbackCodeEditor } from './FallbackCodeEditor';
import { NativeCodeEditor } from './NativeCodeEditor';

export type { CodeEditorHandle, CodeEditorProps, CodeEditorSettings, CodeEditorTheme } from './types';

/** `<CodeEditor>` — Runestone-backed on iOS, a plain `TextInput` fallback elsewhere. One import, one API, regardless of platform. */
// Web gets `CodeEditor.web.tsx` instead, which never imports
// `NativeCodeEditor` (its Nitro import reaches into React Native's native
// component registry when it loads, which react-native-web doesn't have).
export const CodeEditor: typeof NativeCodeEditor =
	Platform.OS === 'ios' ? NativeCodeEditor : FallbackCodeEditor;
