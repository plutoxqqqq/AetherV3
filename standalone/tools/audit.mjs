import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const repository = path.resolve(import.meta.dirname, '../..');
const pairs = [
  ['games/universal.lua', 'standalone/games/universal.lua'],
  ['games/6872274481.lua', 'standalone/games/6872274481.lua'],
];

function constructorCounts(source) {
  const counts = new Map();
  for (const match of source.matchAll(/:Create([A-Za-z0-9_]+)\s*\(/g)) {
    counts.set(match[1], (counts.get(match[1]) ?? 0) + 1);
  }
  return Object.fromEntries([...counts].sort(([a], [b]) => a.localeCompare(b)));
}

let failed = false;
for (const [sourceName, portName] of pairs) {
  const source = fs.readFileSync(path.join(repository, sourceName), 'utf8');
  const port = fs.readFileSync(path.join(repository, portName), 'utf8');
  const expected = constructorCounts(source);
  const actual = constructorCounts(port);
  const equal = JSON.stringify(expected) === JSON.stringify(actual);
  console.log(`${portName}: ${actual.Module ?? 0} modules; constructor parity ${equal ? 'OK' : 'FAILED'}`);
  if (!equal) failed = true;
}

for (const name of ['standalone/runtime.lua', 'standalone/games/universal.lua', 'standalone/games/6872274481.lua']) {
  const source = fs.readFileSync(path.join(repository, name), 'utf8');
  const hasLegacyReference = /shared\.vape\b|\b_G\.vape\b|getgenv\(\)\.vape\b|\bvape\./i.test(source);
  console.log(`${name}: legacy framework references ${hasLegacyReference ? 'FOUND' : 'none'}`);
  if (hasLegacyReference) failed = true;
}

process.exitCode = failed ? 1 : 0;
