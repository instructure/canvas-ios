#!/usr/bin/env node

const fs = require('fs');

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

const affectedFiles = [
  'Horizon/Horizon/Sources/Features/Dashboard/View/DashboardViewModel.swift',
  'Horizon/Horizon/Sources/Common/Data/HCourse.swift'
];

const bugInfo = {
  summary,
  description,
  affectedFiles
};

fs.appendFileSync(process.env.GITHUB_OUTPUT, `affected_files<<EOF\n${JSON.stringify(affectedFiles)}\nEOF\n`);
fs.appendFileSync(process.env.GITHUB_OUTPUT, `bug_summary<<EOF\n${summary}\nEOF\n`);
fs.appendFileSync(process.env.GITHUB_OUTPUT, `bug_description<<EOF\n${description}\nEOF\n`);

console.log('Bug information extracted:');
console.log('Summary:', summary);
console.log('Affected files:', affectedFiles.join(', '));
