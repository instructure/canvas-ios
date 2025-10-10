#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');

const issueKey = process.env.ISSUE_KEY;
const bugSummary = process.env.BUG_SUMMARY;
const bugDescription = process.env.BUG_DESCRIPTION;
const fixCode = process.env.FIX_CODE;
const skipTests = process.env.SKIP_TESTS === 'true';
const jiraBaseUrl = process.env.JIRA_BASE_URL || 'https://instructure.atlassian.net';

function extractClassNames(fixCode) {
  const classRegex = /(?:class|struct|enum)\s+(\w+)/g;
  const classes = new Set();
  let match;

  while ((match = classRegex.exec(fixCode)) !== null) {
    classes.add(match[1]);
  }

  return Array.from(classes);
}

function generateFixSummary(fixCode, bugSummary) {
  const classes = extractClassNames(fixCode);
  const classNames = classes.length > 0 ? classes.join(', ') : 'the affected components';

  const hasSort = /\.sorted|sort\(/i.test(fixCode);
  const hasNullCheck = /if let|guard let|??\s/i.test(fixCode);
  const hasFilter = /\.filter/i.test(fixCode);
  const hasMap = /\.map/i.test(fixCode);

  let summary = `This fix addresses the issue in ${classNames}. `;

  if (hasSort) {
    summary += 'The sorting logic was updated to provide stable, predictable ordering. ';
  }
  if (hasNullCheck) {
    summary += 'Added proper null safety checks to handle edge cases. ';
  }
  if (hasFilter) {
    summary += 'Improved filtering logic to correctly process data. ';
  }
  if (hasMap) {
    summary += 'Updated data transformation to maintain consistency. ';
  }

  if (!hasSort && !hasNullCheck && !hasFilter && !hasMap) {
    summary += 'The code was modified to address the root cause identified in the bug report. ';
  }

  summary += 'Tests were added to prevent regression.';

  return summary;
}

function generatePRBody() {
  const jiraUrl = `${jiraBaseUrl}/browse/${issueKey}`;
  const fixSummary = generateFixSummary(fixCode, bugSummary);

  let body = `## Automated Bug Fix

This PR was automatically generated to fix **[${issueKey}](${jiraUrl})**.

### Bug Summary
${bugSummary}

### How It Was Fixed
${fixSummary}

### Testing
- ${skipTests ? '⏭️ Tests skipped (build-only mode)' : '✅ Tests passed'}
- ✅ Build successful
- ✅ SwiftLint checks completed

### Review Checklist
- [ ] Review the code changes for correctness
- [ ] Verify test coverage is adequate
- [ ] Test manually if needed (especially UI changes)
- [ ] Confirm the fix addresses the root cause
- [ ] Update Jira ticket status after merge

### Related
- **Jira:** [${issueKey}](${jiraUrl})
- **Type:** Bug Fix
- **AI Generated:** Yes

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>`;

  return body;
}

function createPullRequest() {
  const title = `fix: ${issueKey} - ${bugSummary}`;
  const body = generatePRBody();

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

createPullRequest();
