#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const affectedFiles = JSON.parse(process.env.AFFECTED_FILES || process.argv[2]);

const fileContents = {};

for (const filePath of affectedFiles) {
  const fullPath = path.join(process.cwd(), filePath);

  if (fs.existsSync(fullPath)) {
    const content = fs.readFileSync(fullPath, 'utf-8');
    fileContents[filePath] = content;
    console.log(`✓ Read ${filePath} (${content.length} chars)`);
  } else {
    console.log(`⚠ File not found: ${filePath}`);
    fileContents[filePath] = null;
  }
}

const output = JSON.stringify(fileContents);
fs.appendFileSync(process.env.GITHUB_OUTPUT, `file_contents<<EOF\n${output}\nEOF\n`);

console.log(`Read ${Object.keys(fileContents).filter(k => fileContents[k]).length} files`);
