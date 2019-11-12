//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

const { danger, warn, markdown, fail } = require('danger')
const fs = require('fs')
const path = require('path')
const { checkCoverage } = require('./scripts/coverage/dangerfile-utils')
const { check } = require('./scripts/update-headers')

// Warns if there are changes to package.json without changes to yarn.lock.
function packages () {
  const packageChanged = danger.git.modified_files.includes('package.json')
  const lockfileChanged = danger.git.modified_files.includes('yarn.lock')
  if (packageChanged && !lockfileChanged) {
    const message = 'Changes were made to package.json, but not to yarn.lock'
    const idea = 'Perhaps you need to run `yarn install`?'
    warn(`${message} - <i>${idea}</i>`)
  }
}

function commitMessage () {
  const message = danger.github.pr.body
  if (!message) {
    return fail('Please add a description for Danger.')
  }

  if (!message.trim()) {
    fail('Please add a description for Danger.')
  }

  // There are a few cases where linting commits is not required
  if (message.match(/\[ignore-commit-lint\]/g)) {
    return
  }
  handleReleaseNotes(message)
  handleAffects(message)

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

  apps = apps.split(',').map(app => app.trim()).map(app =>
    app[0].toUpperCase() + app.slice(1).toLowerCase()
  )
  const valid = ['Student', 'Teacher', 'Parent', 'None']
  const invalid = apps.filter(app => !valid.includes(app))
  if (invalid.length > 0) {
    fail(`You have included an invalid app. Valid values are: ${valid.join(', ')}`)
    return
  }

  const description = apps.join(', ')
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

function licenseHeaders () {
  const files = danger.git.modified_files.concat(danger.git.created_files)
  const { replaced } = check(files)
  if (replaced.length === 0) { return }
  fail(`Please run \`yarn update-headers\`. The following do not have the correct license header: \n${
    replaced.sort().map(file => `* ${file}`).join('\n')
  }`)
}

// Takes a list of file paths, and converts it into clickable links
function linkableFiles (paths) {
  const repoURL = danger.github.pr.head.repo.html_url
  const ref = danger.github.pr.head.ref
  const links = paths.map((path) =>
    `[${path}](${repoURL}/blob/${ref}${path})`
  )
  return toSentence(links)
}

// ["1", "2", "3"] to "1, 2, and 3"
function toSentence (array) {
  if (array.length === 1) { return array[0] }
  return array.slice(0, -1).join(', ') + ', and ' + array.slice(-1)[0]
}

// New js files should have `@flow` at the top
function annotations () {
  const newJSFiles = danger.git.created_files.filter((path) => path.startsWith('rn/') && path.endsWith('js'))
  const unFlowedFiles = newJSFiles.filter((filepath) => {
    const content = fs.readFileSync(filepath)
    if (!content) return false
    return !content.includes('@flow')
  })

  if (unFlowedFiles.length > 0) {
    warn(`Please add @flow to these files: ${linkableFiles(unFlowedFiles)}`)
  }
}

// Checks for corresponding tests to js files in the commit's modified files
function untestedFiles () {
  const testFiles = danger.git.created_files.filter((path) => {
    return path.includes('__tests__/') && !path.includes('__snapshots__/')
  })

  const logicalTestPaths = testFiles.map((path) => {
    return path.replace(/__tests__\//, '').replace(/.test.js/, '.js')
  })

  const sourcePaths = danger.git.created_files.filter((path) => {
    const exclude = ['__tests__/', '__snapshots__/', '__mocks__/', '__templates__/', 'flow/']
    return path.includes('src/') &&
      path.includes('js') &&
      exclude.every(e => !path.includes(e))
  })

  const untestedFiles = sourcePaths.filter(path => !logicalTestPaths.includes(path))
  if (untestedFiles.length > 0) {
    warn('Please add tests for these files: ' + linkableFiles(untestedFiles))
  }
}

commitMessage()
if (process.env.BITRISE_BUILD_STATUS == "0" /* Not finished */) {
    checkCoverage()
} else {
    warn('Build failed, skipping coverage check')
}
packages()
licenseHeaders()
untestedFiles()
