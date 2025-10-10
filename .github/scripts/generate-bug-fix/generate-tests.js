#!/usr/bin/env node

const https = require('https');
const fs = require('fs');
const path = require('path');

const fixCode = process.env.FIX_CODE || process.argv[2];

if (!process.env.AFFECTED_FILES) {
  console.error('❌ AFFECTED_FILES environment variable is not set');
  console.error('Available env vars:', Object.keys(process.env).filter(k => k.includes('AFFECTED')));
  process.exit(1);
}

let affectedFiles;
try {
  affectedFiles = JSON.parse(process.env.AFFECTED_FILES);
} catch (error) {
  console.error('❌ Failed to parse AFFECTED_FILES as JSON');
  console.error('AFFECTED_FILES content:', process.env.AFFECTED_FILES);
  console.error('Parse error:', error.message);
  process.exit(1);
}

if (!Array.isArray(affectedFiles) || affectedFiles.length === 0) {
  console.error('❌ AFFECTED_FILES must be a non-empty array');
  console.error('Got:', affectedFiles);
  process.exit(1);
}

const mainFile = affectedFiles[0];
console.log(`Generating tests for main file: ${mainFile}`);
const { execSync } = require('child_process');

function findTestDirectory(sourceFile) {
  const dir = path.dirname(sourceFile);
  const projectRoot = dir.split('/')[0];

  try {
    const testDirs = execSync(
      `find ${projectRoot} -type d -name "*Test*" 2>/dev/null | head -5`,
      { encoding: 'utf-8' }
    ).trim().split('\n').filter(Boolean);

    if (testDirs.length > 0) {
      return testDirs[0];
    }
  } catch (error) {
  }

  return `${projectRoot}/Tests`;
}

function getTestFilePath(filePath) {
  const fileName = path.basename(filePath, '.swift');
  const testFileName = `${fileName}Tests.swift`;
  const testDir = findTestDirectory(filePath);

  return path.join(testDir, testFileName);
}

const testFilePath = getTestFilePath(mainFile);

let existingTestContent = '';
if (fs.existsSync(testFilePath)) {
  existingTestContent = fs.readFileSync(testFilePath, 'utf-8');
  console.log(`Found existing test file: ${testFilePath}`);
} else {
  console.log(`No existing test file found at: ${testFilePath}`);
}

const prompt = `You are writing unit tests for a bug fix in the Canvas Student iOS app.

BUG FIX CODE:
${fixCode}

${existingTestContent ? `EXISTING TEST FILE:\n${existingTestContent}\n\n` : ''}

TASK:
${existingTestContent ? 'Add new test cases to the existing test file' : 'Create a new test file'} that validates the fix and prevents regression.

Test Requirements:
1. Test the bug scenario (should fail before fix, pass after)
2. Test edge cases related to the fix
3. Follow existing test patterns in the project
4. Use XCTest framework
5. Mock dependencies if needed

OUTPUT FORMAT:
TEST_FILE_START: ${testFilePath}
[complete test file content]
TEST_FILE_END

IMPORTANT:
- If existing tests: Add new test methods, preserve existing tests
- If new file: Include imports, class declaration, and setup/teardown
- Use descriptive test names: test_bugDescription_expectedBehavior()
- Add comments explaining what each test validates
- Keep tests focused and isolated`;

const requestBody = JSON.stringify({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 4096,
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

console.log('Generating tests with Claude...');

const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    try {
      const response = JSON.parse(data);
      const testCode = response.content[0].text;

      fs.appendFileSync(process.env.GITHUB_OUTPUT, `test_code<<EOF\n${testCode}\nEOF\n`);

      console.log('✓ Tests generated successfully');
      console.log('Preview:', testCode.substring(0, 200) + '...');
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
