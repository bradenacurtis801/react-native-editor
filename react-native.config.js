const path = require('node:path');

module.exports = {
	dependency: {
		platforms: {
			// Autolink the hand-authored podspec (no xcodeproj — the pod compiles
			// ios/HybridEditor.swift + Runestone, pulled in via spm_dependency).
			ios: { podspecPath: path.join(__dirname, 'ReactNativeEditor.podspec') },
		},
	},
};
