#!/usr/bin/env node

const https = require('https');

const issueKey = process.argv[2];
const analysis = process.argv[3];
const codeContext = process.argv[4];

function markdownToADF(markdown) {
  const content = [];
  const lines = markdown.split('\n');
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    if (line.startsWith('```')) {
      const codeLines = [];
      i++;
      while (i < lines.length && !lines[i].startsWith('```')) {
        codeLines.push(lines[i]);
        i++;
      }
      if (codeLines.length > 0) {
        content.push({
          type: 'codeBlock',
          attrs: { language: 'swift' },
          content: [{ type: 'text', text: codeLines.join('\n') }]
        });
      }
      i++;
    } else if (line.startsWith('## ')) {
      content.push({
        type: 'heading',
        attrs: { level: 2 },
        content: [{ type: 'text', text: line.replace(/^## /, '') }]
      });
      i++;
    } else if (line.startsWith('# ')) {
      content.push({
        type: 'heading',
        attrs: { level: 1 },
        content: [{ type: 'text', text: line.replace(/^# /, '') }]
      });
      i++;
    } else if (line.startsWith('- ') || line.startsWith('• ')) {
      const listItems = [];
      while (i < lines.length && (lines[i].startsWith('- ') || lines[i].startsWith('• '))) {
        const itemText = lines[i].replace(/^[•-] /, '');
        if (itemText.trim()) {
          listItems.push({
            type: 'listItem',
            content: [{
              type: 'paragraph',
              content: parseBoldText(itemText)
            }]
          });
        }
        i++;
      }
      if (listItems.length > 0) {
        content.push({
          type: 'bulletList',
          content: listItems
        });
      }
    } else if (line.trim()) {
      content.push({
        type: 'paragraph',
        content: parseBoldText(line)
      });
      i++;
    } else {
      i++;
    }
  }

  return content;
}

function parseBoldText(text) {
  const parts = [];
  const regex = /\*\*(.+?)\*\*/g;
  let lastIndex = 0;
  let match;

  while ((match = regex.exec(text)) !== null) {
    if (match.index > lastIndex) {
      parts.push({ type: 'text', text: text.substring(lastIndex, match.index) });
    }
    parts.push({
      type: 'text',
      text: match[1],
      marks: [{ type: 'strong' }]
    });
    lastIndex = regex.lastIndex;
  }

  if (lastIndex < text.length) {
    parts.push({ type: 'text', text: text.substring(lastIndex) });
  }

  return parts.length > 0 ? parts : [{ type: 'text', text }];
}

const fullContent = [
  {
    type: 'paragraph',
    content: [
      { type: 'text', text: '🤖 ', marks: [] },
      { type: 'text', text: 'Automated Initial Analysis', marks: [{ type: 'strong' }] }
    ]
  },
  ...markdownToADF(analysis),
  {
    type: 'rule'
  },
  {
    type: 'heading',
    attrs: { level: 3 },
    content: [{ type: 'text', text: 'Code Context' }]
  },
  ...markdownToADF(codeContext)
];

const requestBody = JSON.stringify({
  body: {
    type: 'doc',
    version: 1,
    content: fullContent
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

console.log(`Posting comment to ${issueKey}...`);

const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      console.log(`✓ Successfully posted comment to ${issueKey}`);
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
