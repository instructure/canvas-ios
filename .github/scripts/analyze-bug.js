#!/usr/bin/env node

const https = require('https');

const jiraIssue = JSON.parse(process.argv[2]);

const summary = jiraIssue.fields.summary || '';

function extractDescription(descriptionObj) {
  if (!descriptionObj || !descriptionObj.content) {
    return '';
  }

  function processContent(content) {
    let text = '';
    for (const item of content) {
      if (item.type === 'text') {
        text += item.text;
      } else if (item.type === 'hardBreak') {
        text += '\n';
      } else if (item.type === 'mention') {
        text += `@${item.attrs?.text || 'user'}`;
      } else if (item.type === 'emoji') {
        text += item.attrs?.shortName || '';
      } else if (item.type === 'inlineCard') {
        text += item.attrs?.url || '';
      }
    }
    return text;
  }

  let result = '';
  for (const block of descriptionObj.content) {
    if (block.type === 'paragraph' && block.content) {
      result += processContent(block.content) + '\n';
    } else if (block.type === 'bulletList' && block.content) {
      for (const listItem of block.content) {
        if (listItem.content) {
          for (const para of listItem.content) {
            if (para.content) {
              result += '• ' + processContent(para.content) + '\n';
            }
          }
        }
      }
    } else if (block.type === 'orderedList' && block.content) {
      let index = block.attrs?.order || 1;
      for (const listItem of block.content) {
        if (listItem.content) {
          for (const para of listItem.content) {
            if (para.content) {
              result += `${index}. ` + processContent(para.content) + '\n';
              index++;
            }
          }
        }
      }
    } else if (block.type === 'codeBlock') {
      result += '```\n' + (block.content?.[0]?.text || '') + '\n```\n';
    } else if (block.type === 'heading' && block.content) {
      const level = block.attrs?.level || 1;
      result += '#'.repeat(level) + ' ' + processContent(block.content) + '\n';
    }
  }

  return result.trim();
}

const description = extractDescription(jiraIssue.fields.description);
const issueType = jiraIssue.fields.issuetype?.name || '';
const priority = jiraIssue.fields.priority?.name || '';

const prompt = `You are analyzing an iOS bug report for the Canvas Student app (Career experience - Horizon module).

Bug Report:
- Summary: ${summary}
- Description: ${description}
- Type: ${issueType}
- Priority: ${priority}

Provide a CONCISE analysis with these sections. Use plain text formatting without markdown symbols:

SEVERITY: [Critical/High/Medium/Low]
JUSTIFICATION: [One sentence]

AFFECTED COMPONENT: [Primary area - e.g., Dashboard, Course Cards, etc.]

ROOT CAUSE: [Most likely cause]
DETAILS: [Brief explanation]

RECOMMENDED FIX:
[Brief description of the fix approach]

CODE_START
// Actual Swift code example here
courses.sorted { c1, c2 in
    // sorting logic
}
CODE_END

IMPORTANT: Always include CODE_START and CODE_END markers with Swift code between them, even if it's a simple example.

TRIAGE NOTES:
FILES: [List 3-5 most relevant Swift files, comma-separated]
NEXT STEPS: [2-3 concrete actions]
MISSING INFO: [What else is needed, if anything]

Keep concise and actionable. No markdown formatting symbols.`;

const requestBody = JSON.stringify({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 2048,
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

const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    try {
      const response = JSON.parse(data);
      const analysis = response.content[0].text;

      const fs = require('fs');
      fs.writeFileSync(process.env.GITHUB_OUTPUT, `analysis<<EOF\n${analysis}\nEOF\n`);

      console.log(analysis);
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
