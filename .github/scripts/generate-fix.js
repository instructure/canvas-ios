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

OUTPUT FORMAT:
For each file that needs changes, output:

FILE_START: [exact file path]
[complete fixed file content - do not use ... or truncate]
FILE_END

IMPORTANT:
- Provide the COMPLETE file content, not just changes
- Maintain all existing imports, comments, and structure
- Follow Swift style guidelines
- Add brief inline comments explaining the fix
- Only include files that need changes
- If the fix is simple (few lines), explain the change first

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
