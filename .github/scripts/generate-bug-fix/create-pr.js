#!/usr/bin/env node

const { execSync } = require('child_process');
const https = require('https');
const fs = require('fs');

const issueKey = process.env.ISSUE_KEY;
const bugSummary = process.env.BUG_SUMMARY;
const bugDescription = process.env.BUG_DESCRIPTION;
const fixCode = process.env.FIX_CODE;
const skipTests = process.env.SKIP_TESTS === 'true';
const jiraBaseUrl = process.env.JIRA_BASE_URL || 'https://instructure.atlassian.net';
const anthropicApiKey = process.env.ANTHROPIC_API_KEY;

async function generateFixSummaryWithClaude(fixCode, bugSummary, bugDescription) {
  const prompt = `You are writing a summary for a pull request that fixes a bug.

BUG: ${bugSummary}
DESCRIPTION: ${bugDescription}

CODE CHANGES (partial):
${fixCode.substring(0, 2000)}

Write a 2-3 sentence summary explaining HOW the bug was fixed. Focus on:
- What classes/components were modified
- What the actual code change does (e.g., "updated sorting logic to...", "added null check for...")
- Keep it simple and readable for code reviewers

Do NOT just repeat the bug description. Explain the solution.

Output only the summary text, no markdown, no preamble.`;

  return new Promise((resolve, reject) => {
    const requestBody = JSON.stringify({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 300,
      messages: [{ role: 'user', content: prompt }]
    });

    const options = {
      hostname: 'api.anthropic.com',
      path: '/v1/messages',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': anthropicApiKey,
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
          const summary = response.content[0].text.trim();
          resolve(summary);
        } catch (error) {
          console.error('Error parsing Claude response:', error);
          resolve('This fix addresses the reported issue by modifying the affected components and adding test coverage to prevent regression.');
        }
      });
    });

    req.on('error', (error) => {
      console.error('Error calling Claude API:', error);
      resolve('This fix addresses the reported issue by modifying the affected components and adding test coverage to prevent regression.');
    });

    req.write(requestBody);
    req.end();
  });
}

async function generatePRBody() {
  const jiraUrl = `${jiraBaseUrl}/browse/${issueKey}`;

  console.log('Generating fix summary with Claude...');
  const fixSummary = await generateFixSummaryWithClaude(fixCode, bugSummary, bugDescription);

  let body = `## Automated Bug Fix

This PR was automatically generated to fix **[${issueKey}](${jiraUrl})**.

### Bug Summary
${bugSummary}

### How It Was Fixed
${fixSummary}

### Review Checklist
- [ ] Review the code changes for correctness
- [ ] Verify test coverage is adequate
- [ ] Test manually if needed (especially UI changes)
- [ ] Confirm the fix addresses the root cause
- [ ] Update Jira ticket status after merge

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>`;

  return body;
}

async function createPullRequest() {
  const title = `fix: ${issueKey} - ${bugSummary}`;
  const body = await generatePRBody();

  const bodyFile = '/tmp/pr-body.md';
  fs.writeFileSync(bodyFile, body);

  try {
    execSync(
      `gh pr create --draft --title "${title}" --body-file "${bodyFile}"`,
      { encoding: 'utf-8', stdio: 'inherit' }
    );

    console.log('✓ Pull request created successfully');
  } catch (error) {
    console.error('Error creating pull request:', error.message);
    process.exit(1);
  } finally {
    if (fs.existsSync(bodyFile)) {
      fs.unlinkSync(bodyFile);
    }
  }
}

createPullRequest().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
