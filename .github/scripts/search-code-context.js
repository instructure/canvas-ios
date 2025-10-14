#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');

const jiraIssue = JSON.parse(process.argv[2]);
const description = jiraIssue.fields.description?.content?.[0]?.content?.[0]?.text || '';

const keywords = extractKeywords(description);
let context = [];

keywords.forEach(keyword => {
  try {
    const grepResults = execSync(
      `grep -r --include="*.swift" -l "${keyword}" Horizon/`,
      { encoding: 'utf-8', maxBuffer: 1024 * 1024 }
    ).trim();

    if (grepResults) {
      const files = grepResults.split('\n').slice(0, 5);
      context.push(`Files related to "${keyword}":`);
      files.forEach(file => context.push(`  - ${file}`));
    }
  } catch (error) {
  }
});

if (keywords.some(k => k.toLowerCase().includes('course'))) {
  context.push('\nRelated components:');
  context.push('  - Horizon/Features/Dashboard/CourseCardsWidget/');
}

const contextString = context.length > 0
  ? context.join('\n')
  : 'No specific code matches found.';

fs.appendFileSync(process.env.GITHUB_OUTPUT, `context<<EOF\n${contextString}\nEOF\n`);

function extractKeywords(text) {
  const commonTerms = ['course', 'dashboard', 'card', 'widget', 'crash', 'error', 'login', 'assignment'];
  const found = [];

  commonTerms.forEach(term => {
    if (text.toLowerCase().includes(term)) {
      found.push(term);
    }
  });

  const capitalizedWords = text.match(/\b[A-Z][a-zA-Z]+\b/g) || [];
  found.push(...capitalizedWords);

  return [...new Set(found)].slice(0, 5);
}
