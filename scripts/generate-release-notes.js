//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

//
//  Generates release notes from our common commit message format
//

const { spawnSync } = require('child_process')
const { addFixVersion } = require('./update-jira-issues')

console.log('Engage Release Notes Automation!')

// This is put between the commits to easily parse then into an array
let delimiter = '#---------------praise the sun---------------#'

generateReleaseNotes().catch((err) => {
  console.error('Generate release notes failed:', err)
  process.exit(2)
})

function run (cmd, args) {
  const { error, stderr, stdout } = spawnSync(cmd, args, { encoding: 'utf8' })
  if (stderr) { console.error(stderr) }
  if (error) { throw error }
  return stdout
}

function generateReleaseNotes () {
  const tag = process.argv[2] || ''
  const app = tag.split('-')[0]
  if (![ 'Parent', 'Student', 'Teacher' ].includes(app)) {
    throw new Error('The tag argument is required and must start with Parent-, Student-, or Teacher-')
  }

  console.log('Executing git fetch to make sure we have the latest tags....')
  run('git', [ 'fetch', '--force', '--tags' ])

  const tags = run('git', [ 'ls-remote', '--tags', '--sort=v:refname', 'origin', `refs/tags/${app}-*` ])
    .split('\n').map(line => line.split('/').pop()).filter(Boolean)
  const currentIndex = tags.indexOf(tag)
  const sinceTag = tags[currentIndex - 1]
  if (currentIndex < 0) {
    throw new Error(`${tag} is not a valid tag`)
  } else if (!sinceTag) {
    throw new Error('Could not find a previous tag')
  }

  console.log(`Generating release notes for ${app} ${sinceTag}...${tag}`)
  let result = run('git', [ 'log', `${sinceTag}...${tag}`, `--pretty=format:commit:%H%n%B${delimiter}`, '--' ])
  return parseGitLog(result, app.toLowerCase(), tag)
}

// Parses through the gitlog, using the app to know which ones to filter out
async function parseGitLog (log, app, tag) {
  let commits = log.split(delimiter).map(item => item.trim()).filter(a => a)
  let numCommitsForApp = 0
  let numCommitsForAppWithoutReleaseNote = 0
  let numCommitsNotForApp = 0
  let totalNumberOfJiras = 0
  let releaseNotes = []
  let allJiras = []
  let commitsWithoutJiraTicketNumbers = []
  let jirasWithoutReleaseNotes = []
  for (let commit of commits) {
    let hash = getCommitHash(commit)
    let apps = getAppsAffected(commit)
    if (apps.includes(app)) {
      numCommitsForApp++

      let note = getReleaseNote(commit)
      if (note) {
        releaseNotes.push(note)
      } else {
        numCommitsForAppWithoutReleaseNote++
      }

      let jiras = getJiras(commit)
      if (jiras.length) {
        totalNumberOfJiras += jiras.length
       allJiras.push(...jiras)

        if (!note) {
          jirasWithoutReleaseNotes.push(...jiras)
        }
      } else {
        commitsWithoutJiraTicketNumbers.push(hash)
      }
    } else {
      numCommitsNotForApp++
    }
  }

  console.log('')
  console.log(`Number of commits included in this release: ${numCommitsForApp}`)
  console.log(`Number of commits not included in this release: ${numCommitsNotForApp}`)
  console.log(`Total number of commits parsed: ${commits.length}`)
  console.log(`Number of commits included in this release without a release note: ${numCommitsForAppWithoutReleaseNote}`)
  console.log(`Number of jira tickets in this release: ${totalNumberOfJiras}`)
  if (commitsWithoutJiraTicketNumbers.length > 0) {
    console.log('')
    console.log('Commits that do not include a jira ticket number:')
    console.log(commitsWithoutJiraTicketNumbers.join('\n'))
  }

  if (jirasWithoutReleaseNotes.length > 0) {
    console.log('')
    console.log('Jira tickets without release notes:')
    console.log(jirasWithoutReleaseNotes.join('\n'))
  }

  console.log('')
  console.log('Jira tickets included in this release:')
  console.log(allJiras.join('\n'))
  console.log('')
  console.log('Release Notes:')
  console.log(releaseNotes.map(item => `- ${item}`).join('\n'))
  console.log('')

  if (process.env.JIRA_USERNAME && process.env.JIRA_API_TOKEN) {
    await addFixVersion(tag, allJiras)
  }
}

// Parses the commit message and looks for affects: "parent, student", etc.
// filters out 'none'
function getAppsAffected (commit) {
  const affects = /affects:(.+)/gi.exec(commit)
  if (!affects) {
    return []
  }

  let apps = affects[1]
  if (!apps) {
    return []
  }

  return apps.split(',').map(item => item.trim().toLowerCase()).filter(item => item !== 'none')
}

// Parses the release note out of the commit message
// If no release note is found, or if release note is 'none', returns null
// If there are multiple release notes, it will only return the first one
// Our commit linter doesn't allow more than one release note, so that shouldn't happen ever
function getReleaseNote (commit) {
  let releaseNotes = /release note:(.+)/gi.exec(commit)
  if (!releaseNotes || releaseNotes.length === 0) {
    return null
  }

  let note = releaseNotes[1].trim()
  if (note.toLowerCase().startsWith('none') && note.length <= 5) return null
  return note
}

// Parses out all the jira ticket numbers in the commit
// If there are none, returns an empty array
// Only handles one refs token
// the replace regex removes the tags in parentheses added by git eg. (#1234)
function getJiras (commit) {
  const refs = /refs:(.+)/gi.exec(commit)
  if (!refs) {
    return []
  }

  let jiras = refs[1].replace(/\([^()]*\)/g, '').split(',').map(a => a.trim()).filter(a => a !== 'none')
    
  // Check if any jira ticket number contains only numbers. If yes
  // we assume that it's missing the "MBL-" prefix and we prefix it with that.
  jiras = jiras.map(jira => {
    const containsOnlyNumbers = /^\d+$/.test(jira)
    if (containsOnlyNumbers) {
      return 'MBL-' + jira
    }
    return jira
  })

  return jiras
}

function getCommitHash (commit) {
  const hash = /commit:(.+)/gi.exec(commit)
  return hash[1]
}
