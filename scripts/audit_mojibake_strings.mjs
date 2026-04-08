import fs from 'node:fs';
import path from 'node:path';

const TARGET_DIRS = ['lib/screens', 'lib/widgets'];
const suspicious = [];

function walk(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(full);
      continue;
    }
    if (!entry.name.endsWith('.dart')) continue;
    auditFile(full);
  }
}

function auditFile(file) {
  const raw = fs.readFileSync(file, 'utf8');
  const lines = raw.split(/\r?\n/);

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    const trimmed = line.trim();
    if (!trimmed.includes("'")) continue;

    const hasBrokenHint =
      trimmed.includes('??{') ||
      /[\u3130-\u318F][\u00A0-\u024F]/.test(trimmed) ||
      /\?[\uAC00-\uD7A3]/.test(trimmed) ||
      /[\uAC00-\uD7A3]\?/.test(trimmed);

    if (hasBrokenHint) {
      suspicious.push({ file, line: i + 1, text: trimmed.slice(0, 180) });
    }
  }
}

for (const dir of TARGET_DIRS) {
  if (fs.existsSync(dir)) walk(dir);
}

console.log(`[audit:strings] suspicious=${suspicious.length}`);
for (const item of suspicious) {
  console.log(`${item.file}:${item.line} :: ${item.text}`);
}

if (suspicious.length > 0) {
  process.exitCode = 1;
}
