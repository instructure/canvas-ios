#!/usr/bin/env node

const https = require('https');

const issueKey = process.env.ISSUE_KEY;
const fixSuggestion = process.env.FIX_SUGGESTION;
const testCode = process.env.TEST_CODE;

function extractCodeBlocks(text) {
  const blocks = [];
  const fileRegex = /FILE_START:\s*(.+?)\n([\s\S]+?)FILE_END/g;
  let match;

  while ((match = fileRegex.exec(text)) !== null) {
    blocks.push({
      type: 'fix',
      filePath: match[1].trim(),
      code: match[2].trim()
    });
  }

  const testFileRegex = /TEST_FILE_START:\s*(.+?)\n([\s\S]+?)TEST_FILE_END/g;
  while ((match = testFileRegex.exec(text)) !== null) {
    blocks.push({
      type: 'test',
      filePath: match[1].trim(),
      code: match[2].trim()
    });
  }

  return blocks;
}

const fixBlocks = extractCodeBlocks(fixSuggestion);
const testBlocks = extractCodeBlocks(testCode);

const content = [
  {
    type: 'paragraph',
    content: [
      { type: 'text', text: '🤖 ', marks: [] },
      { type: 'text', text: 'Suggested Fix', marks: [{ type: 'strong' }] }
    ]
  },
  {
    type: 'paragraph',
    content: [
      { type: 'text', text: 'Claude has generated a suggested fix for this bug. Review the code below and apply it manually if it looks correct.' }
    ]
  }
];

if (fixBlocks.length > 0) {
  content.push({
    type: 'heading',
    attrs: { level: 2 },
    content: [{ type: 'text', text: 'Proposed Changes' }]
  });

  for (const block of fixBlocks) {
    content.push({
      type: 'paragraph',
      content: [
        { type: 'text', text: 'File: ', marks: [{ type: 'strong' }] },
        { type: 'text', text: block.filePath, marks: [{ type: 'code' }] }
      ]
    });
    content.push({
      type: 'codeBlock',
      attrs: { language: 'swift' },
      content: [{ type: 'text', text: block.code }]
    });
  }
} else {
  content.push({
    type: 'paragraph',
    content: [{ type: 'text', text: fixSuggestion }]
  });
}

if (testBlocks.length > 0) {
  content.push({ type: 'rule' });
  content.push({
    type: 'heading',
    attrs: { level: 2 },
    content: [{ type: 'text', text: 'Suggested Tests' }]
  });

  for (const block of testBlocks) {
    content.push({
      type: 'paragraph',
      content: [
        { type: 'text', text: 'Test File: ', marks: [{ type: 'strong' }] },
        { type: 'text', text: block.filePath, marks: [{ type: 'code' }] }
      ]
    });
    content.push({
      type: 'codeBlock',
      attrs: { language: 'swift' },
      content: [{ type: 'text', text: block.code }]
    });
  }
}

content.push({ type: 'rule' });
content.push({
  type: 'paragraph',
  content: [
    { type: 'text', text: '⚠️ ', marks: [] },
    { type: 'text', text: 'Important:', marks: [{ type: 'strong' }] },
    { type: 'text', text: ' This is an AI-generated suggestion. Please review carefully, test thoroughly, and adjust as needed before committing.' }
  ]
});

const requestBody = JSON.stringify({
  body: {
    type: 'doc',
    version: 1,
    content
  }
});

const authString = `${process.env.JIRA_EMAIL}:${process.env.JIRA_API_TOKEN}`;
const authHeader = Buffer.from(authString).toString('base64');

const url = new URL(`${process.env.JIRA_BASE_URL}/rest/api/3/issue/${issueKey}/comment`);

const options = {
  hostname: url.hostname,
  path: url.pathname,
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Basic ${authHeader}`,
    'Content-Length': Buffer.byteLength(requestBody)
  }
};

console.log(`Posting fix suggestion to ${issueKey}...`);

const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      console.log(`✓ Successfully posted fix suggestion to ${issueKey}`);
      console.log(`Status: ${res.statusCode}`);
    } else {
      console.error(`✗ Failed to post comment. Status: ${res.statusCode}`);
      console.error('Response:', data);
      process.exit(1);
    }
  });
});

req.on('error', (error) => {
  console.error('Error posting to Jira:', error);
  process.exit(1);
});

req.write(requestBody);
req.end();
