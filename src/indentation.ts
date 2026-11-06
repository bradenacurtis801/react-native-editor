/**
 * How a file indents, guessed from its text: `'tab:N'` or `'space:N'` (N: the
 * width of a tab, or of one level of spaces). Looks at the first couple of
 * thousand lines. Lines that start with a tab count for tabs; of the lines
 * that start with spaces, the most common step in over the line above (2 to 8)
 * is the width. A file with no indentation at all gets `'tab:4'`.
 */
export function detectIndentation(text: string): string {
	let tabs = 0;
	let spaces = 0;
	let previous = 0;
	const steps: Record<number, number> = {};
	let start = 0;
	for (let n = 0; n < 2000 && start <= text.length; n++) {
		let end = text.indexOf('\n', start);
		if (end < 0) end = text.length;
		const first = text.charCodeAt(start);
		if (end > start && !(end === start + 1 && first === 13)) {
			if (first === 9) {
				tabs++;
				previous = 0;
			} else if (first === 32) {
				let lead = 0;
				while (start + lead < end && text.charCodeAt(start + lead) === 32) lead++;
				// A line of only spaces says nothing.
				if (start + lead < end) {
					spaces++;
					const step = lead - previous;
					if (step >= 2 && step <= 8) steps[step] = (steps[step] ?? 0) + 1;
					previous = lead;
				}
			} else {
				previous = 0;
			}
		}
		start = end + 1;
	}
	if (tabs > spaces) return 'tab:4';
	if (spaces === 0) return 'tab:4';
	let best = 0;
	let bestCount = 0;
	for (const key of Object.keys(steps)) {
		const step = Number(key);
		const count = steps[step]!;
		if (count > bestCount || (count === bestCount && step < best)) {
			best = step;
			bestCount = count;
		}
	}
	return `space:${best || 2}`;
}
