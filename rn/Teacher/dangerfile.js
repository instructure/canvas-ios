//
// Copyright (C) 2017-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import { danger, warn, markdown, fail } from 'danger'
import fs from 'fs'
import path from 'path'
import _ from 'lodash'

// Takes a list of file paths, and converts it into clickable links
function linkableFiles (paths: Array<string>): string {
  const repoURL = danger.github.pr.head.repo.html_url
  const ref = danger.github.pr.head.ref
  const links = paths.map((path: string) => {
    const href = `${repoURL}/blob/${ref}${path}`
    return createLink(href, path)
  })
  return toSentence(links)
}

// ["1", "2", "3"] to "1, 2 and 3"
function toSentence (array: Array<string>): string {
  if (array.length === 1) { return array[0] }
  return array.slice(0, array.length - 1).join(', ') + ' and ' + array.pop()
}

// ("/href/thing", "name") to "<a href="/href/thing">name</a>"
function createLink (href: string, text: string): string {
  return `<a href='${href}'>${text}</a>`
}

// New js files should have `@flow` at the top
export function annotations (): void {
  const newJSFiles = danger.git.created_files.filter((path: string) => path.endsWith('js'))
  const unFlowedFiles = newJSFiles.filter((filepath: string) => {
    // Navigating up two directories cuz this dangerfile isn't at the project root
    const content = fs.readFileSync(path.join('../../', filepath))
    if (!content) return false
    return !content.includes('@flow')
  })

  if (unFlowedFiles.length > 0) {
    warn(`Please add @flow to these files: ${linkableFiles(unFlowedFiles)}`)
  }
}

