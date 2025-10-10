#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');

const jiraIssue = JSON.parse(process.argv[2]);
const description = jiraIssue.fields.description?.content?.[0]?.content?.[0]?.text || '';
const summary = jiraIssue.fields.summary || '';

const keywords = extractKeywords(summary + ' ' + description);
let context = [];

const searchPaths = ['Horizon/', 'Core/', 'Student/'];

keywords.forEach(keyword => {
  const foundFiles = [];

  searchPaths.forEach(searchPath => {
    try {
      const grepResults = execSync(
        `grep -r --include="*.swift" -l "${keyword}" ${searchPath} 2>/dev/null | head -3`,
        { encoding: 'utf-8', maxBuffer: 1024 * 1024 }
      ).trim();

      if (grepResults) {
        foundFiles.push(...grepResults.split('\n'));
      }
    } catch (error) {
    }
  });

  if (foundFiles.length > 0) {
    const uniqueFiles = [...new Set(foundFiles)].slice(0, 3);
    context.push(`Files related to "${keyword}":`);
    uniqueFiles.forEach(file => context.push(`  - ${file}`));
  }
});

const contextString = context.length > 0
  ? context.join('\n')
  : 'No specific code matches found in codebase.';

fs.appendFileSync(process.env.GITHUB_OUTPUT, `context<<EOF\n${contextString}\nEOF\n`);

function extractKeywords(text) {
  const found = [];

  const capitalizedWords = text.match(/\b[A-Z][a-zA-Z]+\b/g) || [];
  found.push(...capitalizedWords);

  const longWords = text.split(/\s+/).filter(word =>
    word.length > 5 && /^[a-z]/.test(word)
  );
  found.push(...longWords);

  return [...new Set(found)].slice(0, 5);
}
