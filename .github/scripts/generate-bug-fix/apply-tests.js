#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const testCode = process.env.TEST_CODE;

function extractTestFile(text) {
  const match = text.match(/TEST_FILE_START:\s*(.+?)\n([\s\S]+?)TEST_FILE_END/);

  if (match) {
    return {
      filePath: match[1].trim(),
      content: match[2].trim()
    };
  }

  return null;
}

const testFile = extractTestFile(testCode);

if (!testFile) {
  console.log('⚠️ No test file found in generated code');
  console.log('Skipping test application');
  process.exit(0);
}

console.log(`Applying tests to: ${testFile.filePath}`);

const fullPath = path.join(process.cwd(), testFile.filePath);

if (!fs.existsSync(fullPath)) {
  console.log(`Creating new test file...`);

  const dir = path.dirname(fullPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
} else {
  console.log(`Updating existing test file...`);
}

fs.writeFileSync(fullPath, testFile.content, 'utf-8');
console.log(`✓ Applied tests to: ${testFile.filePath}`);
