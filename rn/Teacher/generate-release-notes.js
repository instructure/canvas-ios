//
// Copyright (C) 2018-present Instructure, Inc.
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

//
//  Generates release notes from our common commit message format
//

// @flow

var prompt = require('prompt')
const { spawn } = require('child_process')

console.log('Engage Release Notes Automation!')

// This is put between the commits to easily parse then into an array
let delimiter = '#---------------praise the sun---------------#'

generateReleaseNotes().catch(err => {
  console.error('Export translations failed: ', err)
  process.exit(2)
})

function run (cmd, args, opts) {
  return new Promise((resolve, reject) => {
    const command = spawn(cmd, args, opts)
    command.on('error', reject)
    let result = ''
    command.stdout.on('data', data => {
      result += data.toString()
    })
    command.on('exit', code => {
      if (code === 0) return resolve(result)
      console.error(command.stderr.toString())
      reject(`${cmd} failed with code ${code}.`)
    })
  })
}

async function generateReleaseNotes () {
  console.log('Executing git fetch to make sure we have the latest tags....')
  await run('git', ['fetch'])
  prompt.start()
  prompt.get(['Previous release tag', 'Name of app to release'], async function (err, result) {
    if (err) {
      console.log('An error occured gathering the required input. Sorry!')
      return
    }

    let tag = result['Previous release tag']
    let app = result['Name of app to release']

    await finalizeReleaseNotes(tag, app)
  })
}

async function finalizeReleaseNotes (tag, app) {
  // Make sure that the tag passed in is valid
  let tags = await run('git', ['tag'])
  if (!tags.includes(tag)) {
    console.log('Invalid tag. Run `git tag` to see available tags.')
    process.exit(1)
  }

  try {
    let result = await run('git', ['log', `${tag}...HEAD`, `--pretty=format:commit:%H%n%B${delimiter}`])
    parseGitLog(result, app)
  } catch (e) {
    console.log(e)
  }
}

// Parses through the gitlog, using the app to know which ones to filter out
function parseGitLog (log, app) {
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
        jiras.forEach(j => allJiras.push(j))

        if (!note) {
          jiras.forEach(j => jirasWithoutReleaseNotes.push(j))
        }
      } else {
        commitsWithoutJiraTicketNumbers.push(hash)
      }
    } else {
      numCommitsNotForApp++
    }
  }

  const formattedReleaseNotes = releaseNotes.map(item => `- ${item}`).join('\n')
  const formattedJiras = allJiras.join('\n')

  console.log('')
  console.log(`Number of commits included in this release: ${numCommitsForApp}`)
  console.log(`Number of commits not included in this release: ${numCommitsNotForApp}`)
  console.log(`Total number of commits parsed: ${commits.length}`)
  console.log(`Number of commits included in this release without a release note: ${numCommitsForAppWithoutReleaseNote}`)
  console.log(`Number of jira tickets in this release: ${totalNumberOfJiras}`)
  if (commitsWithoutJiraTicketNumbers.length > 0) {
    const formatted = commitsWithoutJiraTicketNumbers.join('\n')
    console.log('')
    console.log('Commits that do not include a jira ticket number:')
    console.log(formatted)
  }

  if (jirasWithoutReleaseNotes.length > 0) {
    const formatted = jirasWithoutReleaseNotes.join('\n')
    console.log('')
    console.log('Jira tickets without release notes:')
    console.log(formatted)
  }

  console.log('')
  console.log('Jira tickets included in this release:')
  console.log(formattedJiras)
  console.log('')
  console.log('Release Notes:')
  console.log(formattedReleaseNotes)
  console.log('')
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

  return apps.split(',').map(item => item.trim()).filter(item => item.toLowerCase() !== 'none')
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
  if (note === 'none') return null
  return note
}

// Parses out all the jira ticket numbers in the commit
// If there are none, returns an empty array
// Only handles one refs token
function getJiras (commit) {
  const refs = /refs:(.+)/gi.exec(commit)
  if (!refs) {
    return []
  }

  let jiras = refs[1].split(',').map(a => a.trim()).filter(a => a !== 'none')
  return jiras
}

function getCommitHash (commit) {
  const hash = /commit:(.+)/gi.exec(commit)
  return hash[1]
}
