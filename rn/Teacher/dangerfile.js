// @flow

import { danger, warn, markdown } from 'danger'
import fs from 'fs'
import _ from 'lodash'

// Takes a list of file paths, and converts it into clickable links
const linkableFiles = (paths: Array<string>): string => {
  const repoURL = danger.github.pr.head.repo.html_url
  const ref = danger.github.pr.head.ref
  const links = paths.map((path: string) => {
    return createLink(`${repoURL}/blob/${ref}/${path}`, path)
  })
  return toSentence(links)
}

// ["1", "2", "3"] to "1, 2 and 3"
const toSentence = (array: Array<string>): string => {
  if (array.length === 1) { return array[0] }
  return array.slice(0, array.length - 1).join(', ') + ' and ' + array.pop()
}

// ("/href/thing", "name") to "<a href="/href/thing">name</a>"
const createLink = (href: string, text: string): string =>
  `<a href='${href}'>${text}</a>`

// New js files should have `@flow` at the top
const newJSFiles = danger.git.created_files.filter((path: string) => path.endsWith('js'))
const unFlowedFiles = newJSFiles.filter((filepath: string) => {
  // Navigating up two directories cuz this dangerfile isn't at the project root
  const content = fs.readFileSync('../../' + filepath)
  return !content.includes('@flow')
})

if (unFlowedFiles.length > 0) {
  warn(`These new JS files do not have Flow enabled: ${linkableFiles(unFlowedFiles)}`)
}

// Warns if there are changes to package.json without changes to yarn.lock.
const packageChanged = danger.git.modified_files.includes('package.json')
const lockfileChanged = danger.git.modified_files.includes('yarn.lock')
if (packageChanged && !lockfileChanged) {
  const message = 'Changes were made to package.json, but not to yarn.lock'
  const idea = 'Perhaps you need to run `yarn install`?'
  warn(`${message} - <i>${idea}</i>`)
}

// Checks for corresponding tests to js files in the commit's modified files
const testFiles = danger.git.created_files.filter((path: string) => {
  return path.includes('__tests__/') && !path.includes('__snapshots__/')
})

const logicalTestPaths = testFiles.map((path: string) => {
  return path.replace(/__tests__\//, '').replace(/.test.js/, '.js')
})

const sourcePaths = danger.git.created_files.filter((path: string) => {
  return path.includes('src/') && !path.includes('__tests__/') && path.includes('.js')
})

const untestedFiles = _.difference(sourcePaths, logicalTestPaths)
if (untestedFiles.length > 0) {
  warn('The following files were added without tests: ' + linkableFiles(untestedFiles))
}

// Warns if there is not reference to a jira ticket starting with MBL- in the PR title or body
if (!danger.github.pr.title.match(/mbl-/i) && !danger.github.pr.body.match(/mbl-/i)) {
  warn('Neither the title nor body of the pull request reference a JIRA ticket.')
}

// Reports the coverage numbers
const coverageContent = JSON.parse(fs.readFileSync('coverage/coverage-summary.json', 'utf8'))
const developCoverageContent = JSON.parse(fs.readFileSync('coverage-summary-develop.json', 'utf8'))
const statementsCoverageDiff = coverageContent.total.statements.pct - developCoverageContent.total.statements.pct
const branchesCoverageDiff = coverageContent.total.branches.pct - developCoverageContent.total.branches.pct
const functionsCoverageDiff = coverageContent.total.functions.pct - developCoverageContent.total.functions.pct
const linesCoverageDiff = coverageContent.total.lines.pct - developCoverageContent.total.lines.pct
var coverageMarkdown = 'Coverage | New % | Delta\n' +
                       '---------- | ---------- | ----------\n' +
                       'Statements |' + coverageContent.total.statements.pct + '% | ' + statementsCoverageDiff + '%\n' +
                       'Branches |' + coverageContent.total.branches.pct + '% | ' + branchesCoverageDiff + '%\n' +
                       'Functions |' + coverageContent.total.functions.pct + '% | ' + functionsCoverageDiff + '%\n' +
                       'Lines |' + coverageContent.total.lines.pct + '% | ' + linesCoverageDiff + '%\n'
markdown(coverageMarkdown)

const coverageDropWarnThreshold = -5
if (statementsCoverageDiff < coverageDropWarnThreshold || branchesCoverageDiff < coverageDropWarnThreshold || functionsCoverageDiff < coverageDropWarnThreshold || linesCoverageDiff < coverageDropWarnThreshold) {
  warn('One or more of your coverage numbers have dropped more than 5% because of this PR. Get with the program, dude.')
}
