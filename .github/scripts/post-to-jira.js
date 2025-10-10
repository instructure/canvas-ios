#!/usr/bin/env node

const https = require('https');

const issueKey = process.argv[2];
const analysis = process.argv[3];
const codeContext = process.argv[4];

const commentText = `🤖 Automated Initial Analysis

${analysis}

---

**Code Context:**
${codeContext}`;

const requestBody = JSON.stringify({
  body: {
    type: 'doc',
    version: 1,
    content: [
      {
        type: 'paragraph',
        content: [
          {
            type: 'text',
            text: commentText
          }
        ]
      }
    ]
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
