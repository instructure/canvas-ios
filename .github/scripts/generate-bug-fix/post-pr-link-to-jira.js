#!/usr/bin/env node

const https = require('https');

const issueKey = process.env.ISSUE_KEY;
const prUrl = process.env.PR_URL;

const content = [
  {
    type: 'paragraph',
    content: [
      { type: 'text', text: '🔗 ', marks: [] },
      { type: 'text', text: 'Automated Pull Request Created', marks: [{ type: 'strong' }] }
    ]
  },
  {
    type: 'paragraph',
    content: [
      { type: 'text', text: 'An automated fix has been applied and a draft pull request has been created.' }
    ]
  },
  {
    type: 'paragraph',
    content: [
      { type: 'text', text: 'Pull Request: ', marks: [{ type: 'strong' }] },
      { type: 'text', text: prUrl, marks: [{ type: 'link', attrs: { href: prUrl } }] }
    ]
  },
  {
    type: 'paragraph',
    content: [
      { type: 'text', text: 'Status:', marks: [{ type: 'strong' }] }
    ]
  },
  {
    type: 'bulletList',
    content: [
      {
        type: 'listItem',
        content: [{
          type: 'paragraph',
          content: [{ type: 'text', text: '✅ Code fix applied' }]
        }]
      },
      {
        type: 'listItem',
        content: [{
          type: 'paragraph',
          content: [{ type: 'text', text: '✅ Tests added/updated' }]
        }]
      },
      {
        type: 'listItem',
        content: [{
          type: 'paragraph',
          content: [{ type: 'text', text: '✅ Build passed' }]
        }]
      },
      {
        type: 'listItem',
        content: [{
          type: 'paragraph',
          content: [{ type: 'text', text: '✅ Tests passed' }]
        }]
      }
    ]
  },
  {
    type: 'paragraph',
    content: [
      { type: 'text', text: '⚠️ Action Required:', marks: [{ type: 'strong' }] },
      { type: 'text', text: ' Please review the PR carefully before merging.' }
    ]
  }
];

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

console.log(`Posting PR link to ${issueKey}...`);

const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      console.log(`✓ Successfully posted PR link to ${issueKey}`);
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
