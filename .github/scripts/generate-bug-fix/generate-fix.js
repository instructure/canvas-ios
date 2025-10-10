#!/usr/bin/env node

const https = require('https');
const fs = require('fs');

const jiraIssue = JSON.parse(process.env.JIRA_RESPONSE || process.argv[2]);
const fileContents = JSON.parse(process.env.FILE_CONTENTS || process.argv[3]);

const summary = jiraIssue.fields.summary || '';
const description = jiraIssue.fields.description?.content?.[0]?.content?.[0]?.text || '';

const filesContext = Object.entries(fileContents)
  .filter(([_, content]) => content)
  .map(([filePath, content]) => {
    const lines = content.split('\n').length;
    const preview = content.length > 3000 ? content.substring(0, 3000) + '\n...(truncated)' : content;
    return `FILE: ${filePath}\n${preview}`;
  })
  .join('\n\n---\n\n');

const prompt = `You are fixing a bug in the Canvas Student iOS app (Career experience - Horizon module).

BUG REPORT:
Summary: ${summary}
Description: ${description}

CURRENT CODE:
${filesContext}

TASK:
Generate a fix for this bug. Analyze the code, identify the root cause, and provide the corrected code.

OUTPUT FORMAT - YOU MUST FOLLOW THIS EXACTLY:

FILE_START: [exact file path from above]
[complete fixed file content - include ALL code, do not truncate]
FILE_END

FILE_START: [next file path if needed]
[complete fixed file content]
FILE_END

CRITICAL RULES:
1. Start your response immediately with "FILE_START:" - NO explanation before it
2. Use exact format: "FILE_START: path/to/file.swift" (with colon and space)
3. End each file with "FILE_END" on its own line
4. Include the COMPLETE file - every import, every line, every closing brace
5. Do NOT use "..." or truncate anything
6. Only include files that actually need changes

Example:
FILE_START: Horizon/Horizon/Sources/File.swift
import UIKit
// Rest of complete file...
// Fixed: Added null check here
if let value = optionalValue {
    // use value
}
FILE_END

Keep the fix focused on the root cause. Don't refactor unrelated code.`;

const requestBody = JSON.stringify({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 8000,
  messages: [
    {
      role: 'user',
      content: prompt
    }
  ]
});

const options = {
  hostname: 'api.anthropic.com',
  path: '/v1/messages',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'x-api-key': process.env.ANTHROPIC_API_KEY,
    'anthropic-version': '2023-06-01',
    'Content-Length': Buffer.byteLength(requestBody)
  }
};

console.log('Generating fix with Claude...');

const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    try {
      const response = JSON.parse(data);
      const fixCode = response.content[0].text;

      fs.appendFileSync(process.env.GITHUB_OUTPUT, `fix_code<<EOF\n${fixCode}\nEOF\n`);

      console.log('✓ Fix generated successfully');
      console.log('Preview:', fixCode.substring(0, 200) + '...');
    } catch (error) {
      console.error('Error parsing Claude response:', error);
      console.error('Response data:', data);
      process.exit(1);
    }
  });
});

req.on('error', (error) => {
  console.error('Error calling Claude API:', error);
  process.exit(1);
});

req.write(requestBody);
req.end();
