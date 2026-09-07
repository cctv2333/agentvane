#!/usr/bin/env node
// Skill-repo consistency / health check.
//   node scripts/check-consistency.mjs          → report, exit 0
//   node scripts/check-consistency.mjs --check  → exit 1 if anything is wrong
// Read-only.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const check = process.argv.includes("--check");
const errors = [];

const base = (p) => p.replace(/\\/g, "/").split("/").pop();

// --- 1. every SKILL.md: BOM-free, frontmatter name+description, name===folder ---
function walkSkills(dir) {
  const out = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, entry.name);
    if (entry.isDirectory()) out.push(...walkSkills(p));
    else if (entry.name === "SKILL.md") out.push(p);
  }
  return out;
}

const skillsDir = join(root, "skills");
const skills = statSync(skillsDir).isDirectory() ? walkSkills(skillsDir) : [];

for (const file of skills) {
  const bytes = readFileSync(file);
  if (bytes.length >= 3 && bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf) {
    errors.push(`${file}: starts with a UTF-8 BOM (remove it)`);
  }
  const f = readFileSync(file, "utf8");
  const m = f.match(/^---\s*\n([\s\S]*?)\n---\s*\n/);
  if (!m) { errors.push(`${file}: missing frontmatter`); continue; }
  const fm = m[1];
  const name = (fm.match(/^name:\s*(.+)$/m) || [])[1]?.trim();
  const desc = (fm.match(/^description:\s*(.+)$/m) || [])[1]?.trim();
  if (!name) errors.push(`${file}: frontmatter has no 'name'`);
  else if (!/^[a-z0-9-]+$/.test(name)) errors.push(`${file}: 'name' must be lowercase+hyphens (got '${name}')`);
  if (!desc) errors.push(`${file}: frontmatter has no 'description'`);
  const folder = base(dirname(file));
  if (name && name !== folder) errors.push(`${file}: 'name' (${name}) != folder (${folder})`);
}

// --- 2. phrases that must NOT drift out of copies that both carry them ---
const mustCarry = [
  ["宁可慢，不造假", ["skills/agentvane/SKILL.md"]],
  ["指令/数据边界", ["skills/agentvane/SKILL.md"]],
  ["禁止静默", ["skills/agentvane/SKILL.md", "skills/agentvane/reference.md"]],
];
for (const [phrase, files] of mustCarry) {
  for (const f of files) {
    const p = join(root, f);
    if (!statSync(p).isFile()) continue;
    if (!readFileSync(p, "utf8").includes(phrase)) errors.push(`${f}: missing required phrase '${phrase}'`);
  }
}

if (errors.length === 0) {
  console.log(`OK: ${skills.length} skill(s), frontmatter valid, no drift.`);
} else {
  for (const e of errors) console.log(`${check ? "✗ " : "• "}${e}`);
}
if (check && errors.length) {
  console.error(`\ncheck-consistency: ${errors.length} problem(s).`);
  process.exit(1);
}
