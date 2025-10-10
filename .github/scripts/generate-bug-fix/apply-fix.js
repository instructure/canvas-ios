#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const fixCode = process.env.FIX_CODE;
const affectedFiles = JSON.parse(process.env.AFFECTED_FILES);

function extractFileChanges(text) {
  const changes = {};
  const fileRegex = /FILE_START:\s*(.+?)\n([\s\S]+?)FILE_END/g;
  let match;

  while ((match = fileRegex.exec(text)) !== null) {
    const filePath = match[1].trim();
    const fileContent = match[2].trim();
    changes[filePath] = fileContent;
  }

  return changes;
}

const fileChanges = extractFileChanges(fixCode);

if (Object.keys(fileChanges).length === 0) {
  console.log('⚠️ No file changes found in fix code');
  console.log('This might be a manual fix or the format is unexpected');
  process.exit(1);
}

console.log(`Applying fixes to ${Object.keys(fileChanges).length} file(s)...`);

for (const [filePath, newContent] of Object.entries(fileChanges)) {
  const fullPath = path.join(process.cwd(), filePath);

  if (!fs.existsSync(fullPath)) {
    console.log(`⚠️ File not found: ${filePath}`);
    console.log(`Creating new file...`);

    const dir = path.dirname(fullPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }

  fs.writeFileSync(fullPath, newContent, 'utf-8');
  console.log(`✓ Applied fix to: ${filePath}`);
}

console.log(`\n✓ Successfully applied all fixes`);