// Checks for corresponding tests to js files in the commit's modified files
export function untestedFiles (): void {
  const testFiles = danger.git.created_files.filter((path: string) => {
    return path.includes('__tests__/') && !path.includes('__snapshots__/')
  })

  const logicalTestPaths = testFiles.map((path: string) => {
    return path.replace(/__tests__\//, '').replace(/.test.js/, '.js')
  })

  const sourcePaths = danger.git.created_files.filter((path: string) => {
    const exclude = ['__tests__/', '__snapshots__/', '__mocks__/', '__templates__/', 'flow/']
    return path.includes('src/') &&
      path.includes('js') &&
      exclude.reduce((accl, e) => accl && !path.includes(e), true)
  })

  const untestedFiles = _.difference(sourcePaths, logicalTestPaths)
  if (untestedFiles.length > 0) {
    warn('Please add tests for these files: ' + linkableFiles(untestedFiles))
  }
}

// Reports the coverage numbers
export function coverageReport (): void {
  const coverageContent = JSON.parse(fs.readFileSync('coverage/coverage-summary.json', 'utf8'))
  const developCoverageContent = JSON.parse(fs.readFileSync('coverage-summary-develop.json', 'utf8'))
  const statementsCoverageDiff = coverageContent.total.statements.pct - developCoverageContent.total.statements.pct
  const branchesCoverageDiff = coverageContent.total.branches.pct - developCoverageContent.total.branches.pct
  const functionsCoverageDiff = coverageContent.total.functions.pct - developCoverageContent.total.functions.pct
  const linesCoverageDiff = coverageContent.total.lines.pct - developCoverageContent.total.lines.pct
  var coverageMarkdown = 'Coverage | New % | Delta\n' +
                         '---------- | ---------- | ----------\n' +
                         'Statements |' + coverageContent.total.statements.pct + '% | ' + statementsCoverageDiff.toFixed(2) + '%\n' +
                         'Branches |' + coverageContent.total.branches.pct + '% | ' + branchesCoverageDiff.toFixed(2) + '%\n' +
                         'Functions |' + coverageContent.total.functions.pct + '% | ' + functionsCoverageDiff.toFixed(2) + '%\n' +
                         'Lines |' + coverageContent.total.lines.pct + '% | ' + linesCoverageDiff.toFixed(2) + '%\n'
  markdown(coverageMarkdown)

  const coverageDropWarnThreshold = -1
  if (statementsCoverageDiff < coverageDropWarnThreshold || branchesCoverageDiff < coverageDropWarnThreshold || functionsCoverageDiff < coverageDropWarnThreshold || linesCoverageDiff < coverageDropWarnThreshold) {
    warn('One or more of your coverage numbers have dropped more than 1% because of this PR. Get with the program, dude.')
  }
}

// Warns if there are changes to package.json without changes to yarn.lock.
export function packages (): void {
  const packageChanged = _.includes(danger.git.modified_files, 'package.json')
  const lockfileChanged = _.includes(danger.git.modified_files, 'yarn.lock')
  if (packageChanged && !lockfileChanged) {
    const message = 'Changes were made to package.json, but not to yarn.lock'
    const idea = 'Perhaps you need to run `yarn install`?'
    warn(`${message} - <i>${idea}</i>`)
  }
}

export function commitMessage (): void {
  const commit = danger.github.commits[0]
  if (!commit) {
    return fail('Somehow you made a pull request without a commit. Good job!')
  }

  const message = commit.commit.message

  if (!message.trim()) {
    fail('Please add a commit message.')
  }

  // There are a few cases where linting commits is not required
  if (message.match(/\[ignore-commit-lint\]/g)) {
    return
  }
  handleReleaseNotes(message)
  handleAffects(message)

  if (!message.match(/test plan:/gi)) {
    fail('Please add a test plan. It should be prefixed with `test plan:`.')
  }

  handleJira(message)
}

function handleReleaseNotes (message) {
  var releaseNotes = /release note:(.+)/gi.exec(message)
  if (!releaseNotes) {
    fail('Please add a release note. If no release note is wanted, use `none`. Example: `release note: Fixed a bug that prevented users from enjoying the app.`')
    return
  }

  releaseNotes = releaseNotes || []
  if (releaseNotes.length > 2) {
    fail('Please add only one release note.')
  }

  const releaseNoteText = (releaseNotes[1] || '').trim()
  if (!releaseNoteText) {
    fail('Trying to be sneaky? You added a release note but left it blank?')
  } else {
    if (releaseNoteText === 'none') {
      warn('This pull request will not generate a release note.')
    } else {
      markdown(`#### Release Note: \n${releaseNoteText}`)
    }
  }
}

function handleAffects (message) {
  const affects = /affects:(.+)/gi.exec(message)
  if (!affects) {
    fail('Please add which apps this change affects. Example: `affects: Teacher, Student` or `affects: none`')
    return
  }

  let apps = affects[1]
  if (!apps) {
    fail('Did you forget to add app names after `affects:`?')
    return
  }

  apps = apps.split(',').map((x) => x.trim())
  const valid = ['student', 'teacher', 'parent', 'none']
  const invalid = apps.filter((e) => _.find(valid, e.toLowerCase()))
  if (invalid.length > 0) {
    fail(`You have included an invalid app. Valid values are: ${valid.map((e) => _.startCase(e)).join(', ')}`)
    return
  }

  const description = apps.map((a) => _.startCase(a)).join(', ')
  markdown(`#### Affected Apps: ${description}`)
}

function handleJira (message) {
  // Make sure to have jira ticket refs
  if (!message.match(/refs:/gi)) {
    fail('Please add a reference to a jira ticket. For example: `refs: MBL-10023`')
  }

  // Add links to the jira tickets in the markdown
  const issues = message.match(/mbl-\d+/gi) || []
  if (issues.length) {
    const set = new Set(issues.map(issue => issue.toUpperCase()))
    markdown([ ...set ].map(issue =>
      `[${issue}](https://instructure.atlassian.net/browse/${issue})`
    ).join('\n'))
  }
}

if (!danger.__TEST__) {
  commitMessage()
  annotations()
  untestedFiles()
  coverageReport()
}
