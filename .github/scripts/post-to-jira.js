#!/usr/bin/env node

const https = require('https');

const issueKey = process.env.ISSUE_KEY || process.argv[2];
const analysis = process.env.ANALYSIS_TEXT || process.argv[3];
const codeContext = process.env.CODE_CONTEXT || process.argv[4];

function parseAnalysisToADF(text) {
  const content = [];

  const severityMatch = text.match(/SEVERITY:\s*(.+?)[\n\r]/);
  const justificationMatch = text.match(/JUSTIFICATION:\s*(.+?)[\n\r]/);
  const componentMatch = text.match(/AFFECTED COMPONENT:\s*(.+?)[\n\r]/);
  const rootCauseMatch = text.match(/ROOT CAUSE:\s*(.+?)[\n\r]/);
  const detailsMatch = text.match(/DETAILS:\s*(.+?)[\n\r]/);
  const codeMatch = text.match(/CODE_START\s+([\s\S]+?)\s+CODE_END/);
  const filesMatch = text.match(/FILES:\s*(.+?)[\n\r]/);
  const nextStepsMatch = text.match(/NEXT STEPS:\s*(.+?)[\n\r]/);
  const missingInfoMatch = text.match(/MISSING INFO:\s*(.+?)[\n\r]/);

  content.push({
    type: 'heading',
    attrs: { level: 2 },
    content: [{ type: 'text', text: '1. Severity' }]
  });

  if (severityMatch && justificationMatch) {
    content.push({
      type: 'paragraph',
      content: [
        { type: 'text', text: severityMatch[1].trim(), marks: [{ type: 'strong' }] },
        { type: 'text', text: ' - ' + justificationMatch[1].trim() }
      ]
    });
  }

  content.push({
    type: 'heading',
    attrs: { level: 2 },
    content: [{ type: 'text', text: '2. Affected Component' }]
  });

  if (componentMatch) {
    content.push({
      type: 'paragraph',
      content: [{ type: 'text', text: componentMatch[1].trim() }]
    });
  }

  content.push({
    type: 'heading',
    attrs: { level: 2 },
    content: [{ type: 'text', text: '3. Root Cause' }]
  });

  if (rootCauseMatch) {
    content.push({
      type: 'paragraph',
      content: [{ type: 'text', text: rootCauseMatch[1].trim(), marks: [{ type: 'strong' }] }]
    });
  }

  if (detailsMatch) {
    content.push({
      type: 'paragraph',
      content: [{ type: 'text', text: detailsMatch[1].trim() }]
    });
  }

  content.push({
    type: 'heading',
    attrs: { level: 2 },
    content: [{ type: 'text', text: '4. Recommended Fix' }]
  });

  const fixSection = text.match(/RECOMMENDED FIX:\s*([\s\S]+?)(?=TRIAGE NOTES:|$)/);
  if (fixSection) {
    const fixText = fixSection[1];
    const descriptionBeforeCode = fixText.split('CODE_START')[0].trim();

    if (descriptionBeforeCode && !descriptionBeforeCode.includes('[Brief description')) {
      content.push({
        type: 'paragraph',
        content: [{ type: 'text', text: descriptionBeforeCode }]
      });
    }
  }

  if (codeMatch) {
    content.push({
      type: 'codeBlock',
      attrs: { language: 'swift' },
      content: [{ type: 'text', text: codeMatch[1].trim() }]
    });
  } else {
    content.push({
      type: 'paragraph',
      content: [{ type: 'text', text: 'See triage notes for implementation guidance.' }]
    });
  }

  content.push({
    type: 'heading',
    attrs: { level: 2 },
    content: [{ type: 'text', text: '5. Triage Notes' }]
  });

  if (filesMatch) {
    const files = filesMatch[1].split(',').map(f => f.trim()).filter(f => f);
    if (files.length > 0) {
      content.push({
        type: 'paragraph',
        content: [{ type: 'text', text: 'Key files to investigate:', marks: [{ type: 'strong' }] }]
      });
      content.push({
        type: 'bulletList',
        content: files.slice(0, 5).map(file => ({
          type: 'listItem',
          content: [{
            type: 'paragraph',
            content: [{ type: 'text', text: file }]
          }]
        }))
      });
    }
  }

  if (nextStepsMatch) {
    content.push({
      type: 'paragraph',
      content: [{ type: 'text', text: 'Next steps:', marks: [{ type: 'strong' }] }]
    });
    content.push({
      type: 'paragraph',
      content: [{ type: 'text', text: nextStepsMatch[1].trim() }]
    });
  }

  if (missingInfoMatch && missingInfoMatch[1].trim().toLowerCase() !== 'none') {
    content.push({
      type: 'paragraph',
      content: [{ type: 'text', text: 'Missing information:', marks: [{ type: 'strong' }] }]
    });
    content.push({
      type: 'paragraph',
      content: [{ type: 'text', text: missingInfoMatch[1].trim() }]
    });
  }

  return content;
}

function parseCodeContext(text) {
  const content = [];
  const lines = text.split('\n').filter(l => l.trim() && !l.includes('Related components:'));

  const groups = {};
  for (const line of lines) {
    const match = line.match(/Files related to "(.+?)":/);
    if (match) {
      const keyword = match[1];
      groups[keyword] = [];
    } else if (line.trim().startsWith('-')) {
      const lastKey = Object.keys(groups)[Object.keys(groups).length - 1];
      if (lastKey && groups[lastKey].length < 3) {
        groups[lastKey].push(line.trim().substring(1).trim());
      }
    }
  }

  const relevantGroups = ['course', 'dashboard', 'card'].filter(k => groups[k]);

  for (const keyword of relevantGroups) {
    if (groups[keyword] && groups[keyword].length > 0) {
      content.push({
        type: 'paragraph',
        content: [{ type: 'text', text: `Files related to "${keyword}":`, marks: [{ type: 'strong' }] }]
      });
      content.push({
        type: 'bulletList',
        content: groups[keyword].map(file => ({
          type: 'listItem',
          content: [{
            type: 'paragraph',
            content: [{ type: 'text', text: file }]
          }]
        }))
      });
    }
  }

  return content;
}

const fullContent = [
  {
    type: 'paragraph',
    content: [
      { type: 'text', text: '🤖 ', marks: [] },
      { type: 'text', text: 'Automated Initial Analysis', marks: [{ type: 'strong' }] }
    ]
  },
  ...parseAnalysisToADF(analysis)
];

if (codeContext && codeContext.trim()) {
  fullContent.push({ type: 'rule' });
  fullContent.push({
    type: 'heading',
    attrs: { level: 3 },
    content: [{ type: 'text', text: 'Code Context' }]
  });
  fullContent.push(...parseCodeContext(codeContext));
}

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
