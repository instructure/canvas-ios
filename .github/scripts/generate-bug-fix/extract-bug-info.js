#!/usr/bin/env node

const fs = require('fs');
const https = require('https');
const { execSync } = require('child_process');

const jiraIssue = JSON.parse(process.env.JIRA_RESPONSE || process.argv[2]);
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
    }
  }

  return result.trim();
}

const description = extractDescription(jiraIssue.fields.description);

function searchCodebase(keywords) {
  const allFiles = [];
  const searchPaths = ['Horizon/', 'Core/', 'Student/'];

  keywords.forEach(keyword => {
    searchPaths.forEach(searchPath => {
      try {
        const results = execSync(
          `grep -r --include="*.swift" -l "${keyword}" ${searchPath} 2>/dev/null | head -10`,
          { encoding: 'utf-8', maxBuffer: 1024 * 1024 }
        ).trim();

        if (results) {
          allFiles.push(...results.split('\n'));
        }
      } catch (error) {
      }
    });
  });

  return [...new Set(allFiles)].slice(0, 20);
}

async function identifyAffectedFilesWithClaude(summary, description, codebaseFiles) {
  if (process.env.AFFECTED_FILES_OVERRIDE) {
    return JSON.parse(process.env.AFFECTED_FILES_OVERRIDE);
  }

  const prompt = `You are analyzing an iOS bug report for the Canvas Student app. The app has three main areas:
- Horizon (Career experience)
- Core (Shared code used by all apps)
- Student (Student app specific code)

BUG SUMMARY: ${summary}

BUG DESCRIPTION:
${description}

FILES FOUND IN CODEBASE (potentially related based on keywords):
${codebaseFiles.length > 0 ? codebaseFiles.join('\n') : 'No files found via keyword search'}

TASK: Identify the 2-4 files most likely to contain the bug. Consider:
1. The bug description and which components it mentions
2. Whether it's a UI issue (View files), data issue (Model files), or logic issue (ViewModel/Interactor files)
3. Whether it's specific to Horizon (Career) or could be in shared Core code

OUTPUT FORMAT (just the file paths, one per line, no explanations):
Path/To/File1.swift
Path/To/File2.swift
Path/To/File3.swift`;

  return new Promise((resolve, reject) => {
    const requestBody = JSON.stringify({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 1024,
      messages: [{ role: 'user', content: prompt }]
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
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          const text = response.content[0].text;
          const files = text.split('\n')
            .map(line => line.trim())
            .filter(line => line.endsWith('.swift'));
          resolve(files);
        } catch (error) {
          console.error('Error parsing Claude response:', error);
          resolve([]);
        }
      });
    });

    req.on('error', (error) => {
      console.error('Error calling Claude API:', error);
      resolve([]);
    });

    req.write(requestBody);
    req.end();
  });
}

async function main() {
  console.log('Extracting bug information...');
  console.log('Summary:', summary);

  const keywords = [
    ...summary.split(/\s+/),
    ...description.split(/\s+/)
  ].filter(word => word.length > 4 && /^[A-Z]/.test(word)).slice(0, 5);

  console.log('Searching codebase for keywords:', keywords.join(', '));
  const codebaseFiles = searchCodebase(keywords);

  console.log('Using Claude to identify affected files...');
  const affectedFiles = await identifyAffectedFilesWithClaude(summary, description, codebaseFiles);

  fs.appendFileSync(process.env.GITHUB_OUTPUT, `affected_files<<EOF\n${JSON.stringify(affectedFiles)}\nEOF\n`);
  fs.appendFileSync(process.env.GITHUB_OUTPUT, `bug_summary<<EOF\n${summary}\nEOF\n`);
  fs.appendFileSync(process.env.GITHUB_OUTPUT, `bug_description<<EOF\n${description}\nEOF\n`);

  console.log('✓ Bug information extracted');
  console.log('Affected files identified by Claude:', affectedFiles.join(', '));
  console.log('(Set AFFECTED_FILES_OVERRIDE env var to manually specify files)');
}

main().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
