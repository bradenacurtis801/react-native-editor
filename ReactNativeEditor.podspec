require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

# Pure-Swift Nitro HybridView wrapping Runestone (github.com/simonbs/Runestone),
# an SPM-only iOS text editor built on tree-sitter. No Rust, no xcframework —
# Runestone itself is pulled in as a real SPM dependency of THIS pod's own
# native target via React Native's spm_dependency helper (available since RN
# 0.75, scripts/cocoapods/spm.rb) rather than vendored: the consuming app's
# Podfile already calls react_native_post_install, which wires
# SPM.apply_on_post_install into post_install, so this Just Works with no
# extra config plugin.
#
# Tree-sitter grammars are added the same way, one spm_dependency per
# language needed — Runestone's own docs confirm a grammar is just plain C
# (parser.c/parser.h) + a highlights.scm query, no further nested SPM
# resolution problem.
#
# Below points at bradenacurtis801/{Runestone,TreeSitterLanguages} forks, NOT
# the upstream simonbs repos. Both forks are identical to upstream except for
# one changed dependency URL each, forming a chain:
#   TreeSitterLanguages fork -> Runestone fork -> tree-sitter fork
# where bradenacurtis801/tree-sitter (v0.20.10) carries a one-line header fix
# for an Xcode 26 / Swift 6.3 C++ interop compile error — api.h/parser.h
# #include stdlib.h/stdint.h/stdbool.h *inside* an extern "C" block, which
# newer Xcode rejects ("import of C++ module 'std_stdint_h' appears within
# extern \"C\" language linkage specification"). See
# https://github.com/tree-sitter/tree-sitter/issues/5523 (a related but
# distinct upstream Xcode 26 SPM issue, affecting 0.25+ — we're pinned to
# 0.20.x so unaffected by that one) and the fork's own commit message for
# this specific fix. Revert to the upstream URLs below once fixed upstream.
#
# The whole chain has to point at forks together — SPM treats different URLs
# as different package identities, so pointing only the top of the chain at
# a fork while a lower link still resolves the original upstream URL would
# pull in two different "Runestone" (or "TreeSitter") modules at once.

Pod::Spec.new do |s|
  s.name         = "ReactNativeEditor"
  s.version      = package["version"]
  s.summary      = "Native code editor for React Native (iOS: Runestone)."
  s.homepage     = "https://github.com/bradenacurtis801/react-native-editor"
  s.license      = package["license"]
  s.authors      = { "Braden Curtis" => "bradenacurtis801@gmail.com" }

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/bradenacurtis801/react-native-editor.git", :tag => "#{s.version}" }

  # Hand-authored iOS sources — just the Nitro Swift view (nitrogen's
  # add_nitrogen_files, below, appends its own generated specs/bridges).
  s.source_files = "ios/**/*.{h,m,mm,swift}"

  spm_dependency(s,
    url: "https://github.com/bradenacurtis801/Runestone",
    requirement: { kind: "upToNextMajorVersion", minimumVersion: "0.5.3" },
    products: ["Runestone"])

  # Tree-sitter grammars, bundled as Runestone bindings (parser + highlights
  # query + a `TreeSitterLanguage` static preset, e.g. `.json`) via simonbs'
  # TreeSitterLanguages package — one SPM package, many products, matched to
  # the language ids `viewerUtils.getLanguage()` already produces app-side.
  # Anything not in this list (e.g. kotlin, xml) falls back to plain text in
  # HybridEditor.swift's language switch, not a build error.
  spm_dependency(s,
    url: "https://github.com/bradenacurtis801/TreeSitterLanguages",
    requirement: { kind: "upToNextMajorVersion", minimumVersion: "0.1.11" },
    products: %w[
      TreeSitterJSONRunestone
      TreeSitterJavaScriptRunestone
      TreeSitterTypeScriptRunestone
      TreeSitterCSharpRunestone
      TreeSitterPythonRunestone
      TreeSitterRubyRunestone
      TreeSitterGoRunestone
      TreeSitterRustRunestone
      TreeSitterJavaRunestone
      TreeSitterSwiftRunestone
      TreeSitterCRunestone
      TreeSitterCPPRunestone
      TreeSitterCSSRunestone
      TreeSitterHTMLRunestone
      TreeSitterYAMLRunestone
      TreeSitterSQLRunestone
      TreeSitterBashRunestone
      TreeSitterMarkdownRunestone
    ])

  # React-Core / ReactCommon (turbomodule/core for ObjCTurboModule), Folly, etc.
  install_modules_dependencies(s)

  # Nitro HybridView: appends nitrogen's generated specs + bridges to
  # source_files, adds the NitroModules dependency, and merges the C++ <->
  # Swift interop xcconfig. Loaded last so it extends (not overwrites) the above.
  load File.join(__dir__, "nitrogen", "generated", "ios", "ReactNativeEditor+autolinking.rb")
  add_nitrogen_files(s)
end
